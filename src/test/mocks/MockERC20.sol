// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("Mock ERC", "MER") {
        _mint(msg.sender, 10000e18);
    }
}
