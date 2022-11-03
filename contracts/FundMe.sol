// Get funds from users
// Withdraw funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 0.05 * 1e18;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    // Store in byte code instead of storage
    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        // Want to be able to set a minimum fund amount in usd
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didn't send enough");
        funders.push(msg.sender);        
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {        
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        // reset the array
        funders = new address[](0);

        // withdraw the actual funds
        // method 1: transfer
        // msg.sender = address
        // payable(msg.sender) = payable address
        // if transfer fails -> return error
        // payable(msg.sender).transfer(address(this).balance);

        // method 2: send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        // method 3: call
        // lower level command
        // recommended way
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
        revert();
    }

    modifier onlyOwner {
        // require(msg.sender == i_owner, "Sender is not owner!");
        if (msg.sender != i_owner) { revert NotOwner(); }
        _; // Means do the rest of the code
    }

    // What happens if someone sends this contract ETH without calling the fund function

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
