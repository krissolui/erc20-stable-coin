// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.21;

import {ERC20} from "./ERC20.sol";
import {DepositorCoin} from "./DepositorCoin.sol";
import {Oracle} from "./Oracle.sol";
import {FixedPoint, fromFraction, mulFixedPoint, divFixedPoint} from "./FixedPoint.sol";

error InitialCollactoralRationNotMatch(string message, uint256 minimumDeposit);

contract StableCoin is ERC20 {
    DepositorCoin public depositorCoin;
    Oracle public oracle;
    uint256 feeRate;
    uint256 initialCollactoralRatio;
    uint256 depositorCoinLockTime;

    constructor(
        string memory _name,
        string memory _symbol,
        Oracle _oracle,
        uint256 _feeRate,
        uint256 _initialCollactoralRatio,
        uint256 _depositorCoinLockTime
    ) ERC20(_name, _symbol, 18) {
        oracle = _oracle;
        feeRate = _feeRate;
        initialCollactoralRatio = _initialCollactoralRatio;
        depositorCoinLockTime = _depositorCoinLockTime;
    }

    function mint() external payable {
        uint256 mintAmount = (msg.value - _getFee(msg.value)) *
            oracle.getPrice();
        _mint(msg.sender, mintAmount);
    }

    function burn(uint256 _value) external {
        uint256 refundEthAmount = _value / oracle.getPrice();
        _burn(msg.sender, _value);
        (bool success, ) = msg.sender.call{
            value: refundEthAmount - _getFee(refundEthAmount)
        }("");
        require(success, "STC: Burn refund transaction failed.");
    }

    function depositCollactoralBuffer() external payable {
        int256 deficitOrSurplusUsd = _getDeficitOrSurplusUsd();

        if (deficitOrSurplusUsd <= 0) {
            uint256 deficitEth = uint256(deficitOrSurplusUsd * -1) /
                oracle.getPrice();

            uint addedSurplusEth = msg.value - deficitEth;

            uint256 requiredInitialSurplusUsd = (initialCollactoralRatio *
                totalSupply) / 100;
            uint256 requiredInitialSurplusEth = requiredInitialSurplusUsd /
                oracle.getPrice();
            // require(
            //     addedSurplusEth >= requiredInitialSurplusEth,
            //     "STC: Initial collateral ratio not met."
            // );
            if (addedSurplusEth < requiredInitialSurplusEth) {
                revert InitialCollactoralRationNotMatch({
                    message: "STC: Initial collateral ratio not met.",
                    minimumDeposit: deficitEth + requiredInitialSurplusEth
                });
            }

            uint256 initialDepositorCoinSupply = addedSurplusEth *
                oracle.getPrice();

            depositorCoin = new DepositorCoin(
                "Depositor Coin",
                "DPC",
                depositorCoinLockTime,
                msg.sender,
                initialDepositorCoinSupply
            );

            return;
        }

        FixedPoint usdInDpcPrice = fromFraction(
            depositorCoin.totalSupply(),
            uint256(deficitOrSurplusUsd)
        );
        uint256 mintDepositorCoinAmount = mulFixedPoint(
            msg.value * oracle.getPrice(),
            usdInDpcPrice
        );
        depositorCoin.mint(msg.sender, mintDepositorCoinAmount);
    }

    function withdrawCollactoralBuffer(uint256 _amount) external {
        int256 deficitOrSurplusUsd = _getDeficitOrSurplusUsd();
        require(
            deficitOrSurplusUsd > 0,
            "STC: No depositor funds to withdraw."
        );

        FixedPoint usdInDpcPrice = fromFraction(
            depositorCoin.totalSupply(),
            uint256(deficitOrSurplusUsd)
        );
        uint256 refundEthAmount = divFixedPoint(_amount, usdInDpcPrice) /
            oracle.getPrice();
        depositorCoin.burn(msg.sender, _amount);
        (bool success, ) = msg.sender.call{value: refundEthAmount}("");
        require(
            success,
            "STC: Withdraw collactoral buffer transaction failed."
        );
    }

    /**
     * Helper functions
     */
    function _getDeficitOrSurplusUsd() private view returns (int256) {
        uint256 usdBalance = (address(this).balance - msg.value) *
            oracle.getPrice();
        return int256(usdBalance) - int256(totalSupply);
    }

    function _getFee(uint256 _ethAmount) private view returns (uint256) {
        return (_ethAmount * feeRate) / 100;
    }
}
