//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

contract NFT is ERC721, ERC721Enumerable, ERC721URIStorage  {
    using Counters for Counters.Counter;
    Counters.Counter  public  _NFTIds;
    Counters.Counter  public  _PSAIds;
    Counters.Counter  public _PPAIds;
    Counters.Counter  public _EquipmentIds;
    Counters.Counter  public _LicenseIds;
    
    mapping (uint => NFTh) Equipments;
    mapping (uint => NFTh) NFTs;
    mapping (uint => NFTh) PSAs;
    mapping (uint => NFTh) PPAs;
    mapping (uint => NFTh) Licenses;
    
    address contractAddress;

     struct NFTh {
        string  CategoryName;
        string  Party1;
        string Party2;
        string  Location;
        string  description;
        string  tokenURI;
        uint8 Amount;
        uint8 CapFee;
        uint8 NFTId;
        uint8  CategoryId;
    }

    constructor(address marketplaceAddress) ERC721("Market Certificate" , "MC") {
        contractAddress = marketplaceAddress;   
    }

    function createNFT(
        string calldata _categoryName,
        string calldata _Party1,
        string calldata _Party2,
        string  calldata _location,
        string  calldata _description,
        string calldata _tokenURI,
        uint8 _Amount,
        uint8 _CapFee
        ) 
        validInput(_categoryName) validInput(_Party1) 
        validInput(_Party2) validInput(_location) 
        validInput(_description) validInput(_tokenURI)
        public returns (uint){
        _NFTIds.increment();
        uint8 newItemId = uint8(_NFTIds.current());

        
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId , _tokenURI);
        _setApprovalForAll(contractAddress, contractAddress, true);
    
        NFTs[newItemId] = NFTh(
            _categoryName,
            _Party1,
            _Party2,
            _location,
            _description,
            _tokenURI,
            _Amount,
            _CapFee,
            newItemId,
            0
        );

        if (keccak256(abi.encodePacked(_categoryName)) == keccak256(abi.encodePacked("PPA"))) {
            _PPAIds.increment();
            uint8 _newItemId = uint8(_PPAIds.current());
            NFTs[newItemId].CategoryId = _newItemId;

        } else if (keccak256(abi.encodePacked(_categoryName)) == keccak256(abi.encodePacked("PSA"))) {
           _PSAIds.increment();
           uint8 _newItemId = uint8(_PSAIds.current());
           NFTs[newItemId].CategoryId = _newItemId;

        } else if (keccak256(abi.encodePacked(_categoryName)) == keccak256(abi.encodePacked("Equipment"))) {
            _EquipmentIds.increment();
            uint8 _newItemId = uint8(_EquipmentIds.current());
            NFTs[newItemId].CategoryId = _newItemId;

        }else if (keccak256(abi.encodePacked(_categoryName)) == keccak256(abi.encodePacked("License"))) {
            _LicenseIds.increment();
            uint8 _newItemId = uint8(_LicenseIds.current());
            NFTs[newItemId].CategoryId = _newItemId; 
        }else {
            console.log("Invalid Certificate code");
        }
           
        console.log (" created NFT of type:", NFTs[newItemId].CategoryName);
        return newItemId;
    }

    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    modifier validInput(string calldata _input){
        require(bytes(_input).length > 0, "enter valid input");
        _;
    }
}