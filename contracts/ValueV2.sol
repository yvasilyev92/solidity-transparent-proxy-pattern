// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Simple 2nd Version of Logic Contract ValueV1 to upgrade from

contract ValueV2 {
    
    mapping(address => uint) public valueMapping;

    function increaseValueMapping(uint _amount) external {
        valueMapping[msg.sender] += _amount;
    }

    function decreaseValueMapping(uint _amount) external {
        valueMapping[msg.sender] -= _amount;
    }
}