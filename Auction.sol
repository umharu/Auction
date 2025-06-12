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
 * - Partial withdrawal capability
 * - Emergency ETH recovery
 */
contract Auction {
    // Structs
    struct Bid {
        uint256 amount;
        uint256 timestamp;
        bool isActive;
    }
    
    // State variables
    address public owner;
    address public highestBidder;
    uint256 public highestBid;
    uint256 public auctionEndTime;
    bool public auctionEnded;
    
    // Constants
    uint256 private constant MIN_INCREASE = 5; // 5% minimum increase
    uint256 private constant FEE = 2; // 2% fee
    uint256 private constant EXTENSION = 10 minutes;
    uint256 private constant EXTENSION_WINDOW = 10 minutes;
    
    // Bid tracking
    mapping(address => Bid) public bids;
    address[] public bidders;
    
    // Events
    event NewBid(address indexed bidder, uint256 amount);
    event AuctionEnded(address indexed winner, uint256 amount);
    event RefundIssued(address indexed bidder, uint256 amount);
    event PartialWithdrawal(address indexed bidder, uint256 amount);
    event EmergencyWithdrawal(address indexed to, uint256 amount);
    
    /**
     * @dev Constructor initializes the auction with a specified duration
     * @param _durationInMinutes The duration of the auction in minutes
     */
    constructor(uint256 _durationInMinutes) {
        require(_durationInMinutes > 0, "Invalid duration");
        owner = msg.sender;
        auctionEndTime = block.timestamp + (_durationInMinutes * 1 minutes);
        auctionEnded = false;
    }
    
    /**
     * @dev Places a bid in the auction
     * @notice Bids must be at least 5% higher than current highest bid
     * @notice Extends auction time if bid is placed in last 10 minutes
     */
    function placeBid() external payable {
        // Early require statements
        require(block.timestamp <= auctionEndTime, "Auction ended");
        require(!auctionEnded, "Auction ended");
        require(msg.value > 0, "Zero bid");
        
        // Calculate minimum bid once
        uint256 minBid = highestBid > 0 ? 
            highestBid + (highestBid * MIN_INCREASE / 100) : 0;
        
        if (minBid > 0) {
            require(msg.value >= minBid, "Bid too low");
        }
        
        // Check time extension
        if (auctionEndTime - block.timestamp <= EXTENSION_WINDOW) {
            auctionEndTime = block.timestamp + EXTENSION;
        }
        
        // Update bid tracking
        if (bids[msg.sender].amount == 0) {
            bidders.push(msg.sender);
        }
        bids[msg.sender] = Bid({
            amount: bids[msg.sender].amount + msg.value,
            timestamp: block.timestamp,
            isActive: true
        });
        
        // Update highest bid
        highestBid = msg.value;
        highestBidder = msg.sender;
        
        emit NewBid(msg.sender, msg.value);
    }
    
    /**
     * @dev Ends the auction and distributes funds
     * @notice Only callable by owner after auction end time
     */
    function endAuction() external {
        require(msg.sender == owner, "Not owner");
        require(!auctionEnded, "Already ended");
        require(block.timestamp >= auctionEndTime, "Not ended");
        
        auctionEnded = true;
        
        // Calculate amounts once
        uint256 fee = (highestBid * FEE) / 100;
        uint256 winnerAmount = highestBid - fee;
        
        // Transfer funds
        payable(highestBidder).transfer(winnerAmount);
        payable(owner).transfer(fee);
        
        emit AuctionEnded(highestBidder, highestBid);
    }
    
    /**
     * @dev Allows bidders to withdraw excess funds
     * @param _amount Amount to withdraw
     */
    function withdrawPartial(uint256 _amount) external {
        require(_amount > 0, "Zero amount");
        require(_amount <= bids[msg.sender].amount, "Amount too high");
        require(msg.sender != highestBidder || auctionEnded, "Winner active");
        
        bids[msg.sender].amount -= _amount;
        payable(msg.sender).transfer(_amount);
        
        emit PartialWithdrawal(msg.sender, _amount);
    }
    
    /**
     * @dev Allows non-winning bidders to get full refund
     */
    function getRefund() external {
        require(auctionEnded, "Not ended");
        require(msg.sender != highestBidder, "Winner");
        require(bids[msg.sender].amount > 0, "No bid");
        
        uint256 refundAmount = bids[msg.sender].amount;
        bids[msg.sender].amount = 0;
        bids[msg.sender].isActive = false;
        
        payable(msg.sender).transfer(refundAmount);
        emit RefundIssued(msg.sender, refundAmount);
    }
    
    /**
     * @dev Returns all bidders and their bid amounts
     * @return Array of bidder addresses
     * @return Array of corresponding bid amounts
     */
    function getBids() external view returns (address[] memory, uint256[] memory) {
        uint256 length = bidders.length;
        uint256[] memory amounts = new uint256[](length);
        
        // Use dirty variable
        uint256 i;
        for (i = 0; i < length; i++) {
            amounts[i] = bids[bidders[i]].amount;
        }
        return (bidders, amounts);
    }
    
    /**
     * @dev Returns remaining auction time
     * @return Time remaining in seconds
     */
    function getTimeLeft() external view returns (uint256) {
        return block.timestamp >= auctionEndTime ? 0 : auctionEndTime - block.timestamp;
    }
    
    /**
     * @dev Emergency function to recover ETH
     * @notice Only callable by owner
     * @param _to Address to send ETH to
     * @param _amount Amount to send
     */
    function emergencyWithdraw(address payable _to, uint256 _amount) external {
        require(msg.sender == owner, "Not owner");
        require(_to != address(0), "Zero address");
        require(_amount > 0, "Zero amount");
        require(_amount <= address(this).balance, "Amount too high");
        
        _to.transfer(_amount);
        emit EmergencyWithdrawal(_to, _amount);
    }
    
    /**
     * @dev Prevents direct ETH transfers
     */
    receive() external payable {
        revert("Use placeBid()");
    }
}
