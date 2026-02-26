// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MyToken{
    mapping (address => uint256) public balanceOf;
    uint256 public totalSupply;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name;
    string public symbol;
    uint8 public decimals;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
