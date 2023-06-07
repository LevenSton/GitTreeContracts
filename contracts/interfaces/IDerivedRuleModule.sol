// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

interface IDerivedRuleModule {
    function initializeDerivedRuleModule(
        uint256 collectionId,
        uint256 profileId,
        uint256 pubId,
        bytes calldata data
    ) external returns (bytes memory);

    function processDerived(
        address collector,
        uint256 collectionId,
        uint256 profileId,
        bytes calldata data
    ) external;
}
