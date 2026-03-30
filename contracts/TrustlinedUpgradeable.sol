// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IValidationEngine} from "./interfaces/IValidationEngine.sol";

/// @title Trustline's Upgradeable Base Contract
/// @author Trustline
/// @notice Upgradeable variant of Trustlined for proxy-based deployments
abstract contract TrustlinedUpgradeable is Initializable {
    /// @notice Emitted when a new Validation Engine proxy is deployed for this client contract.
    event ValidationEngineDeployed(
        address indexed client,
        address indexed engineProxy,
        address indexed logic,
        address initialOwner
    );

    /// @notice The Trustline ValidationEngine contract address. It must be set before any of the provided functions can be used
    IValidationEngine public validationEngine;

    /// @dev Initializer for proxy-based deployments.
    /// @param logic The Validation Engine logic contract address for deploying a proxy (used only if proxy is zero)
    /// @param proxy Optional Validation Engine proxy address. If provided (non-zero), it is used directly
    function __Trustlined_init(address logic, address proxy) internal onlyInitializing {
        __Trustlined_init_unchained(logic, proxy);
    }

    function __Trustlined_init_unchained(address logic, address proxy) internal onlyInitializing {
        require(address(validationEngine) == address(0), "Already initialized");

        if (proxy != address(0)) {
            require(proxy.code.length > 0, "Proxy is not a contract");
            validationEngine = IValidationEngine(proxy);
        } else {
            require(logic.code.length > 0, "Logic is not a contract");

            address initialOwner = msg.sender;
            bytes memory data = abi.encodeWithSignature("initialize(address)", initialOwner);
            address proxy_ = address(new ERC1967Proxy(logic, data));

            validationEngine = IValidationEngine(proxy_);

            emit ValidationEngineDeployed(address(this), proxy_, logic, initialOwner);
        }
    }

    /// @notice Checks whether a transaction is trusted and verifies msg.sender + addresses[] against sanctions lists
    function checkTrustlineStatus(address[] memory addresses) internal view returns (bool) {
        return validationEngine.checkTrustlineStatus(msg.sender, msg.value, msg.data, addresses);
    }

    /// @notice Checks whether a transaction is trusted and verifies msg.sender against sanctions lists
    function checkTrustlineStatus() internal view returns (bool) {
        return validationEngine.checkTrustlineStatus(msg.sender, msg.value, msg.data);
    }

    /// @notice Requires a trusted transaction and non-sanctioned msg.sender + addresses[]
    function requireTrustline(address[] memory addresses) internal {
        validationEngine.requireTrustline(msg.sender, msg.value, msg.data, addresses);
    }

    /// @notice Requires a trusted transaction and a non-sanctioned msg.sender
    function requireTrustline() internal {
        validationEngine.requireTrustline(msg.sender, msg.value, msg.data);
    }

    uint256[49] private __gap;
}
