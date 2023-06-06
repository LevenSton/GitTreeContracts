// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {Events} from "../../libraries/Events.sol";
import {GitTreeDataTypes as DataTypes} from "../../libraries/GitTreeDataTypes.sol";
import {Errors} from "../../libraries/Errors.sol";

/**
 * @title LensMultiState
 *
 * @notice This is an abstract contract that implements internal state setting and validation.
 *
 * whenNotPaused: Either publishingPaused or Unpaused.
 * whenPublishingEnabled: When Unpaused only.
 */
abstract contract GitTreeBaseState {
    DataTypes.GitTreeState private _state;
    uint256 internal _maxBaseRoyaltyForColletionOwner;
    uint256 internal _maxRoyaltyForNFT;

    modifier whenNotPaused() {
        _validateNotPaused();
        _;
    }

    function getState() external view returns (DataTypes.GitTreeState) {
        return _state;
    }

    function _setState(DataTypes.GitTreeState newState) internal {
        DataTypes.GitTreeState prevState = _state;
        _state = newState;
        emit Events.StateSet(msg.sender, prevState, newState, block.timestamp);
    }

    function _setMaxBaseRoyaltyForCollection(uint256 newBaseRoyalty) internal {
        uint256 prevMaxBaseRoyalty = _maxBaseRoyaltyForColletionOwner;
        _maxBaseRoyaltyForColletionOwner = newBaseRoyalty;
        emit Events.BaseRoyaltySet(
            msg.sender,
            prevMaxBaseRoyalty,
            newBaseRoyalty,
            block.timestamp
        );
    }

    function _setMaxNFTRoyalty(uint256 newRoyalty) internal {
        uint256 prevNFTRoyalty = _maxRoyaltyForNFT;
        _maxRoyaltyForNFT = newRoyalty;
        emit Events.NFTRoyaltySet(
            msg.sender,
            prevNFTRoyalty,
            newRoyalty,
            block.timestamp
        );
    }

    function _validateNotPaused() internal view {
        if (_state == DataTypes.GitTreeState.Paused) revert Errors.Paused();
    }
}
