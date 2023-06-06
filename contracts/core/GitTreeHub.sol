// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {GitTreeDataTypes} from "../libraries/GitTreeDataTypes.sol";
import {DataTypes as LensDataTypes} from "../libraries/LensDataTypes.sol";
import {Errors} from "../libraries/Errors.sol";
import {Events} from "../libraries/Events.sol";
import {GitTreeStorage} from "./storage/GitTreeStorage.sol";
import {VersionedInitializable} from "../upgradeability/VersionedInitializable.sol";
import {GitTreeBaseState} from "./base/GitTreeBaseState.sol";
import {IGitTree} from "../interfaces/IGitTree.sol";
import {Lib_LensAddresses} from "../constants/Lib_LensAddresser.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ILensHub} from "../interfaces/ILensHub.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {IDerivedNFT} from "../interfaces/IDerivedNFT.sol";
import {IDerivedModule} from "../interfaces/IDerivedModule.sol";

contract GitTreeHub is
    VersionedInitializable,
    GitTreeBaseState,
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

    function initialize(
        address newGovernance,
        uint256 _maxBaseRoyaltyForColletionOwner,
        uint256 _maxNFTRoyalty
    ) external override initializer {
        _setState(GitTreeDataTypes.GitTreeState.Paused);
        _setMaxBaseRoyaltyForCollection(_maxBaseRoyaltyForColletionOwner);
        _setMaxNFTRoyalty(_maxNFTRoyalty);
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

    function createNewCollectionTree(
        GitTreeDataTypes.CreateNewTreeData calldata vars
    ) external returns (uint256) {
        _validateNotPaused();
        _validateParams(vars.baseRoyalty);
        uint256 profileId;
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
            profileId = vars.profileId;
            LensDataTypes.PostData memory postVar = LensDataTypes.PostData({
                profileId: vars.profileId,
                contentURI: vars.collDescURI,
                collectModule: vars.collectModule,
                collectModuleInitData: vars.collectModuleInitData,
                referenceModule: address(0x0),
                referenceModuleInitData: bytes("")
            });
            newTreeId = ILensHub(Lib_LensAddresses.LENS_HUB).post(postVar);
        }

        address derivedCollectionAddr = _deployDerivedCollection(
            profileId,
            newTreeId,
            vars.baseRoyalty,
            vars.collName,
            vars.collSymbol
        );

        uint256 colltionId = ++_collectionCounter;
        bytes memory returnData = _setStateVariable(
            colltionId,
            msg.sender,
            derivedCollectionAddr,
            vars.derivedRuleModule,
            vars.collDescURI,
            vars.derivedRuleModuleInitData
        );
        emit Events.NewCollectionCreated(
            profileId,
            newTreeId,
            vars.collDescURI,
            derivedCollectionAddr,
            vars.derivedRuleModule,
            returnData,
            block.timestamp
        );
        return colltionId;
    }

    /// ****************************
    /// *****INTERNAL FUNCTIONS*****
    /// ****************************

    function _setStateVariable(
        uint256 colltionId,
        address creator,
        address collectionAddr,
        address ruleModule,
        string calldata url,
        bytes memory ruleModuleInitData
    ) internal returns (bytes memory) {
        if (!_derivedRuleModuleWhitelisted[ruleModule])
            revert Errors.DerivedRuleModuleNotWhitelisted();

        uint256 len = _allCollections.length;
        _balance[creator] += 1;
        _holdIndexes[creator].push(len);
        _collectionByIdCollInfo[colltionId] = DervideCollectionStruct({
            contentURI: url,
            derivedRuletModule: ruleModule,
            collectNFT: collectionAddr
        });
        _collectionOwners[colltionId] = creator;
        _allCollections.push(collectionAddr);

        return
            IDerivedModule(ruleModule).initializeDerivedRuleModule(
                colltionId,
                ruleModuleInitData
            );
    }

    function _validateParams(uint256 baseRoyalty) internal view returns (bool) {
        if (baseRoyalty > _maxBaseRoyaltyForColletionOwner) {
            revert Errors.RoyaltyTooHigh();
        }
        return true;
    }

    function _deployDerivedCollection(
        uint256 profileId,
        uint256 newTreeId,
        uint256 baseRoyalty,
        string memory collName,
        string memory collSymbol
    ) internal returns (address) {
        address derivedCollectionAddr = Clones.clone(DERIVED_NFT_IMPL);

        IDerivedNFT(derivedCollectionAddr).initialize(
            profileId,
            newTreeId,
            baseRoyalty,
            collName,
            collSymbol
        );
        emit Events.DerivedCollectioinDeployed(
            profileId,
            newTreeId,
            derivedCollectionAddr,
            block.timestamp
        );

        return derivedCollectionAddr;
    }

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
