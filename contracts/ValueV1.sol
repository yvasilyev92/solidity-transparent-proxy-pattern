// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Simple 1st Version of Logic Contract ValueV1

contract ValueV1 {
    
    mapping(address => uint) public valueMapping;

    function increaseValueMapping(uint _amount) external {
        valueMapping[msg.sender] += _amount;
    }
}