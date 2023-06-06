// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

library DataTypes {
    enum GitTreeState {
        Unpaused,
        Paused
    }

    struct CreateNewTreeData {
        string tokenURI;
        address collectModule;
        bytes collectModuleInitData;
        address referenceModule;
        bytes referenceModuleInitData;
    }
}
