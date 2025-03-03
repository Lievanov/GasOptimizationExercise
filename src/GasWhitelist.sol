// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library GasWhitelist {
    error NotAdminOrOwner();
    error InvalidTier();

    event AddedToWhitelist(address userAddress, uint256 tier);
    event WhiteListTransfer(address indexed);

    struct WhitelistStorage {
        mapping(address => uint256) whitelist;
        mapping(address => uint256) whitelistAmounts;
    }

    function addToWhitelist(
        WhitelistStorage storage self,
        address _userAddrs,
        uint256 _tier,
        address[5] storage admins
    ) external {
        bool isAdmin = false;
        for (uint256 i = 0; i < 5; ++i) {
            if (msg.sender == admins[i]) {
                isAdmin = true;
                break;
            }
        }
        if (!isAdmin) revert NotAdminOrOwner();
        if (_tier >= 255) revert InvalidTier();
        
        self.whitelist[_userAddrs] = _tier > 3 ? 3 : _tier;

        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(
        WhitelistStorage storage self,
        address sender,
        address _recipient,
        uint256 _amount,
        mapping(address => uint256) storage balances
    ) external {
        uint8 tier = uint8(self.whitelist[sender]);
        uint256 adjustedAmount = _amount - tier;
                
        balances[sender] -= adjustedAmount;
        balances[_recipient] += adjustedAmount;
        
        self.whitelistAmounts[sender] = _amount;
        
        emit WhiteListTransfer(_recipient);
    }

    function getPaymentStatus(WhitelistStorage storage self, address sender) 
        external 
        view 
        returns (bool, uint256) 
    {
        return (true, self.whitelistAmounts[sender]);
    }
} 