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
        uint256 baseRoyalty;
        string collDescURI;
        string collName;
        string collSymbol;
        address derivedRuleModule;
        bytes derivedRuleModuleInitData;
        address collectModule;
        bytes collectModuleInitData;
    }
}
