// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {IFollowModule} from "../../../interfaces/lens/IFollowModule.sol";
import {ILensHub} from "../../../interfaces/lens/ILensHub.sol";
import {Errors} from "../../../libraries/Errors.sol";
import {Events} from "../../../libraries/Events.sol";
import {ModuleBase} from "./ModuleBase.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

abstract contract FollowValidationModuleBase is ModuleBase {
    function _checkFollowValidity(
        uint256 profileId,
        address user
    ) internal view {
        address followModule = ILensHub(LENSHUB).getFollowModule(profileId);
        bool isFollowing;
        if (followModule != address(0)) {
            isFollowing = IFollowModule(followModule).isFollowing(
                profileId,
                user,
                0
            );
        } else {
            address followNFT = ILensHub(LENSHUB).getFollowNFT(profileId);
            isFollowing =
                followNFT != address(0) &&
                IERC721(followNFT).balanceOf(user) != 0;
        }
        if (!isFollowing && IERC721(LENSHUB).ownerOf(profileId) != user) {
            revert Errors.FollowInvalid();
        }
    }
}
