// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {GovToken} from "../src/GovToken.sol";
import {GovGovernor} from "../src/GovGovernor.sol";
import {Treasury} from "../src/Treasury.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

contract DeployGovStack is Script {
    function run() external {
        address deployer = msg.sender;
        vm.startBroadcast();

        GovToken token = new GovToken(deployer);
        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](1);
        executors[0] = address(0); // open execution once ready

        TimelockController timelock =
            new TimelockController(1 hours, proposers, executors, deployer);
        GovGovernor governor = new GovGovernor(token, timelock);
        Treasury treasury = new Treasury(address(timelock));

        bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bytes32 cancellerRole = timelock.CANCELLER_ROLE();
        bytes32 adminRole = timelock.DEFAULT_ADMIN_ROLE();

        timelock.grantRole(proposerRole, address(governor));
        timelock.grantRole(cancellerRole, address(governor));
        timelock.revokeRole(adminRole, deployer);

        token.mint(deployer, 1_000_000 ether);

        vm.stopBroadcast();

        console2.log("GovToken", address(token));
        console2.log("Timelock", address(timelock));
        console2.log("Governor", address(governor));
        console2.log("Treasury", address(treasury));
    }
}
