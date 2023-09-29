// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;
import "hardhat/console.sol";

contract greet {
    uint256 amountOfGreetings = 1;


    function greetings() public {
        amountOfGreetings +=1;
    }

    function getAmountOfGreetings() public view returns (uint256) {
        return amountOfGreetings;
    }
}
