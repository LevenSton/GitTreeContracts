// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {DataTypes} from "../libraries/GitTreeDataTypes.sol";
import {Errors} from "../libraries/Errors.sol";
import {Events} from "../libraries/Events.sol";
import {GitTreeStorage} from "./storage/GitTreeStorage.sol";
import {VersionedInitializable} from "../upgradeability/VersionedInitializable.sol";
import {GitTreeMultiState} from "./base/GitTreeMultiState.sol";
import {IGitTree} from "../interfaces/IGitTree.sol";

contract GitTreeHub is
    VersionedInitializable,
    GitTreeMultiState,
    GitTreeStorage,
    IGitTree
{
    uint256 internal constant REVISION = 1;

    address internal immutable COLLECT_NFT_IMPL;

    modifier onlyGov() {
        _validateCallerIsGovernance();
        _;
    }

    constructor(address collectNFTImpl) {
        if (collectNFTImpl == address(0)) revert Errors.InitParamsInvalid();
        COLLECT_NFT_IMPL = collectNFTImpl;
    }

    function initialize(address newGovernance) external override initializer {
        _setState(DataTypes.GitTreeState.Paused);
        _setGovernance(newGovernance);
    }

    /// ***********************
    /// *****GOV FUNCTIONS*****
    /// ***********************

    function setGovernance(address newGovernance) external override onlyGov {
        _setGovernance(newGovernance);
    }

    function setEmergencyAdmin(
        address newEmergencyAdmin
    ) external override onlyGov {
        address prevEmergencyAdmin = _emergencyAdmin;
        _emergencyAdmin = newEmergencyAdmin;
        emit Events.EmergencyAdminSet(
            msg.sender,
            prevEmergencyAdmin,
            newEmergencyAdmin,
            block.timestamp
        );
    }

    function setState(DataTypes.GitTreeState newState) external override {
        if (msg.sender == _emergencyAdmin) {
            if (newState == DataTypes.GitTreeState.Unpaused)
                revert Errors.EmergencyAdminCannotUnpause();
            _validateNotPaused();
        } else if (msg.sender != _governance) {
            revert Errors.NotGovernanceOrEmergencyAdmin();
        }
        _setState(newState);
    }

    function createNewTree() external returns (uint256) {}

    /// ****************************
    /// *****INTERNAL FUNCTIONS*****
    /// ****************************

    function _setGovernance(address newGovernance) internal {
        address prevGovernance = _governance;
        _governance = newGovernance;
        emit Events.GovernanceSet(
            msg.sender,
            prevGovernance,
            newGovernance,
            block.timestamp
        );
    }

    function _validateCallerIsGovernance() internal view {
        if (msg.sender != _governance) revert Errors.NotGovernance();
    }

    function getRevision() internal pure virtual override returns (uint256) {}

    function getCollectNFTImpl() external view override returns (address) {}
}
