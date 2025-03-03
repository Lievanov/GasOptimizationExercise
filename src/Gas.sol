// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0; 

import "./GasWhitelist.sol";
import "./GasTransfer.sol";
import "./GasAdmin.sol";

contract GasContract {
    using GasWhitelist for GasWhitelist.WhitelistStorage;
    using GasTransfer for mapping(address => uint256);
    using GasAdmin for address[5];

    address[5] public administrators;
    mapping(address => uint256) public balances;
    GasWhitelist.WhitelistStorage private whitelistStorage;

    constructor(address[] memory _admins, uint256 _totalSupply) {        
        administrators.initializeAdmins(_admins);
        balances[msg.sender] = _totalSupply;
    }

    function checkForAdmin(address _user) public view returns (bool) {
        return administrators.isAdmin(_user);
    }

    function balanceOf(address _user) public view returns (uint256 balance_) {
        return balances[_user];
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata
    ) public {
        balances.standardTransfer(msg.sender, _recipient, _amount);
    }

    function addToWhitelist(address _userAddrs, uint256 _tier) public {
        whitelistStorage.addToWhitelist(_userAddrs, _tier, administrators);
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount
    ) public {
        whitelistStorage.whiteTransfer(msg.sender, _recipient, _amount, balances);
    }

    function getPaymentStatus(address sender) public view returns (bool, uint256) {
        return whitelistStorage.getPaymentStatus(sender);
    }

    function whitelist(address _user) public view returns (uint256) {
        return whitelistStorage.whitelist[_user];
    }
}