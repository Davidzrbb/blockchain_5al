
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

import "./cardhelper.sol";

contract Battle is CardHelper {

    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    mapping(address => mapping(uint => uint)) public addressToCardInBattle; // address => cardId => number of that card in battle

    BattleData[] public battles;

    struct BattleData {
        address player1;
        address player2;
        uint cardIdPlayer1;
        uint cardIdPlayer2;
        uint amountPlayer1;
        uint amountPlayer2;
        uint[] statsPlayer1;
        uint[] statsPlayer2;
        address winner;
        address loser;
        bool draw;
        string status;
    }

    function _initBattle(uint _cardId) internal returns (uint) {
        addressToCardInBattle[msg.sender][_cardId] = addressToCardInBattle[msg.sender][_cardId].add(1);
        BattleData memory battle = BattleData(msg.sender, address(0), _cardId, 0, msg.value, 0, new uint[](0), new uint[](0), address(0), address(0), false, "waitP2");

        battles.push(battle);

        return battles.length;
    }

    function _selectBattle(uint _cardId, uint _battleId, uint[] memory _stats) internal returns (bool){
        addressToCardInBattle[msg.sender][_cardId] = addressToCardInBattle[msg.sender][_cardId].add(1);
        BattleData memory battle = battles[_battleId-1];
        battle.player2 = msg.sender;
        battle.cardIdPlayer2 = _cardId;
        battle.amountPlayer2 = msg.value;
        battle.statsPlayer2 = _stats;
        battle.status = "waitP1";

        battles[_battleId-1] = battle;
        return true;
    }

    function _confirmBattle(uint _battleId, uint[] memory _stats) internal returns (bool) {
        BattleData memory battle = battles[_battleId-1];

        battle.statsPlayer1 = _stats;

        battle.status = "confirmed";

        battles[_battleId-1] = battle;

        return true;
    }

    function _doBattle(uint _battleId) internal returns (bool) {
        BattleData memory battle = battles[_battleId-1];

        uint[] memory statsPlayer1 = battle.statsPlayer1;
        uint[] memory statsPlayer2 = battle.statsPlayer2;
        uint cardIdPlayer1 = battle.cardIdPlayer1;
        uint cardIdPlayer2 = battle.cardIdPlayer2;
        uint amountPlayer1 = battle.amountPlayer1;
        uint amountPlayer2 = battle.amountPlayer2;
        uint roundWinPlayer1 = 0;
        uint roundWinPlayer2 = 0;
        uint cardIdWinner = 0;

        for(uint i = 0; i < 3; i++) {
            if(statsPlayer1[i] > statsPlayer2[i]) {
                roundWinPlayer1++;
            } else if(statsPlayer1[i] < statsPlayer2[i]) {
                roundWinPlayer2++;
            }
        }

        if(roundWinPlayer1 > roundWinPlayer2){
            battle.winner = battle.player1;
            cardIdWinner = cardIdPlayer1;
            battle.loser = battle.player2; 
        } else if(roundWinPlayer1 < roundWinPlayer2) {
            battle.winner = battle.player2;
            cardIdWinner = cardIdPlayer2;
            battle.loser = battle.player1;
        } else {
            battle.winner = address(0);
            battle.loser = address(0);
            battle.draw = true;
            battle.status = "draw";
            payable(battle.player1).transfer(amountPlayer1);
            payable(battle.player2).transfer(amountPlayer2);
            battles[_battleId-1] = battle;
            addressToCardInBattle[battle.player1][battle.cardIdPlayer1] = addressToCardInBattle[battle.player1][battle.cardIdPlayer1].sub(1);
            addressToCardInBattle[battle.player2][battle.cardIdPlayer2] = addressToCardInBattle[battle.player2][battle.cardIdPlayer2].sub(1);
            return true;
        }

        battle.status = "done";
        battles[_battleId-1] = battle;

        addressToCardInBattle[battle.player1][battle.cardIdPlayer1] = addressToCardInBattle[battle.player1][battle.cardIdPlayer1].sub(1);
        addressToCardInBattle[battle.player2][battle.cardIdPlayer2] = addressToCardInBattle[battle.player2][battle.cardIdPlayer2].sub(1);

        uint256 totalAmount = amountPlayer1.add(amountPlayer2);

        return _doRoyalty(_battleId, totalAmount, cardIdWinner);
    }

    function _doRoyalty(uint _battleId, uint _totalAmount, uint _cardIdWinner) internal returns (bool){
       
        BattleData memory battle = battles[_battleId-1];

        // 10% goes to royalty
        uint256 royalty = _totalAmount.mul(10).div(100);

        uint royaltyCardAmount = 0;
        for(uint i = 0; i < cardIdToOwners[_cardIdWinner].length; i++){
            uint amountOfCardId = cardIdToOwnerToAmount[_cardIdWinner][cardIdToOwners[_cardIdWinner][i]];
            royaltyCardAmount = royaltyCardAmount.add(amountOfCardId);
        }

        
        if(royaltyCardAmount != 0){
            uint royaltyPerCard = royalty.div(royaltyCardAmount);

            for(uint i = 0; i < cardIdToOwners[_cardIdWinner].length; i++){
                uint amountOfCardId = cardIdToOwnerToAmount[_cardIdWinner][cardIdToOwners[_cardIdWinner][i]];
                uint royaltyAmount = royaltyPerCard.mul(amountOfCardId);
                payable(cardIdToOwners[_cardIdWinner][i]).transfer(royaltyAmount);
            }
        }

        
        // 90% goes to winner
        uint256 winnerAmount = _totalAmount.sub(royalty);
        payable(battle.winner).transfer(winnerAmount);

        battles[_battleId-1] = battle;

        return true;

    }

    function _cancelBattle(uint _battleId) internal returns (bool) {
        BattleData memory battle = battles[_battleId-1];

        payable(battle.player1).transfer(battle.amountPlayer1);
        addressToCardInBattle[battle.player1][battle.cardIdPlayer1] = addressToCardInBattle[battle.player1][battle.cardIdPlayer1].sub(1);
        payable(battle.player2).transfer(battle.amountPlayer2);
        addressToCardInBattle[battle.player2][battle.cardIdPlayer2] = addressToCardInBattle[battle.player2][battle.cardIdPlayer2].sub(1);

        battle.status = "canceled";

        battles[_battleId-1] = battle;

        return true;
    }

    function _getAllBattleUser() internal view returns (BattleData[] memory) {
        BattleData[] memory battlesUser = new BattleData[](battles.length);
        uint counter = 0;
        for(uint i = 0; i < battles.length; i++) {
            if(battles[i].player1 == msg.sender || battles[i].player2 == msg.sender) {
                battlesUser[counter] = battles[i];
                counter++;
            }
        }
        return battlesUser;
    }


}