// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BadApprover {
    address immutable contractHacker;
    IERC20 immutable token;

    constructor(address _contractHacker, IERC20 _token) {
        contractHacker = _contractHacker;
        token = _token;
    }

    function approveHacker() external {
        token.approve(contractHacker, 10 ether);
    }
}