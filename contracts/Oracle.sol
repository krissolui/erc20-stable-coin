// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.21;

contract Oracle {
    uint256 private price;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function getPrice() external view returns (uint256) {
        return price;
    }

    function setPrice(uint256 _newPrice) external {
        require(msg.sender == owner, "EthUsdPrice: Only owner can set price.");
        price = _newPrice;
    }
}
