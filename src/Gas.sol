// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0; 

import "./Ownable.sol";


error OnlyAdminOrOwnerError();
error CheckIfWhiteListed();
error NotWhiteListed();
error UsersTierIncorrect();
error SenderNotOriginator();
error TierTooHigh();
error InsuffBal();
error NameTooLong();
error MustBeBiggerThanThree();
error NotBeZeroAddress();

contract GasContract {
    uint256 public totalSupply = 0; // cannot be updated
    mapping(address => uint256) public balances;
    mapping(address => uint256) public whitelist;
    mapping(address => bool) public isAdminAddress;

    address public contractOwner;
    address[5] public administrators;
    
    mapping(address => uint256 amount) public whiteListStruct;

    event AddedToWhitelist(address userAddress, uint256 tier);

    modifier onlyAdminOrOwner() {
        contractOwner = msg.sender;
        require(isAdminAddress[contractOwner], OnlyAdminOrOwnerError());
        _;
    }

    modifier checkIfWhiteListed(address sender) {
        require(sender == msg.sender, SenderNotOriginator());
        uint256 usersTier = whitelist[sender];
        require(usersTier <= 3, UsersTierIncorrect());
        _;
    }

    event supplyChanged(address indexed, uint256 indexed);
    event Transfer(address recipient, uint256 amount);
    event PaymentUpdated(
        address admin,
        uint256 ID,
        uint256 amount,
        string recipient
    );
    event WhiteListTransfer(address indexed);

    constructor(address[] memory _admins, uint256 _totalSupply) {
        contractOwner = msg.sender;
        totalSupply = _totalSupply;

        for (uint256 i = 0; i < _admins.length; i++) {
            address admin = _admins[i];
            if (admin != address(0)) {
                administrators[i] = admin;
                if (_admins[i] == contractOwner) {
                    balances[contractOwner] = totalSupply;
                    isAdminAddress[admin] = true;
                    emit supplyChanged(admin, totalSupply);
                } else {
                    balances[_admins[i]] = 0;
                    isAdminAddress[admin] = false;
                    emit supplyChanged(admin, 0);
                }
            }
        }
    }

    function checkForAdmin(address _user) public view returns (bool admin_) {
        return isAdminAddress[_user];
    }

    function balanceOf(address _user) public view returns (uint256 balance_) {
        return balances[_user];
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata _name
    ) public {
        address senderOfTx = msg.sender;
        require(
            balances[senderOfTx] >= _amount,
            InsuffBal()
        );
        require(
            bytes(_name).length < 9,
            NameTooLong()
        );
        balances[senderOfTx] -= _amount;
        balances[_recipient] += _amount;
        emit Transfer(_recipient, _amount);
    }

    function addToWhitelist(address _userAddrs, uint256 _tier)
        public
        onlyAdminOrOwner
    {
        require(_tier < 255, TierTooHigh());
        whitelist[_userAddrs] = _tier > 3 ? 3 : _tier; // Set to 3 if tier is greater than 3
        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount
    ) public checkIfWhiteListed(msg.sender) {
        address senderOfTx = msg.sender;
        require(
            balances[senderOfTx] >= _amount,
            InsuffBal()
        );
        require(
            _amount > 3,
            MustBeBiggerThanThree()
        );
        whiteListStruct[senderOfTx] = _amount;
        balances[senderOfTx] -= _amount;
        balances[_recipient] += _amount;
        balances[senderOfTx] += whitelist[senderOfTx];
        balances[_recipient] -= whitelist[senderOfTx];
        emit WhiteListTransfer(_recipient);
    }

    function getPaymentStatus(address sender) public view returns (bool, uint256) {
        return (true, whiteListStruct[sender]);
    }
}