// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {ERC20} from "./ERC20.sol";

contract ERC20Mock is ERC20 {
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) ERC20(_name, _symbol, _decimals) {}

    function mint(address _to, uint256 _value) external payable override {
        _mint(_to, _value);
    }
}
