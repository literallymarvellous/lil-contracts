// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import {Vm} from "../../lib/forge-std/src/Vm.sol";
import "../../lib/ds-test/src/test.sol";
import {MultiSigWallet} from "../MultiSigWallet.sol";

contract multisigWalletTest is DSTest {
    Vm internal constant vm = Vm(HEVM_ADDRESS);
    MultiSigWallet internal multisigWallet;
    address[] public owners;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
    }

    receive() external payable {}

    function setUp() public {
        address a = vm.addr(1);
        address b = vm.addr(2);
        address c = vm.addr(3);
        owners.push(a);
        owners.push(b);
        owners.push(c);
        multisigWallet = new MultiSigWallet(owners, 2);
    }

    function testSubmit() public {
        vm.prank(owners[0]);
        multisigWallet.submit(msg.sender, 0.001 ether, "");
        (address to, , , ) = multisigWallet.transactions(0);
        assertEq(to, msg.sender);
    }

    function testCannotSubmit() public {
        vm.expectRevert("Only owner can call this function");
        multisigWallet.submit(msg.sender, 0.001 ether, "");
        uint256 len = multisigWallet.getTransactionLength();
        assertEq(len, 0);
    }

    function testApprove() public {
        vm.prank(owners[0]);
        multisigWallet.submit(msg.sender, 0.001 ether, "");

        (address to, , , ) = multisigWallet.transactions(0);
        assertEq(to, msg.sender);

        vm.prank(owners[1]);
        multisigWallet.approve(0);

        bool success = multisigWallet.approved(0, owners[1]);
        assert(success);
    }

    function testExecute() public {
        vm.prank(owners[0]);
        multisigWallet.submit(msg.sender, 0.001 ether, "");

        (address to, , , ) = multisigWallet.transactions(0);
        assertEq(to, msg.sender);

        vm.prank(owners[1]);
        multisigWallet.approve(0);

        bool success = multisigWallet.approved(0, owners[1]);
        assert(success);

        vm.prank(owners[2]);
        multisigWallet.approve(0);

        bool successTwo = multisigWallet.approved(0, owners[2]);
        assert(successTwo);

        vm.deal(address(multisigWallet), 1 ether);
        multisigWallet.execute(0);

        (, , , bool executed) = multisigWallet.transactions(0);
        assert(executed);
    }

    function testRevoke() public {
        vm.prank(owners[0]);
        multisigWallet.submit(msg.sender, 0.001 ether, "");

        (address to, , , ) = multisigWallet.transactions(0);
        assertEq(to, msg.sender);

        vm.prank(owners[1]);
        multisigWallet.approve(0);

        bool success = multisigWallet.approved(0, owners[1]);
        assert(success);

        vm.prank(owners[1]);
        multisigWallet.revoke(0);

        bool successTwo = multisigWallet.approved(0, owners[1]);
        assert(!successTwo);
    }

    function testCannotRevoke() public {
        vm.prank(owners[0]);
        multisigWallet.submit(msg.sender, 0.001 ether, "");

        (address to, , , ) = multisigWallet.transactions(0);
        assertEq(to, msg.sender);

        vm.prank(owners[1]);
        vm.expectRevert("Not approved");
        multisigWallet.revoke(0);

        bool success = multisigWallet.approved(0, owners[1]);
        assert(!success);
    }

    function testCannotExecuteBelowRequiredApprovals() public {
        vm.prank(owners[0]);
        multisigWallet.submit(msg.sender, 0.001 ether, "");

        (address to, , , ) = multisigWallet.transactions(0);
        assertEq(to, msg.sender);

        vm.prank(owners[1]);
        multisigWallet.approve(0);

        bool success = multisigWallet.approved(0, owners[1]);
        assert(success);

        vm.expectRevert("Not enough approvals");
        multisigWallet.execute(0);

        (, , , bool executed) = multisigWallet.transactions(0);
        assert(!executed);
    }
}
