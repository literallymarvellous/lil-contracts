// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import {FlashLoanReceiverBase} from "./aave/FlashLoanRecieverBase.sol";
import {IERC20, ILendingPoolAddressesProvider} from "./aave/Interfaces.sol";

contract AaveV2FlashLoan is FlashLoanReceiverBase {
    constructor(ILendingPoolAddressesProvider _addressProvider)
        FlashLoanReceiverBase(_addressProvider)
    {}

    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        // This contract now has the funds requested.
        // Your logic goes here

        // At the end of your logic above, this contract owes
        // the flashloaned amounts + premiums.
        // Therefore ensure your contract has enough to repay
        // these amounts.

        // Approve the LendingPool contract allowance to *pull* the owed amount
        for (uint256 i = 0; i < assets.length; i++) {
            uint256 amountOwing = amounts[i] + premiums[i];
            IERC20(assets[i]).approve(address(LENDING_POOL), amountOwing);
        }

        return true;
    }

    function myFlashLoanCall() public {
        address receiverAddress = 0xcF4AbEE5eCe1979C139A3837a7aCE130c782863e;

        address[] memory assets = new address[](1);
        assets[0] = 0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD; // Kovan DAI

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 1 ether;

        // 0 = no debt, 1 = stable, 2 = variable
        uint256[] memory modes = new uint256[](1);
        modes[0] = 0;

        address onBehalfOf = 0xcF4AbEE5eCe1979C139A3837a7aCE130c782863e;
        bytes memory params = "";
        uint16 referralCode = 0;

        LENDING_POOL.flashLoan(
            receiverAddress,
            assets,
            amounts,
            modes,
            onBehalfOf,
            params,
            referralCode
        );
    }
}
