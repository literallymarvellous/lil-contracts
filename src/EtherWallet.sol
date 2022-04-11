// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

/// @title ether wallet
/// @author Ahiara Ikechukwu
/// @notice Send, recieve and withdraw ether from this contract
/// @dev Explain to a developer any extra details

contract EtherWallet {
    address payable public owner;

    /// @notice checks msg.sender is the owner
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    constructor() {
        owner = payable(msg.sender);
    }

    /// @notice Send ether to a given address
    /// @param _to The address to send ether to
    /// @param _value The amount of ether to send
    function sendEther(address payable _to, uint256 _value) external onlyOwner {
        require(_to != address(0));
        require(_value > 0);
        require(_value <= address(this).balance);
        (bool success, ) = _to.call{value: _value}("");
        require(success, "Failed to send ether");
    }

    /// @notice Withdraw ether from the contract
    function withdrawAll() external onlyOwner {
        uint256 withdrawAmount = address(this).balance;

        // send all Ether to owner
        // Owner can receive Ether since the address of owner is payable
        (bool success, ) = owner.call{value: withdrawAmount}("");
        require(success, "Failed to send Ether");
    }

    /// @notice Withdraw specific ether from the contract
    /// @param _amount The amount of ether to send
    function withdraw(uint256 _amount) external onlyOwner {
        require(_amount > 0);
        require(address(this).balance >= _amount);

        (bool success, ) = owner.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
