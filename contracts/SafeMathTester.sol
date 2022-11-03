// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SafeMathTester {
    uint8 public bigNumber = 255; // the number is unchecked

    function add() public {
        unchecked { bigNumber = bigNumber + 1; } // wrap around -> go back to 0
    }
}