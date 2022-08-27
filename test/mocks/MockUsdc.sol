// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "solmate/tokens/ERC20.sol";

contract MockUsdc is ERC20 {
    constructor(string memory _name, string memory _symbol, uint8 decimals) ERC20(_name, _symbol, decimals) {}
    
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

