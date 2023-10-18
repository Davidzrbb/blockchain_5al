// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

import "./card.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract CardHelper is CardFactory {

    function changeCardIdMax(uint256 _cardIdMax) external onlyOwner {
        
        cardIdMax = _cardIdMax;
        emit CardIdMaxChanged(_cardIdMax);
    }

    function getCardIdMax() external view returns (uint256) {
        return cardIdMax;
    }

    function setURI(string memory _newuri) external onlyOwner {
        _setURI(_newuri);
    }

    function mint(address _account, uint256 _id, uint256 _amount, bytes memory _data)
        external
        onlyOwner
    {
        _mint(_account, _id, _amount, _data);
    }

    function mintBatch(address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data)
        external
        onlyOwner
    {
        _mintBatch(_to, _ids, _amounts, _data);
    }

    function burn(address _from, uint256 _id, uint256 _value) virtual public {
        _burn(_from, _id, _value);
    }

    function getAllBalance(address _from) external view returns (uint[] memory) {
        uint[] memory idToCount = new uint[](cardIdMax);
        for(uint i = 1; i <= cardIdMax; i++) {
            if(balanceOf(_from, i) > 0) {
                idToCount[i-1] = balanceOf(_from, i);
            }
        }
        return idToCount;
        
    }

    function getBalanceOf(uint _id, address _from) external view returns (uint) {
        
        
        return balanceOf(_from, _id);
        
    }

    function openPack() virtual public payable {
        require(msg.value == 0.000001 ether, "You need to pay 0.000001 ether to open a pack");
        

        uint randRarity = _generateRandomNumberRarity();
        uint rarity = _getRarity(randRarity);
        uint randCardId = _generateRandomNumberCardId();
        uint256 cardId = _getCardId(randCardId);

        uint id = cardId + rarity;

        _createCard(id);
    }

}