# Smart Contract Auction System

Contract Address: `0xaF4ECFA27Fbfa25594Bcd7E43CF4e0Ab46F44ed4`
Verified at: [Sepolia Etherscan](https://sepolia.etherscan.io/address/0xaF4ECFA27Fbfa25594Bcd7E43CF4e0Ab46F44ed4)

A secure and efficient auction system implemented as a Solidity smart contract. This system provides a transparent and automated way to conduct auctions with automatic time extensions and bid management.

## Features

- **Automatic Time Extension**: Auctions automatically extend by 10 minutes if a bid is placed in the last 10 minutes
- **Minimum Bid Increase**: Requires bids to be at least 5% higher than the current highest bid
- **Fee System**: Implements a 2% fee on winning bids and refunds
- **Bid Management**:
  - Partial withdrawal capability for excess funds
  - Full refund system for non-winning bidders
  - Batch refund functionality for all users
  - Bid history tracking with timestamps
- **Security Features**:
  - Emergency ETH recovery function
  - Protected direct ETH transfers
  - Comprehensive input validation

## Contract Structure

### State Variables
- `owner`: Contract owner address
- `highestBidder`: Current highest bidder
- `highestBid`: Current highest bid amount
- `auctionEndTime`: Timestamp when auction ends
- `auctionEnded`: Boolean flag for auction status

### Bid Struct
```solidity
struct Bid {
    uint256 amount;    // Total bid amount
    uint256 timestamp; // When bid was last updated
    bool isActive;     // Whether bid is still active
}
```

### Constants
- `MIN_INCREASE`: 5% minimum bid increase
- `FEE`: 2% fee on winning bid
- `EXTENSION`: 10 minutes extension time
- `EXTENSION_WINDOW`: 10 minutes window for extension

## Functions

### Core Functions
- `constructor(uint256 _durationInMinutes)`: Initializes auction with duration
- `placeBid()`: Places a new bid (payable)
- `endAuction()`: Ends auction and distributes funds
- `getRefund()`: Allows non-winning bidders to get refund
- `withdrawPartial(uint256 _amount)`: Allows partial withdrawal of excess funds
- `refundAllUsers()`: Refunds all non-winning bidders with 2% fee

### View Functions
- `getBids()`: Returns all bidders and their bid amounts
- `getTimeLeft()`: Returns remaining auction time

### Emergency Functions
- `emergencyWithdraw(address payable _to, uint256 _amount)`: Emergency ETH recovery

## Events
- `NewBid`: Emitted when a new bid is placed
- `AuctionEnded`: Emitted when auction ends
- `RefundIssued`: Emitted when refund is processed
- `PartialWithdrawal`: Emitted when partial withdrawal occurs
- `EmergencyWithdrawal`: Emitted when emergency withdrawal occurs

## Usage

1. Deploy the contract with desired auction duration
2. Bidders can place bids using `placeBid()`
3. Auction automatically extends if bids are placed in last 10 minutes
4. Owner can end auction after end time
5. Non-winning bidders can get refunds
6. Bidders can withdraw excess funds partially

## Security Considerations

- All external functions include input validation
- Protected against direct ETH transfers
- Emergency withdrawal function for contract owner
- Bid tracking with timestamps for audit trail
- Active status tracking for refunded bids

## Gas Optimization

- Uses constants for magic numbers
- Optimized storage reads
- Efficient loop implementations
- Early require statements
- Single calculation of derived values

## License

MIT License 