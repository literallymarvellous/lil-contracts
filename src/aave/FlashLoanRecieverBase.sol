// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.12;

import {IFlashLoanReceiver, ILendingPoolAddressesProvider, ILendingPool, IERC20} from "./Interfaces.sol";

abstract contract FlashLoanReceiverBase is IFlashLoanReceiver {
    ILendingPoolAddressesProvider public immutable ADDRESSES_PROVIDER;
    ILendingPool public immutable LENDING_POOL;

    constructor(ILendingPoolAddressesProvider provider) {
        ADDRESSES_PROVIDER = provider;
        LENDING_POOL = ILendingPool(provider.getLendingPool());
    }
}
