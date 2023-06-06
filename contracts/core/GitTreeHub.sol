// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {GitTreeDataTypes} from "../libraries/GitTreeDataTypes.sol";
import {DataTypes as LensDataTypes} from "../libraries/LensDataTypes.sol";
import {Errors} from "../libraries/Errors.sol";
import {Events} from "../libraries/Events.sol";
import {GitTreeStorage} from "./storage/GitTreeStorage.sol";
import {VersionedInitializable} from "../upgradeability/VersionedInitializable.sol";
import {GitTreeMultiState} from "./base/GitTreeMultiState.sol";
import {IGitTree} from "../interfaces/IGitTree.sol";
import {Lib_LensAddresses} from "../constants/Lib_LensAddresser.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ILensHub} from "../interfaces/ILensHub.sol";

contract GitTreeHub is
    VersionedInitializable,
    GitTreeMultiState,
    GitTreeStorage,
    IGitTree
{
    uint256 internal constant REVISION = 1;

    address internal immutable DERIVED_NFT_IMPL;

    modifier onlyGov() {
        _validateCallerIsGovernance();
        _;
    }

    constructor(address derivedNFTImpl) {
        if (derivedNFTImpl == address(0)) revert Errors.InitParamsInvalid();
        DERIVED_NFT_IMPL = derivedNFTImpl;
    }

    function initialize(address newGovernance) external override initializer {
        _setState(GitTreeDataTypes.GitTreeState.Paused);
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

    function setState(
        GitTreeDataTypes.GitTreeState newState
    ) external override {
        if (msg.sender == _emergencyAdmin) {
            if (newState != GitTreeDataTypes.GitTreeState.Paused)
                revert Errors.EmergencyAdminJustCanPause();
            _validateNotPaused();
        } else if (msg.sender != _governance) {
            revert Errors.NotGovernanceOrEmergencyAdmin();
        }
        _setState(newState);
    }

    /// ***************************************
    /// *****EXTERNAL FUNCTIONS*****
    /// ***************************************

    function createNewTree(
        GitTreeDataTypes.CreateNewTreeData calldata vars
    ) external returns (uint256) {
        _validateNotPaused();
        uint256 newTreeId;
        if (
            this.getState() == GitTreeDataTypes.GitTreeState.OnlyForLensHandle
        ) {
            if (
                IERC721(Lib_LensAddresses.LENS_HUB).ownerOf(vars.profileId) !=
                msg.sender
            ) {
                revert Errors.NotProfileOwner();
            }
            LensDataTypes.PostData memory postVar = LensDataTypes.PostData({
                profileId: vars.profileId,
                contentURI: vars.collDescURI,
                collectModule: vars.collectModule,
                collectModuleInitData: vars.collectModuleInitData,
                referenceModule: address(0x0),
                referenceModuleInitData: bytes("")
            });
            newTreeId = ILensHub(Lib_LensAddresses.LENS_HUB).post(postVar);
        } else {}
        //_deployDerivedNFT(vars.profileId, )
        return newTreeId;
    }

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

    function getRevision() internal pure virtual override returns (uint256) {
        return REVISION;
    }

    function getDerivedNFTImpl() external view override returns (address) {
        return DERIVED_NFT_IMPL;
    }
}
