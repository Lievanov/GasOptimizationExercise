// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library GasAdmin {
    function initializeAdmins(
        address[5] storage administrators,
        address[] memory _admins
    ) external {
        for (uint256 i; i < 5; ++i) {
            administrators[i] = _admins[i];
        }
    }

    function isAdmin(
        address[5] storage administrators,
        address _user
    ) external view returns (bool) {
        return (_user == administrators[0] || 
                _user == administrators[1] ||
                _user == administrators[2] ||
                _user == administrators[3] ||
                _user == administrators[4]);
    }
} 