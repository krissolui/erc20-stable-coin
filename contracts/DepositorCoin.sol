// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.21;

import {ERC20} from "./ERC20.sol";

contract DepositorCoin is ERC20 {
    address public owner;
    uint256 public unlockTime;

    modifier isUnlocked() {
        require(block.timestamp >= unlockTime, "DPC: Still locked.");
        _;
    }
    modifier isOwner() {
        require(msg.sender == owner, "DPC: Caller must be owner.");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _lockTime,
        address _initialOwner,
        uint256 _initialSupply
    ) ERC20(_name, _symbol, 18) {
        owner = msg.sender;
        unlockTime = block.timestamp + _lockTime;
        _mint(_initialOwner, _initialSupply);
    }

    function mint(address _to, uint256 _value) external isOwner isUnlocked {
        _mint(_to, _value);
    }

    function burn(address _from, uint256 _value) external isOwner isUnlocked {
        _burn(_from, _value);
    }
}
