// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import {Vm} from "../../lib/forge-std/src/Vm.sol";
import "../../lib/ds-test/src/test.sol";
import {EtherWallet} from "../EtherWallet.sol";

contract etherWalletTest is DSTest {
    Vm internal constant vm = Vm(HEVM_ADDRESS);
    EtherWallet internal etherWallet;

    receive() external payable {}

    function setUp() public {
        etherWallet = new EtherWallet();
    }

    function testBalance() public {
        uint256 amount = etherWallet.getBalance();
        assertEq(amount, 0);
    }

    function testCanRecieveEther() public {
        (bool success, ) = address(etherWallet).call{value: 1 ether}("");
        assertTrue(success);
    }

    function testCanSendEther() public {
        (bool success, ) = address(etherWallet).call{value: 1 ether}("");
        assertTrue(success);

        uint256 amount = etherWallet.getBalance() - 0.01 ether;

        etherWallet.sendEther(payable(msg.sender), 0.01 ether);
        assertEq(address(etherWallet).balance, amount);
    }

    function testCannotSendEtherForInsufficientBalance() public {
        uint256 amount = msg.sender.balance;

        vm.expectRevert("Insufficient balance");
        etherWallet.sendEther(payable(msg.sender), 0.01 ether);

        assertEq(msg.sender.balance, amount);
    }

    function testCannotSendEtherForZeroAddress() public {
        (bool success, ) = address(etherWallet).call{value: 0.01 ether}("");
        assertTrue(success);

        uint256 amount = address(etherWallet).balance;

        vm.expectRevert("Can't send to zero address");
        etherWallet.sendEther(payable(address(0)), 0.01 ether);

        assertEq(address(etherWallet).balance, amount);
    }

    function testCannotSendEtherForZeroValue() public {
        (bool success, ) = address(etherWallet).call{value: 0.01 ether}("");
        assertTrue(success);

        uint256 amount = address(etherWallet).balance;

        vm.expectRevert("Value must be greater than 0");
        etherWallet.sendEther(payable(msg.sender), 0);

        assertEq(address(etherWallet).balance, amount);
    }

    function testWithdraw() public {
        (bool success, ) = address(etherWallet).call{value: 1 ether}("");
        assertTrue(success);

        uint256 amount = address(etherWallet).balance - 0.01 ether;

        etherWallet.withdraw(0.01 ether);

        assertEq(address(etherWallet).balance, amount);
    }

    function testWithdrawAll() public {
        (bool success, ) = address(etherWallet).call{value: 1 ether}("");
        assertTrue(success);

        etherWallet.withdrawAll();

        assertEq(address(etherWallet).balance, 0);
    }
}
