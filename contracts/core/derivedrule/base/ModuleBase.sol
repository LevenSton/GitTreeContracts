// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {Errors} from "../../../libraries/Errors.sol";
import {Events} from "../../../libraries/Events.sol";

abstract contract ModuleBase {
    address public immutable LENSHUB;
    address public immutable GITTREEHUB;

    modifier onlyGitTreeHub() {
        if (msg.sender != GITTREEHUB) revert Errors.NotGitTreeHub();
        _;
    }

    constructor(address gitTreeHub, address lensHub) {
        if (gitTreeHub == address(0) || lensHub == address(0))
            revert Errors.InitParamsInvalid();
        GITTREEHUB = gitTreeHub;
        LENSHUB = lensHub;
        emit Events.ModuleBaseConstructed(lensHub, gitTreeHub, block.timestamp);
    }
}
