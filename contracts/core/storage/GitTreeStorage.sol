// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "../../libraries/GitTreeDataTypes.sol" as DataTypes;

/**
 * @title GitTreeStorage
 *
 * @notice This is an abstract contract that *only* contains storage for the contract. This
 * *must* be inherited last (bar interfaces) in order to preserve the storage layout. Adding
 * storage variables should be done solely at the bottom of this contract.
 */
abstract contract GitTreeStorage {
    struct DervideCollectionStruct {
        string contentURI;
        address derivedRuletModule;
        address collectNFT;
    }

    mapping(address => bool) internal _derivedRuleModuleWhitelisted;

    mapping(address => uint256) internal _balance;
    mapping(address => uint256[]) internal _holdIndexes;
    mapping(uint256 => DervideCollectionStruct)
        internal _collectionByIdCollInfo;
    mapping(uint256 => address) internal _collectionOwners;
    address[] _allCollections;

    uint256 internal _collectionCounter;
    address internal _governance;
    address internal _emergencyAdmin;
}
