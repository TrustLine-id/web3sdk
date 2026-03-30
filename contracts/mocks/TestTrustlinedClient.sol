// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {Trustlined} from "../Trustlined.sol";

contract TestTrustlinedClient is Trustlined {
    constructor(address trustlineValidationEngineLogic, address trustlineValidationEngineProxy)
        Trustlined(trustlineValidationEngineLogic, trustlineValidationEngineProxy)
    {}

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
