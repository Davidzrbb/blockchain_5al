// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

import "./battle.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract BattleHelper is CardHelper, Battle {

    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    event BattleInitiated(address indexed _from, uint indexed _cardId, uint indexed _battleId);
    event BattleSelected(address indexed _from, uint indexed _cardId, uint indexed _battleId, bool _res);
    event BattleDone(address _winner, address _loser, uint indexed _battleId, bool _res);
    event BattleDoneDraw(uint indexed _battleId, bool _res);

    // override openPack
    function openPack() override(CardHelper) public payable {
        super.openPack();
    }

    // override burn
    function burn(address _from, uint256 _id, uint256 _value) override(CardHelper) public {
        super.burn(_from, _id, _value);
    }

    /**
    * @dev Returns an URI for a given token ID
    */
    function tokenURI(uint256 _tokenId) public pure returns (string memory) {
        return string(abi.encodePacked("http://51.38.190.134:1156/api/cards/", Strings.toString(_tokenId)));
    }

    function initBattle(uint _cardId) external payable {

        require(msg.value > 0, "You need to send ether");

        require(_cardId > 0 && _cardId <= cardIdMax);
        require((balanceOf(msg.sender, _cardId) - addressToCardInBattle[msg.sender][_cardId]) > 0, "You don't have enougth of this card available");
        uint256 battleId = _initBattle(_cardId);

        emit BattleInitiated(msg.sender, _cardId, battleId);
    }

    function selectBattle(uint _cardId, uint _battleId, uint[] memory _stats) external payable {
        require(msg.value > 0, "You need to send ether");
        require(_cardId > 0 && _cardId <= cardIdMax);
        require((balanceOf(msg.sender, _cardId) - addressToCardInBattle[msg.sender][_cardId]) > 0, "You don't have enougth of this card available");
        require(_battleId > 0 && _battleId <= battles.length, "This battle doesn't exist");
        require(keccak256(abi.encodePacked(battles[_battleId-1].status)) == keccak256(abi.encodePacked("waitP2")), "This battle is not waiting for a player 2");
        require(_stats.length == 3, "You need to send 3 stats");
        
        bool res = _selectBattle(_cardId, _battleId, _stats);

        if (!res) {
            revert("Something went wrong during the battle selection");
        }

        emit BattleSelected(msg.sender, _cardId, _battleId, res);
    }

    function confirmBattle(uint _battleId, uint[] memory _stats) external {
        require(_battleId > 0 && _battleId <= battles.length, "This battle doesn't exist");
        require(battles[_battleId-1].player1 == msg.sender, "You are not part of this battle");
        require(keccak256(abi.encodePacked(battles[_battleId-1].status)) == keccak256(abi.encodePacked("waitP1")), "This battle is not waiting for a player 1");
        require(_stats.length == 3, "You need to send 3 stats");

        bool res = _confirmBattle(_battleId, _stats);

        if (!res) {
            revert("Something went wrong during the battle confirmation");
        }

        doBattle(_battleId);
        
    }

    function doBattle(uint _battleId) internal {
        require(_battleId > 0 && _battleId <= battles.length, "This battle doesn't exist");
        require(battles[_battleId-1].player1 == msg.sender, "You are not part of this battle");
        require(keccak256(abi.encodePacked(battles[_battleId-1].status)) == keccak256(abi.encodePacked("confirmed")), "This battle is not confirmed");

        bool res = _doBattle(_battleId);

        if (!res) {
            revert("Something went wrong during the battle");
        }

        BattleData memory battle = battles[_battleId-1];

        if(battle.draw) {
            emit BattleDoneDraw(_battleId, res);
            return;
        }

        if (battle.winner == address(0)) {
            revert("Something went wrong during the battle (not draw and no winner)");
        }

        emit BattleDone(battle.winner, battle.loser, _battleId, res);

    }

    function getBattle(uint _battleId) external view returns (BattleData memory) {
        require(_battleId > 0 && _battleId <= battles.length, "This battle doesn't exist");
        return battles[_battleId-1];
    }

    function getAllBattle() external view returns (BattleData[] memory) {
        return battles;
    }

    function getAllBattleUser() external view returns (BattleData[] memory) {
        return _getAllBattleUser();
    }

    function cancelBattle(uint _battleId) external {
        require(_battleId > 0 && _battleId <= battles.length, "This battle doesn't exist");
        require(battles[_battleId-1].player1 == msg.sender, "You are not part of this battle");
        require(keccak256(abi.encodePacked(battles[_battleId-1].status)) == keccak256(abi.encodePacked("waitP1")) || keccak256(abi.encodePacked(battles[_battleId-1].status)) == keccak256(abi.encodePacked("waitP2")), "Cant cancel a battle that is not waiting for a player");

        bool res = _cancelBattle(_battleId);

        if (!res) {
            revert("Something went wrong during the battle cancellation");
        }
    }
}