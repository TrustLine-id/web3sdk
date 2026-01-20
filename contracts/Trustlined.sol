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

    /// @dev Both a constructor and initializer functions are defined to support both upgradeable and non-upgradeable deployment scenarios
    constructor(address trustlineValidationEngineLogic) {
        __Trustlined_init(trustlineValidationEngineLogic);
    }

    function __Trustlined_init(address logic) internal {
        __Trustlined_init_unchained(logic);
    }

    function __Trustlined_init_unchained(address logic) internal {
        require(address(validationEngine) == address(0), "Already initialized");
        require(logic.code.length > 0, "Logic is not a contract");

        address initialOwner = msg.sender;

        // Deployment of the Validation Engine proxy
        bytes memory data = abi.encodeWithSignature("initialize(address)", initialOwner);
        address proxy = address(new ERC1967Proxy(logic, data));

        validationEngine = IValidationEngine(proxy);

        emit ValidationEngineDeployed(address(this), proxy, logic, initialOwner);
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
