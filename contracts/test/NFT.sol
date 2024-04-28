// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721 {
    string private baseURI;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory customBaseURI
    ) ERC721(_name, _symbol) {
        baseURI = customBaseURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function safeMint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }
}
