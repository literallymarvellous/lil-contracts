// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import {Vm} from "../../lib/forge-std/src/Vm.sol";
import "../../lib/ds-test/src/test.sol";
import {EtherWallet} from "../EtherWallet.sol";

contract etherWalletTest is DSTest {
    Vm internal constant vm = Vm(HEVM_ADDRESS);
    EtherWallet internal etherWallet;

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

        emit log_named_uint("amount :", address(etherWallet).balance);
    }

    function testCanSendEther() public {
        (bool success, ) = address(etherWallet).call{value: 1 ether}("");
        assertTrue(success);

        emit log_named_uint("amount :", address(etherWallet).balance);

        uint256 amount = etherWallet.getBalance() - 0.01 ether;

        etherWallet.sendEther(payable(msg.sender), 0.01 ether);
        assertEq(address(etherWallet).balance, amount);

        emit log_named_uint("amount :", address(etherWallet).balance);
    }
}
