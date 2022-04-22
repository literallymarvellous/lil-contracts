// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import {IERC721} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC721.sol";

contract EnglishAuction {
    event Bid(address indexed bidder, uint256 amount);
    event Withdraw(address indexed bidder, uint256 amount);
    event End(address winner, uint256 amount);

    // struct Bidder {
    //     address bidder;
    //     uint256 bid;
    // }

    bool public started;
    bool public ended;

    uint256 private constant DURATION = 10 minutes;

    IERC721 public immutable token;
    uint256 public immutable tokenId;

    address payable public immutable seller;
    uint256 public expiresAt;

    uint256 public highestBid;
    mapping(address => uint256) bids;
    address public highestBidder;

    receive() external payable {}

    modifier onlySeller() {
        require(msg.sender == seller, "Only seller can call this function");
        _;
    }

    constructor(
        uint256 _askingPrice,
        address _token,
        uint256 _tokenId
    ) {
        require(
            _askingPrice > 0,
            "Starting price must > discount rate * duration"
        );
        seller = payable(msg.sender);
        highestBid = _askingPrice;

        token = IERC721(_token);
        tokenId = _tokenId;
    }

    function startBid() external onlySeller {
        require(!started, "Auction has already started");

        started = true;
        expiresAt = uint256(block.timestamp + DURATION);
    }

    function bid() external payable {
        require(started, "Not started yet");
        require(msg.value > highestBid, "Below asking price");
        require(block.timestamp < expiresAt, "Auction has expired");

        if (highestBidder != address(0)) {
            bids[highestBidder] = highestBid;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;

        emit Bid(msg.sender, msg.value);
    }

    function end() external onlySeller {
        require(started, "Not started yet");
        require(block.timestamp >= expiresAt, "Auction hasn't expired");
        require(!ended, "ended");

        ended = true;

        if (highestBidder != address(0)) {
            token.safeTransferFrom(address(this), highestBidder, tokenId);
            seller.transfer(highestBid);
        } else {
            token.safeTransferFrom(address(this), seller, tokenId);
        }

        emit End(highestBidder, highestBid);
    }
}
