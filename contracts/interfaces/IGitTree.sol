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
    /**
     * @notice Initializes the NFT, setting the initial governance address as well as the name and symbol in
     * the LensNFTBase contract.
     *
     * @param newGovernance The governance address to set.
     */
    function initialize(address newGovernance) external;

    /**
     * @notice Sets the privileged governance role. This function can only be called by the current governance
     * address.
     *
     * @param newGovernance The new governance address to set.
     */
    function setGovernance(address newGovernance) external;

    function setEmergencyAdmin(address newEmergencyAdmin) external;

    function getDerivedNFTImpl() external view returns (address);

    function setState(GitTreeDataTypes.GitTreeState newState) external;
}
