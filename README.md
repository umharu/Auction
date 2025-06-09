# Auction Smart Contract

A simple auction smart contract that implements basic auction functionality with automatic time extension.

## Features

- Place bids with 5% minimum increase requirement
- Automatic 10-minute extension for bids in last 10 minutes
- 2% fee on winning bid
- Refund system for non-winning bidders

## Contract Details

### State Variables
- `owner`: Contract creator address
- `highestBidder`: Current highest bidder address
- `highestBid`: Current highest bid amount
- `auctionEndTime`: When the auction ends
- `auctionEnded`: Auction status flag
- `bids`: Mapping of bidder addresses to their bid amounts
- `bidders`: Array of all bidder addresses

### Main Functions

#### placeBid()
```solidity
function placeBid() external payable
```
- Places a new bid
- Requirements:
  - Auction must be active
  - Bid must be > 0
  - Must be 5% higher than current highest bid (if not first bid)
- Automatically extends auction by 10 minutes if bid is placed in last 10 minutes
- Emits `NewBid` event

#### endAuction()
```solidity
function endAuction() external
```
- Ends the auction
- Requirements:
  - Only callable by owner
  - Auction must not be ended
  - Current time must be past auction end time
- Distributes funds:
  - 98% to winner
  - 2% to owner
- Emits `AuctionEnded` event

#### getRefund()
```solidity
function getRefund() external
```
- Allows non-winning bidders to get their deposits back
- Requirements:
  - Auction must be ended
  - Caller must not be the winner
  - Caller must have a bid to refund
- Emits `RefundIssued` event

#### getBids()
```solidity
function getBids() external view returns (address[] memory, uint256[] memory)
```
- Returns arrays of all bidders and their bid amounts

#### getTimeLeft()
```solidity
function getTimeLeft() external view returns (uint256)
```
- Returns remaining auction time in seconds

## Events
- `NewBid`: Emitted when a new bid is placed
- `AuctionEnded`: Emitted when auction ends
- `RefundIssued`: Emitted when a refund is processed

## Testing on Remix

1. Deploy:
   - Set duration in minutes (e.g., 60 for 1 hour)
   - Deployer becomes owner

2. Place Bids:
   - First bid: Any amount > 0
   - Next bids: Must be 5% higher
   - Example: 1 ETH → 1.05 ETH → 1.1025 ETH

3. End Auction:
   - Wait for time to expire
   - Call `endAuction` as owner
   - Winner gets 98% of highest bid
   - Owner gets 2% fee

4. Get Refunds:
   - Non-winners can call `getRefund`
   - Winner cannot get refund 