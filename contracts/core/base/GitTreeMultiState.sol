// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {Events} from "../../libraries/Events.sol";
import {DataTypes} from "../../libraries/GitTreeDataTypes.sol";
import {Errors} from "../../libraries/Errors.sol";

/**
 * @title LensMultiState
 *
 * @notice This is an abstract contract that implements internal state setting and validation.
 *
 * whenNotPaused: Either publishingPaused or Unpaused.
 * whenPublishingEnabled: When Unpaused only.
 */
abstract contract GitTreeMultiState {
    DataTypes.GitTreeState private _state;

    modifier whenNotPaused() {
        _validateNotPaused();
        _;
    }

    /**
     * @notice Returns the current protocol state.
     *
     * @return GitTreeState The Protocol state, an enum, where:
     *      0: Unpaused
     *      1: Paused
     */
    function getState() external view returns (DataTypes.GitTreeState) {
        return _state;
    }

    function _setState(DataTypes.GitTreeState newState) internal {
        DataTypes.GitTreeState prevState = _state;
        _state = newState;
        emit Events.StateSet(msg.sender, prevState, newState, block.timestamp);
    }

    function _validateNotPaused() internal view {
        if (_state == DataTypes.GitTreeState.Paused) revert Errors.Paused();
    }
}
