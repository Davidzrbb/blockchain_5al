// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

contract CardHelper is CardFactory {

    function addNewNameAndStats(string memory _name, mapping(string => uint) _stats) external onlyOwner {
        require(cardNameToId[_name] == 0, "This name already exists");
        require(_stats.length == 3, "You need to add 3 stats");

        uint id = idTocardName.length;
        cardNameToId[_name] = id;
        idTocardName[id] = _name;

        cardNameToStats[_name] = _stats;
    }

}