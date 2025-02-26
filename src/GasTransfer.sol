// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library GasTransfer {
    event Transfer(
        address indexed sender,
        address indexed recipient,
        uint256 amount
    );

    function standardTransfer(
        mapping(address => uint256) storage balances,
        address sender,
        address _recipient,
        uint256 _amount
    ) external {
        balances[sender] -= _amount;
        balances[_recipient] += _amount;

        emit Transfer(sender, _recipient, _amount);
    }
} 