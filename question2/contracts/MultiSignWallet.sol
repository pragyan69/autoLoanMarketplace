// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiSigWallet {
    address[] public owners;
    uint256 public required;
    mapping(address => bool) public isOwner;
    uint256 public transactionCount;
    mapping(uint256 => Transaction) public transactions;
    mapping(uint256 => mapping(address => bool)) public confirmations;

    struct Transaction {
        address destination;
        uint256 value;
        bytes data;
        bool executed;
    }

    event Submission(uint256 indexed transactionId);
    event Confirmation(address indexed sender, uint256 indexed transactionId);
    event Execution(uint256 indexed transactionId);

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length >= _required, "Invalid number of owners and required confirmations");

        for (uint256 i = 0; i < _owners.length; i++) {
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;
    }

    function submitTransaction(address destination, uint256 value, bytes memory data) public returns (uint256) {
        require(isOwner[msg.sender], "Only owners can submit transactions");
        uint256 transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            data: data,
            executed: false
        });
        transactionCount += 1;
        emit Submission(transactionId);
        return transactionId;
    }

    function confirmTransaction(uint256 transactionId) public {
        require(isOwner[msg.sender], "Only owners can confirm transactions");
        require(!confirmations[transactionId][msg.sender], "Transaction already confirmed by this owner");
        confirmations[transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

    function executeTransaction(uint256 transactionId) public {
        require(transactions[transactionId].executed == false, "Transaction already executed");
        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId];
            txn.executed = true;
            (bool success, ) = txn.destination.call{value: txn.value}(txn.data);
            require(success, "Transaction execution failed");
            emit Execution(transactionId);
        }
    }

    function isConfirmed(uint256 transactionId) internal view returns (bool) {
        uint256 count = 0;
        for (uint256 i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]]) {
                count += 1;
            }
            if (count == required) {
                return true;
            }
        }
        return false;
    }
}
