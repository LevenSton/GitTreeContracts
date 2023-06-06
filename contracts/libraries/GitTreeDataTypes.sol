// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

library GitTreeDataTypes {
    enum GitTreeState {
        OpenForAll,
        OnlyForLensHandle,
        Paused
    }

    struct CreateNewTreeData {
        uint256 profileId;
        string collDescURI;
        address collectModule;
        bytes collectModuleInitData;
    }
}
