// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {TrustlinedUpgradeable} from "../TrustlinedUpgradeable.sol";

contract TestTrustlinedUpgradeableClient is Initializable, TrustlinedUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address trustlineValidationEngineLogic, address trustlineValidationEngineProxy) external initializer {
        __Trustlined_init(trustlineValidationEngineLogic, trustlineValidationEngineProxy);
    }

    function guardedNoArgs() external {
        requireTrustline();
    }

    function guardedWithAddress(address target) external {
        address[] memory addresses = new address[](1);
        addresses[0] = target;
        requireTrustline(addresses);
    }

    function canPassNoArgs() external view returns (bool) {
        return checkTrustlineStatus();
    }
}
