// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

library Errors {
    error EmergencyAdminJustCanPause();
    error NotProfileOwner();
    error NotGovernanceOrEmergencyAdmin();
    error NotGovernance();

    error InitParamsInvalid();
    error CannotInitImplementation();
    error Initialized();
    error Paused();
    error ZeroSpender();
    error NotOwnerOrApproved();
    error SignatureExpired();
    error SignatureInvalid();
    error NotGitTreeHub();
    // error TokenDoesNotExist();
    // error CallerNotWhitelistedModule();
    // error CollectModuleNotWhitelisted();
    // error FollowModuleNotWhitelisted();
    // error ReferenceModuleNotWhitelisted();
    // error ProfileCreatorNotWhitelisted();
    // error NotProfileOwner();
    // error NotProfileOwnerOrDispatcher();
    // error NotDispatcher();
    // error PublicationDoesNotExist();
    // error HandleTaken();
    // error HandleLengthInvalid();
    // error HandleContainsInvalidCharacters();
    // error HandleFirstCharInvalid();
    // error ProfileImageURILengthInvalid();
    // error CallerNotFollowNFT();
    // error CallerNotCollectNFT();
    // error BlockNumberInvalid();
    // error ArrayMismatch();
    // error CannotCommentOnSelf();
    // error NotWhitelisted();
    // error InvalidParameter();

    // // Module Errors
    // error CollectExpired();
    // error FollowInvalid();
    // error ModuleDataMismatch();
    // error FollowNotApproved();
    // error MintLimitExceeded();
    // error CollectNotAllowed();

    // // MultiState Errors
    // error Paused();
    // error PublishingPaused();
}
