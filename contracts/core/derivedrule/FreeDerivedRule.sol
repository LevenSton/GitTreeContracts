// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {IDerivedRuleModule} from "../../interfaces/IDerivedRuleModule.sol";
import {ModuleBase} from "./base/ModuleBase.sol";
import {FollowValidationModuleBase} from "./base/FollowValidationModuleBase.sol";

contract FreeDerivedRule is FollowValidationModuleBase, IDerivedRuleModule {
    constructor(
        address gitTreeHub,
        address lensHub
    ) ModuleBase(gitTreeHub, lensHub) {}

    struct RuleInfo {
        uint256 profileId;
        uint248 pubId;
        uint8 bFollower;
    }
    mapping(uint256 => RuleInfo) internal _onlyAllowLensFollowDerived;

    function initializeDerivedRuleModule(
        uint256 collectionId,
        uint256 profileId,
        uint256 pubId,
        bytes calldata data
    ) external override onlyGitTreeHub returns (bytes memory) {
        bool followerOnly = abi.decode(data, (bool));
        if (followerOnly)
            _onlyAllowLensFollowDerived[collectionId] = RuleInfo(
                profileId,
                uint248(pubId),
                1
            );
        return data;
    }

    function processDerived(
        address collector,
        uint256 collectionId,
        uint256 profileId,
        bytes calldata data
    ) external view override {
        if (_onlyAllowLensFollowDerived[collectionId].bFollower > 0)
            _checkFollowValidity(profileId, collector);
    }
}
