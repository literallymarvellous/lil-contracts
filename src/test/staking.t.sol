// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import {Vm} from "../../lib/forge-std/src/Vm.sol";
import "../../lib/ds-test/src/test.sol";
import {Staking} from "../Staking.sol";
import "./mocks/MockERC20.sol";

contract stakingTest is DSTest {
    Vm internal constant vm = Vm(HEVM_ADDRESS);
    Staking internal stakeContract;
    ERC20 public token;

    function setUp() public {
        token = new MockERC20();
        stakeContract = new Staking(token);
        stakeContract.addAllowedTokens(token);
    }

    // function testStakingTokens() public {
    //     token.approve(address(stakeContract), 1 ether);
    //     stakeContract.stake(0.01 ether, token);
    //     assertEq(
    //         stakeContract.stakingBalances(token, address(this)),
    //         0.01 ether
    //     );
    // }

    // fuzz test
    function testStakingTokens(uint32 amount) public {
        emit log_uint(token.balanceOf(address(this)));
        token.approve(address(stakeContract), amount);
        stakeContract.stake(amount, token);
        assertEq(stakeContract.stakingBalances(token, address(this)), amount);
    }
}
