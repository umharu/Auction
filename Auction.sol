// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Auction
 * @dev A smart contract for managing an auction system with automatic time extension
 * @notice This contract implements a secure auction system with the following features:
 * - Minimum 5% bid increase requirement
 * - 10-minute extension for bids in last 10 minutes
 * - 2% fee on winning bid
 * - Refund system for non-winning bidders
 */
contract Auction {
    address public owner;
    address public highestBidder;
    uint256 public highestBid;
    uint256 public auctionEndTime;
    bool public auctionEnded;
    
    
    mapping(address => uint256) public bids;
    address[] public bidders;
    
    // Events
    event NewBid(address bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);
    event RefundIssued(address bidder, uint256 amount);
    
    constructor(uint256 _durationInMinutes) {
        owner = msg.sender;
        auctionEndTime = block.timestamp + (_durationInMinutes * 1 minutes);
        auctionEnded = false;
    }
    
    // Place a bid
    function placeBid() external payable {
        require(block.timestamp <= auctionEndTime, "Auction has ended");
        require(!auctionEnded, "Auction has ended");
        require(msg.value > 0, "Bid must be greater than 0");
        
        
        if (highestBid > 0) {
            require(msg.value >= highestBid * 105 / 100, "Bid must be 5% higher");
        }
        
        
        if (auctionEndTime - block.timestamp <= 10 minutes) {
            auctionEndTime = block.timestamp + 10 minutes;
        }
        
        
        if (bids[msg.sender] == 0) {
            bidders.push(msg.sender);
        }
        bids[msg.sender] += msg.value;
        
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        
        emit NewBid(msg.sender, msg.value);
    }
    
    
    function endAuction() external {
        require(msg.sender == owner, "Only owner can end auction");
        require(!auctionEnded, "Auction already ended");
        require(block.timestamp >= auctionEndTime, "Auction has not ended");
        
        auctionEnded = true;
        
        
        uint256 fee = (highestBid * 2) / 100;
        uint256 winnerAmount = highestBid - fee;
        
        
        payable(highestBidder).transfer(winnerAmount);
        payable(owner).transfer(fee);
        
        emit AuctionEnded(highestBidder, highestBid);
    }
    
    
    function getRefund() external {
        require(auctionEnded, "Auction not ended");
        require(msg.sender != highestBidder, "Winner cannot get refund");
        require(bids[msg.sender] > 0, "No bid to refund");
        
        uint256 refundAmount = bids[msg.sender];
        bids[msg.sender] = 0;
        
        payable(msg.sender).transfer(refundAmount);
        emit RefundIssued(msg.sender, refundAmount);
    }
    
    
    function getBids() external view returns (address[] memory, uint256[] memory) {
        uint256[] memory amounts = new uint256[](bidders.length);
        for (uint i = 0; i < bidders.length; i++) {
            amounts[i] = bids[bidders[i]];
        }
        return (bidders, amounts);
    }
    
    function getTimeLeft() external view returns (uint256) {
        if (block.timestamp >= auctionEndTime) return 0;
        return auctionEndTime - block.timestamp;
    }
    
    
    receive() external payable {
        revert("Use placeBid() to place a bid");
    }
}
