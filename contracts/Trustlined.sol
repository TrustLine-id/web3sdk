// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IValidationEngine} from "./interfaces/IValidationEngine.sol";

/// @title Trustline's Base Contract
/// @author Trustline
/// @notice This library provides functions for verifying the trust status of a transaction
abstract contract Trustlined {
    /// @notice Emitted when a new Validation Engine proxy is deployed for this client contract.
    /// @dev `client` is the address of the integrating contract (i.e., the contract inheriting from Trustlined).
    /// @dev `engineProxy` is the freshly deployed ERC1967 proxy address for the Validation Engine instance.
    /// @dev `logic` is the Validation Engine implementation (logic) contract the proxy points to at deployment time.
    /// @dev `initialOwner` is the address passed to the engine's `initialize(address)` call (typically the deployer/initializer).
    event ValidationEngineDeployed(
        address indexed client,
        address indexed engineProxy,
        address indexed logic,
        address initialOwner
    );

    /// @notice The Trustline ValidationEngine contract address. It must be set before any of the provided functions can be used
    /// @dev Multiple dapps can share the same ValidationEngine contract
    /// @dev This contract is set by the owner and must implement the IValidationEngine interface
    IValidationEngine public validationEngine;

    /// @dev Constructor-only initialization for non-upgradeable deployment scenarios
    /// @param trustlineValidationEngineLogic The Validation Engine logic contract address for deploying a proxy (used only if trustlineValidationEngineProxy is zero)
    /// @param trustlineValidationEngineProxy Optional Validation Engine proxy address. If provided (non-zero), it will be used directly instead of deploying a new proxy
    constructor(address trustlineValidationEngineLogic, address trustlineValidationEngineProxy) {
        if (trustlineValidationEngineProxy != address(0)) {
            // Use the provided Validation Engine proxy
            require(trustlineValidationEngineProxy.code.length > 0, "Proxy is not a contract");
            validationEngine = IValidationEngine(trustlineValidationEngineProxy);
        } else {
            // Deploy a new Validation Engine proxy
            require(trustlineValidationEngineLogic.code.length > 0, "Logic is not a contract");

            address initialOwner = msg.sender;

            // Deployment of the Validation Engine proxy
            bytes memory data = abi.encodeWithSignature("initialize(address)", initialOwner);
            address proxy_ = address(new ERC1967Proxy(trustlineValidationEngineLogic, data));

            validationEngine = IValidationEngine(proxy_);

            emit ValidationEngineDeployed(address(this), proxy_, trustlineValidationEngineLogic, initialOwner);
        }
    }

    /// @notice Checks whether a transaction is trusted and verifies msg.sender + addresses[] against sanctions lists
    /// @param addresses An array of addresses that will be verified by the policy
    function checkTrustlineStatus(address[] memory addresses) internal view returns (bool) {
        return validationEngine.checkTrustlineStatus(msg.sender, msg.value, msg.data, addresses);
    }

    /// @notice Checks whether a transaction is trusted and verifies msg.sender against sanctions lists
    function checkTrustlineStatus() internal view returns (bool) {
        return validationEngine.checkTrustlineStatus(msg.sender, msg.value, msg.data);
    }

    /// @notice Requires a trusted transaction and non‑sanctioned msg.sender + addresses[]
    /// @param addresses An array of addresses that will be verified by the policy
    function requireTrustline(address[] memory addresses) internal {
        validationEngine.requireTrustline(msg.sender, msg.value, msg.data, addresses);
    }

    /// @notice Requires a trusted transaction and a non‑sanctioned msg.sender
    function requireTrustline() internal {
        validationEngine.requireTrustline(msg.sender, msg.value, msg.data);
    }
}
