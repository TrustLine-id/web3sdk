// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

/// @title Trustline's Validation interface
/// @author Trustline
/// @notice This interface defines the functions that must be implemented by the validation contract
/// @dev This interface is used by the Trustlined contract to interact with Trustline's Validation contract
interface IValidationEngine {
    /// @notice Checks if a transaction is trusted
    /// @param sender The transaction sender
    /// @param value Transaction value in wei
    /// @param data Transaction payload data
    /// @param addresses An array of addresses that will be verified by the policy
    function checkTrustlineStatus(
        address sender,
        uint256 value,
        bytes calldata data,
        address[] memory addresses
    ) external view returns (bool);

    /// @notice Checks if a transaction is trusted
    /// @param sender The transaction sender
    /// @param value Transaction value in wei
    /// @param data Transaction payload data
    function checkTrustlineStatus(
        address sender,
        uint256 value,
        bytes calldata data
    ) external view returns (bool);

    /// @notice Requires a trusted transaction
    /// @dev reverts if the transaction is not compliant
    /// @param sender The transaction sender
    /// @param value Transaction value in wei
    /// @param data Transaction payload data
    /// @param addresses An array of addresses that will be verified by the policy
    function requireTrustline(
        address sender,
        uint256 value,
        bytes calldata data,
        address[] memory addresses
    ) external;

    /// @notice Requires a trusted transaction
    /// @dev reverts if the transaction is not compliant
    /// @param sender The transaction sender
    /// @param value Transaction value in wei
    /// @param data Transaction payload data
    function requireTrustline(
        address sender,
        uint256 value,
        bytes calldata data
    ) external;
}