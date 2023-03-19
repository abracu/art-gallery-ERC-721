// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract ArtGallery is ERC721, Ownable {

    // ==============================================
    // Initial Statement
    // ==============================================

    // Smart Contract Constructor
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    // NFT token counter
    uint256 COUNTER;

    // Price del NFT token (price of the artwork)
    uint public fee = 5 ether;

    // Data structure with the properties of the artwork
    struct Art {
        string name;
        uint256 id;
        uint256 dna;
        uint8 level;
        uint8 rarity;
    }

    // Storage structure for keeping artworks
    Art[] public art_works;

    // Declaration of an event
    event NewArtWork (address indexed owner, uint256 id, uint256 dna);

    // ==============================================
    // Helper Functions
    // ==============================================

    // Function to generate a random number (required for NFT token properties)
    function _createRandomNum(uint256 _mod) internal view returns (uint256) {
        bytes32 has_randomNum = keccak256(abi.encodePacked(block.timestamp, msg.sender));
        uint256 randomNum = uint256(has_randomNum);
        return randomNum % _mod;
    }

    // NFT Token Creation (Artwork)
    function _createArtWork(string memory _name) internal {
        uint8 randRarity = uint8(_createRandomNum(1000));
        uint256 randDna = _createRandomNum(10**16);
        COUNTER++;
        Art memory newArtWork = Art(_name, COUNTER, randDna, 1, randRarity);
        art_works.push(newArtWork);
        _safeMint(msg.sender, COUNTER);
        emit NewArtWork(msg.sender, COUNTER, randDna);
    }

    // NFT Token Price Update
    function updateFee(uint _newFee) public onlyOwner {
        fee = _newFee;
    }

    // Visualize the balance of the Smart Contract (Ethers)
    function infoSmartContract() public view returns (address, uint256) {
        address SC_address = address(this);
        uint256 SC_money = address(this).balance / 10**18;
        return (SC_address, SC_money);
    }

    // Obtener all creted NFT tokens (Artworks)
    function getArtWorks() public view returns (Art[] memory) {
        return art_works;
    }

    // Obtaining a user's NFT tokens (Artworks)
    function getArtWorksByOwner(address _owner) public view returns (Art[] memory) {
        uint256 balance = balanceOf(_owner);
        Art[] memory result = new Art[](balance);
        uint256 counter_owner = 0;
        for (uint256 i = 0; i < art_works.length; i++) {
            if (ownerOf(i) == _owner) {
                result[counter_owner] = art_works[i];
                counter_owner++;
            }
        }
        return result;
    }

    // ==============================================
    // NFT Token Development
    // ==============================================

    // NFT Token Payment
    function createRandomArtWork(string memory _name) public payable {
        require(msg.value == fee, "You must pay the correct amount");
        _createArtWork(_name);
    }

    // Extraction of ether from the Smart Contract to the owner's wallet
    function withdraw() external payable onlyOwner {
        address payable _owner = payable(owner());
        _owner.transfer(address(this).balance);
    }

    // Level up NFT token (Artwork)
    function levelUp(uint256 _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender, "You must be the owner of the token");
        art_works[_tokenId].level++;
    }
}