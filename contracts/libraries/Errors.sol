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
    error RoyaltyTooHigh();
    error DerivedRuleModuleNotWhitelisted();
    error FollowInvalid();
}
