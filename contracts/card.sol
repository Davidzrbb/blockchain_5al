// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;



import "./safemath.sol";

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract CardFactory is ERC1155, ERC1155Supply, Ownable {

    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    uint256 public cardIdMax = 9;
    uint256 public nonce = 0;

    event CardIdMaxChanged(uint256 newCardIdMax);

    mapping (uint => mapping(address => uint)) public cardIdToOwnerToAmount;
    mapping (uint => address[]) public cardIdToOwners;

    constructor()
        ERC1155("http://51.38.190.134:1155/cards/{id}.json")
        Ownable(msg.sender)
    {}

    // The following functions are overrides required by Solidity.
    function _update(address _from, address _to, uint256[] memory _ids, uint256[] memory _values)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._update(_from, _to, _ids, _values);
    }

    function _createCard(uint _id) internal {
        _mint(msg.sender, _id, 1, "");

        cardIdToOwnerToAmount[_id][msg.sender] = cardIdToOwnerToAmount[_id][msg.sender].add(1);   

        for(uint i = 0; i < cardIdToOwners[_id].length; i++) {
            if(cardIdToOwners[_id][i] == msg.sender) {
                return;
            }
        }

        cardIdToOwners[_id].push(msg.sender);    
        
    }

    

    function _generateRandomNumberRarity() internal view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.prevrandao)));
        return rand;
    }

    function _generateRandomNumberCardId() internal returns (uint) {
        nonce++;
        uint rand = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce)));
        return rand;
    }

    function _getRarity(uint _rand) internal pure returns (uint) {
        if( _rand % 100 < 20) {
            return 2;
        } else if (_rand % 100 < 50) {
            return 1;
        } else {
            return 0;
        }
    }

    function _getCardId(uint _rand) internal view returns (uint) {
        return (((_rand % (cardIdMax/3)) + 1) * 3) - 2; 
        // each card have 3 rarity so id 1,2 and 3 is for the "first" card, then 4,5 and 6 for the second, so if we want the second, we do 2*3 then -2 to remove 2 rairty and get common rarity)
    }

    /*

        ((5134 % (9/3)) + 1)
        ((5134 % 3) + 1)
        (1 + 1)
        2

        2*3
        6
        6 - 2
        4



    */
    
}