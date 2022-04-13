// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;
}

contract EnglishAuction {
    event Bid(address indexed bidder, uint256 amount);

    struct Bidder {
        address bidder;
        uint256 bid;
    }

    bool public started;
    bool public ended;

    uint256 private constant DURATION = 1 minutes;

    IERC721 public immutable token;
    uint256 public immutable tokenId;

    address payable public immutable seller;
    uint256 public immutable askingPrice;
    uint256 public expiresAt;

    mapping(address => uint256) bids;
    Bidder public winner;

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
        askingPrice = _askingPrice;

        token = IERC721(_token);
        tokenId = _tokenId;
    }

    function startBid() external onlySeller {
        require(!started, "Auction has already started");

        started = true;
        expiresAt = uint256(block.timestamp + DURATION);
    }

    function bid() external payable {
        require(msg.value >= askingPrice, "Below asking price");
        require(block.timestamp < expiresAt, "Auction has expired");

        Bidder memory bidder = Bidder(msg.sender, msg.value);

        if (bidder.bid > winner.bid) {
            winner = bidder;
        }

        emit Bid(msg.sender, msg.value);
    }

    function transferOwnership() external onlySeller {
        require(block.timestamp > expiresAt, "Auction hasn't expired");
    }
}
