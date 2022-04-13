// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

contract MultiSigWallet {
    event Deposit(address indexed sender, uint256 amount);
    event Submit(uint256 indexed transactionId);
    event Approve(address indexed owner, uint256 indexed transactionId);
    event Revoke(address indexed owner, uint256 indexed transactionId);
    event Execute(uint256 indexed transactionId);

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
    }

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public required;

    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) public approved;

    /// @notice checks msg.sender is the owner
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Only owner can call this function");
        _;
    }

    /// @notice checks if transaction exits
    modifier transactionExists(uint256 transactionId) {
        require(
            transactionId < transactions.length,
            "Transaction does not exist"
        );
        _;
    }

    modifier notApproved(uint256 transactionId) {
        require(
            !approved[transactionId][msg.sender],
            "Transaction already approved"
        );
        _;
    }

    modifier notExecuted(uint256 transactionId) {
        require(
            !transactions[transactionId].executed,
            "Transaction already executed"
        );
        _;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "owners required");
        require(
            _required > 0 && _required <= _owners.length,
            "invalid required number pf owners"
        );

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "owner cannot be the zero address");
            require(isOwner[owner] == false, "owner already exists");

            owners.push(owner);
            isOwner[owner] = true;
        }

        required = _required;
    }

    function submit(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyOwner {
        Transaction memory transaction = Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false
        });

        transactions.push(transaction);
        emit Submit(transactions.length - 1);
    }

    function approve(uint256 _transactionId)
        external
        onlyOwner
        transactionExists(_transactionId)
        notApproved(_transactionId)
        notExecuted(_transactionId)
    {
        approved[_transactionId][msg.sender] = true;
        emit Approve(msg.sender, _transactionId);
    }

    function _getApprovalCount(uint256 _transactionId)
        private
        view
        returns (uint256 count)
    {
        for (uint256 i; i < owners.length; i++) {
            if (approved[_transactionId][owners[i]]) {
                count += 1;
            }
        }
    }

    function execute(uint256 _transactionId)
        external
        transactionExists(_transactionId)
        notExecuted(_transactionId)
    {
        require(
            _getApprovalCount(_transactionId) >= required,
            "Not enough approvals"
        );
        Transaction storage transaction = transactions[_transactionId];

        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );

        require(success, "Transaction failed");

        emit Execute(_transactionId);
    }

    function revoke(uint256 _transactionId)
        external
        onlyOwner
        transactionExists(_transactionId)
        notExecuted(_transactionId)
    {
        require(approved[_transactionId][msg.sender], "Not approved");
        approved[_transactionId][msg.sender] = false;
        emit Revoke(msg.sender, _transactionId);
    }

    function getTransactionLength() external view returns (uint256) {
        return transactions.length;
    }
}
