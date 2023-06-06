// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {GitTreeDataTypes} from "../libraries/GitTreeDataTypes.sol";

/**
 * @title IGitTree
 *
 * @notice This is the interface for the contract, the main entry point for the protocol.
 * You'll find all the events and external functions, as well as the reasoning behind them here.
 */
interface IGitTree {
    function initialize(
        address newGovernance,
        uint256 _maxBaseRoyaltyForColletionOwner,
        uint256 _maxNFTRoyalty
    ) external;

    function setGovernance(address newGovernance) external;

    function setEmergencyAdmin(address newEmergencyAdmin) external;

    function getDerivedNFTImpl() external view returns (address);

    function setState(GitTreeDataTypes.GitTreeState newState) external;
}
