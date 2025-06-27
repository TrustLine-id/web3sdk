// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {IValidationEngine} from "./interfaces/IValidationEngine.sol";

/// @title Trustline's Base Contract
/// @author Trustline
/// @notice This library provides functions for verifying the trust status of a transaction
abstract contract Trustlined {
    /// @notice The Trustline ValidationEngine contract address. It must be set before any of the provided functions can be used
    /// @dev Multiple dapps can share the same ValidationEngine contract
    /// @dev This contract is set by the owner and must implement the IValidationEngine interface
    IValidationEngine public validationEngine;

    /// @dev Both a constructor and initializer functions are defined to support both upgradeable and non-upgradeable deployment scenarios
    constructor(address validationEngine_) {
        __Trustlined_init(validationEngine_);
    }

    function __Trustlined_init(address validation_) internal {
        __Trustlined_init_unchained(validation_);
    }

    function __Trustlined_init_unchained(address validationEngine_) internal {
        require(address(validationEngine) == address(0), "Already initialized");
        validationEngine = IValidationEngine(validationEngine_);
    }

    /// @notice Checks if a transaction is trusted
    /// @param addresses An array of addresses that will be verified by the policy
    function checkTrustlineStatus(address[] memory addresses) internal view returns (bool) {
        return validationEngine.checkTrustlineStatus(msg.sender, msg.value, msg.data, addresses);
    }

    /// @notice Checks if a transaction is trusted
    function checkTrustlineStatus() internal view returns (bool) {
        return validationEngine.checkTrustlineStatus(msg.sender, msg.value, msg.data);
    }

    /// @notice Requires a trusted transaction
    /// @param addresses An array of addresses that will be verified by the policy
    function requireTrustline(address[] memory addresses) internal {
        validationEngine.requireTrustline(msg.sender, msg.value, msg.data, addresses);
    }

    /// @notice Requires a trusted transaction
    function requireTrustline() internal {
        validationEngine.requireTrustline(msg.sender, msg.value, msg.data);
    }
}
