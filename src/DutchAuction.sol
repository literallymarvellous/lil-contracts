// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;
}

contract DutchAuction {
    uint256 private constant DURATION = 7 days;

    IERC721 public immutable token;
    uint256 public immutable tokenId;

    address payable public immutable seller;
    uint256 public immutable startingPrice;
    uint256 public immutable startAt;
    uint256 public immutable expiresAt;
    uint256 public immutable discountRate;

    constructor(
        uint256 _startingPrice,
        uint256 _discountRate,
        address _token,
        uint256 _tokenId
    ) {
        require(
            _startingPrice >= _discountRate * DURATION,
            "Starting price must > discount rate * duration"
        );
        seller = payable(msg.sender);
        startingPrice = _startingPrice;
        discountRate = _discountRate;

        token = IERC721(_token);
        tokenId = _tokenId;

        startAt = block.timestamp;
        expiresAt = startAt + DURATION;
    }

    function getPrice() public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - startAt;
        uint256 discount = discountRate * timeElapsed;
        return startingPrice - discount;
    }

    function buy() external payable {
        require(block.timestamp < expiresAt, "Auction has expired");
        uint256 price = getPrice();
        require(msg.value >= price, "Insufficient ether");

        token.transferFrom(seller, msg.sender, tokenId);
        uint256 refund = msg.value - getPrice();
        if (refund > 0) {
            (bool success, ) = payable(msg.sender).call{value: refund}("");
            require(success, "Refund failed");
        }
        selfdestruct(seller);
    }
}
