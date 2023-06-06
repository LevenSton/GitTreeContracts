// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

interface IDerivedModule {
    function initializeDerivedRuleModule(
        uint256 collectionId,
        bytes calldata data
    ) external returns (bytes memory);

    function processDerived(
        address collector,
        uint256 collectionId,
        bytes calldata data
    ) external;
}
