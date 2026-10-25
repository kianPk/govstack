// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {GovToken} from "../src/GovToken.sol";
import {GovGovernor} from "../src/GovGovernor.sol";
import {Treasury} from "../src/Treasury.sol";
import {ProposalLib} from "../src/ProposalLib.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";
import {IGovernor} from "@openzeppelin/contracts/governance/IGovernor.sol";

contract GovStackTest is Test {
    GovToken token;
    TimelockController timelock;
    GovGovernor governor;
    Treasury treasury;

    address admin = makeAddr("admin");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address recipient = makeAddr("recipient");

    function setUp() public {
        vm.startPrank(admin);
        token = new GovToken(admin);

        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](1);
        executors[0] = address(0);

        timelock = new TimelockController(1 hours, proposers, executors, admin);
        governor = new GovGovernor(token, timelock);
        treasury = new Treasury(address(timelock));

        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.CANCELLER_ROLE(), address(governor));
        timelock.revokeRole(timelock.DEFAULT_ADMIN_ROLE(), admin);

        token.mint(alice, 600_000 ether);
        token.mint(bob, 400_000 ether);
        vm.stopPrank();

        vm.deal(address(treasury), 10 ether);

        vm.prank(alice);
        token.delegate(alice);
        vm.prank(bob);
        token.delegate(bob);

        // let checkpoints settle
        vm.warp(block.timestamp + 1);
    }

    function test_proposalLifecycleSpendsTreasury() public {
        (address[] memory targets, uint256[] memory values, bytes[] memory calldatas) =
            ProposalLib.ethGrant(address(treasury), payable(recipient), 1 ether);

        string memory desc = "Send 1 ETH grant";

        vm.prank(alice);
        uint256 proposalId = governor.propose(targets, values, calldatas, desc);

        // wait voting delay
        vm.warp(block.timestamp + governor.votingDelay() + 1);

        vm.prank(alice);
        governor.castVote(proposalId, 1); // For
        vm.prank(bob);
        governor.castVote(proposalId, 1);

        vm.warp(block.timestamp + governor.votingPeriod() + 1);

        governor.queue(targets, values, calldatas, keccak256(bytes(desc)));
        vm.warp(block.timestamp + timelock.getMinDelay() + 1);
        governor.execute(targets, values, calldatas, keccak256(bytes(desc)));

        assertEq(recipient.balance, 1 ether);
        assertEq(address(treasury).balance, 9 ether);
        assertEq(uint256(governor.state(proposalId)), uint256(IGovernor.ProposalState.Executed));
    }

    function test_treasuryBatchSpend() public {
        address payable r1 = payable(makeAddr("r1"));
        address payable r2 = payable(makeAddr("r2"));

        address payable[] memory recipients = new address payable[](2);
        recipients[0] = r1;
        recipients[1] = r2;
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 1 ether;
        amounts[1] = 2 ether;

        vm.prank(address(timelock));
        treasury.batchSpend(recipients, amounts);

        assertEq(r1.balance, 1 ether);
        assertEq(r2.balance, 2 ether);
        assertEq(address(treasury).balance, 7 ether);
    }

    function test_batchSpendRevertsOnLengthMismatch() public {
        address payable[] memory recipients = new address payable[](1);
        recipients[0] = payable(makeAddr("r1"));
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 1 ether;
        amounts[1] = 1 ether;

        vm.prank(address(timelock));
        vm.expectRevert(Treasury.ArrayLengthMismatch.selector);
        treasury.batchSpend(recipients, amounts);
    }

    function test_quorumRequired() public {
        // alice has 60%, enough alone for quorum (4%) and majority
        assertGe(token.getVotes(alice), token.totalSupply() * 4 / 100);
    }
}
