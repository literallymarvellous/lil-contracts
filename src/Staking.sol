// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/// @title Staker
/// @author Ahiara Ikechukwu
/// @notice Stake erc20 tokens and recive yield after a period
contract Staking is Ownable, ReentrancyGuard {
    mapping(ERC20 => mapping(address => uint256)) public stakingBalances;
    mapping(ERC20 => bool) public allowedTokens;
    mapping(address => uint256) public uniqueTokensStaked;
    mapping(address => ERC20[]) public tokensStaked;
    mapping(ERC20 => address) public tokenPricefeed;
    uint256 public constant THRESHOLD = 1 ether;
    address[] public stakers;
    ERC20 public dappToken;

    event Stake(ERC20 token, uint256 amount);

    // 100 ETH 1:1 for every 1 ETH, we give 1 DappToke`n
    // 50 ETH and 50 DAI staked, and we want to give a reward of 1 DAPP / 1 DAI

    constructor(ERC20 _tokenAddress) {
        dappToken = _tokenAddress;
    }

    function setPriceFeed(ERC20 _token, address _pricefeed) internal onlyOwner {
        require(allowedTokens[_token], "token not allowed");
        tokenPricefeed[_token] = _pricefeed;
    }

    /// @notice issue tokens to all stakers
    function issueTokens() public onlyOwner {
        for (uint256 i = 0; i < stakers.length; i++) {
            address recipient = stakers[i];
            uint256 userTotalValue = getUserTotalValue(recipient);
            // sned a token reward based on value locked
            dappToken.transfer(recipient, userTotalValue);
        }
    }

    /// @notice gets combined value of tokens staked by an address
    /// @param _user address of user
    /// @return totalValue the total value of staked tokens
    function getUserTotalValue(address _user) public view returns (uint256) {
        uint256 totalValue = 0;
        require(uniqueTokensStaked[_user] > 0, "No token staked");
        for (uint256 i = 0; i < tokensStaked[_user].length; i++) {
            totalValue += getUserSingleTokenValue(
                _user,
                tokensStaked[_user][i]
            );
        }
        return totalValue;
    }

    function getUserSingleTokenValue(address _user, ERC20 _token)
        public
        view
        returns (uint256)
    {
        (uint256 price, uint256 decimals) = getTokenValue(_token);
        return (stakingBalances[_token][_user] * price) / (10**decimals);
    }

    function getTokenValue(ERC20 _token)
        public
        view
        returns (uint256, uint256)
    {
        address priceFeedAddress = tokenPricefeed[_token];
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            priceFeedAddress
        );
        (, int256 price, , , ) = priceFeed.latestRoundData();
        uint256 decimals = priceFeed.decimals();
        return (uint256(price), decimals);
    }

    /// @notice Stake any of the allowed tokens
    /// @param amount amount of token to stake
    /// @param _token address of token to be staked
    function stake(uint256 amount, ERC20 _token) public nonReentrant {
        require(amount > 0, "Amount cannot be 0");
        require(allowedTokens[_token], "Token isn't allowed");
        _token.transferFrom(msg.sender, address(this), amount);
        updateUniqueTokensStaked(msg.sender, _token);
        emit Stake(_token, amount);
        stakingBalances[_token][msg.sender] += amount;
        if (uniqueTokensStaked[msg.sender] == 1) {
            stakers.push(msg.sender);
        }
    }

    function unstakeTokens(ERC20 _token) public nonReentrant {
        uint256 balance = stakingBalances[_token][msg.sender];
        require(balance > 0, "Staking balance cannot be 0");
        stakingBalances[_token][msg.sender] = 0;
        uniqueTokensStaked[msg.sender] -= 1;
        _token.transfer(msg.sender, balance);
    }

    function updateUniqueTokensStaked(address _user, ERC20 _token) internal {
        if (stakingBalances[_token][_user] <= 0) {
            uniqueTokensStaked[_user] += 1;
        }
    }

    function updateTokensStaked(address _user, ERC20 _token) internal {
        if (stakingBalances[_token][_user] <= 0) {
            tokensStaked[_user].push(_token);
        }
    }

    function addAllowedTokens(ERC20 token) public onlyOwner {
        allowedTokens[token] = true;
    }
}
