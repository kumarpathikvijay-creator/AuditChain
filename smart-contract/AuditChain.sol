// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuditChain {

    struct AuditRecord {
        string transactionId;
        string recordHash;
        uint256 timestamp;
        address submittedBy;
    }

    mapping(string => AuditRecord) private records;

    event AuditRecordAdded(
        string transactionId,
        string recordHash,
        uint256 timestamp,
        address submittedBy
    );

    function addAuditRecord(
        string memory _transactionId,
        string memory _recordHash
    ) public {

        records[_transactionId] = AuditRecord(
            _transactionId,
            _recordHash,
            block.timestamp,
            msg.sender
        );

        emit AuditRecordAdded(
            _transactionId,
            _recordHash,
            block.timestamp,
            msg.sender
        );
    }

    function getAuditRecord(
        string memory _transactionId
    )
        public
        view
        returns (
            string memory,
            string memory,
            uint256,
            address
        )
    {
        AuditRecord memory record = records[_transactionId];

        return (
            record.transactionId,
            record.recordHash,
            record.timestamp,
            record.submittedBy
        );
    }
}
