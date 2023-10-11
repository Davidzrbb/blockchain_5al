// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;



import "./ownable.sol";
import "./safemath.sol";

contract CardFactory is ERC721, Ownable {

    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    mapping(uint => address) public cardToOwner;
    mapping(address => uint) ownerCardCount;

    mapping(string => uint) public cardNameToId;
    mapping(uint => string) public idTocardName;

    mapping(string => mapping(string => uint)) public cardNameToStats;
    

    event NewCard(uint cardId, string name, string rarity, mapping(string => uint) stats);
    
    struct Card {
        string name;
        mapping(string => uint) stats;
        string rarity;
    }

    Card[] public cards;

    uint256 private _nextTokenId;

    constructor(address initialOwner)
        ERC721("Card", "CRD")
        Ownable(initialOwner)
    {}

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }

    function _createCard(string memory _name, string memory _rarity, mapping(string => uint) _stats) internal {
        uint id = cards.push(Card(_name, _rarity, _stats)) - 1;
        cardToOwner[id] = msg.sender;
        ownerCardCount[msg.sender] = ownerCardCount[msg.sender].add(1);
        emit NewCard(id, _name, _rarity, _stats);
    }

    function openPack() external {
        require(msg.value == 0.01 ether, "You need to pay 0.01 ether to open a pack");
        
        uint rand = _generateRandomNumber();
        string memory rarity = _getRarity(rand);
        string name = idTocardName[rand % idTocardName.length];
        mapping(string => uint) stats = cardNameToStats[name];

        _createCard(name, rarity, stats);

    }

    function _generateRandomNumber() internal view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.difficulty)));
        return rand;
    }

    function _getRarity(uint _rand) internal pure returns (string memory) {
        if( _rand % 100 <= 1) {
            return "legendary";
        } else if (_rand % 100 <= 21) {
            return "rare";
        } else {
            return "common";
        }
    }


    
}