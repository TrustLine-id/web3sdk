// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
//import {Trustlined} from "@trustline.id/evmsdk/contracts/Trustlined.sol";
import {Trustlined} from "../Trustlined.sol";

/// @title PaymentFirewall
/// @author Trustline
/// @notice This contract is a firewall ensuring all funds going in and out are compliant
contract PaymentFirewall is Trustlined, ReentrancyGuard {
    using SafeERC20 for IERC20;

    constructor(address trustlineValidationEngineLogic, address trustlineValidationEngineProxy) Trustlined(trustlineValidationEngineLogic, trustlineValidationEngineProxy) {}

    /// @notice Pay native ethers to a recipient
    /// @param destination The recipient address
    function payEthers(address payable destination) public payable nonReentrant {
        require(destination != address(0), "Invalid destination");
        require(msg.value > 0, "Invalid amount");

        address[] memory addresses = new address[](1);
        addresses[0] = destination;
        requireTrustline(addresses);
        (bool sent, ) = destination.call{value: msg.value}("");
        require(sent, "Unable to pay ethers");
    }

    /// @notice Pay ERC20 tokens to a recipient
    /// @param destination The recipient address
    /// @param token The ERC20 token address
    /// @param value The amount of tokens to pay
    function payTokens(address destination, address token, uint256 value) external nonReentrant {
        require(destination != address(0), "Invalid destination");
        require(token != address(0), "Invalid token");
        require(value > 0, "Invalid amount");

        address[] memory addresses = new address[](1);
        addresses[0] = destination;
        requireTrustline(addresses);
        IERC20(token).safeTransferFrom(msg.sender, destination, value);
    }
}
