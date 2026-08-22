// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title AuditChain
 * @dev Blockchain-based audit record management and verification system.
 *
 * This contract is designed as a proof-of-concept for storing
 * transaction audit records and verification data on the blockchain.
 */
contract AuditChain {

    // Contract administrator
    address public owner;

    // Total number of audit records created
    uint256 public totalRecords;

    /**
     * @dev Risk classification generated during the audit process.
     */
    enum RiskLevel {
        Low,
        Medium,
        High,
        Critical
    }

    /**
     * @dev Status of an audit record.
     */
    enum AuditStatus {
        Pending,
        Verified,
        Flagged,
        Rejected
    }

    /**
     * @dev Main structure used to store an audit record.
     */
    struct AuditRecord {
        string transactionId;
        string recordHash;
        string documentHash;

        uint256 amount;
        uint256 timestamp;
        uint256 riskScore;

        RiskLevel riskLevel;
        AuditStatus status;

        address submittedBy;

        bool exists;
        bool verified;
    }

    // Maps a transaction ID to its audit record
    mapping(string => AuditRecord) private records;

    // Maps a wallet address to its auditor permission
    mapping(address => bool) public authorizedAuditors;

    /**
     * EVENTS
     */

    event AuditRecordAdded(
        string indexed transactionId,
        string recordHash,
        string documentHash,
        uint256 amount,
        uint256 riskScore,
        address indexed submittedBy,
        uint256 timestamp
    );

    event AuditRecordUpdated(
        string indexed transactionId,
        AuditStatus status,
        bool verified,
        address updatedBy
    );

    event AuditorAuthorizationUpdated(
        address indexed auditor,
        bool authorized
    );

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * MODIFIERS
     */

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can perform this action"
        );
        _;
    }

    modifier onlyAuthorizedAuditor() {
        require(
            authorizedAuditors[msg.sender] ||
            msg.sender == owner,
            "Only an authorized auditor can perform this action"
        );
        _;
    }

    /**
     * CONTRACT INITIALIZATION
     */

    constructor() {
        owner = msg.sender;
        authorizedAuditors[msg.sender] = true;
    }

    /**
     * @dev Adds or removes an authorized auditor.
     */
    function setAuditorAuthorization(
        address _auditor,
        bool _authorized
    )
        external
        onlyOwner
    {
        require(
            _auditor != address(0),
            "Invalid auditor address"
        );

        authorizedAuditors[_auditor] = _authorized;

        emit AuditorAuthorizationUpdated(
            _auditor,
            _authorized
        );
    }

    /**
     * @dev Adds a new audit record.
     *
     * Duplicate transaction IDs are not allowed.
     */
    function addAuditRecord(
        string memory _transactionId,
        string memory _recordHash,
        string memory _documentHash,
        uint256 _amount,
        uint256 _riskScore
    )
        external
        onlyAuthorizedAuditor
    {
        require(
            bytes(_transactionId).length > 0,
            "Transaction ID cannot be empty"
        );

        require(
            !records[_transactionId].exists,
            "Audit record already exists"
        );

        require(
            _riskScore <= 100,
            "Risk score must be between 0 and 100"
        );

        RiskLevel calculatedRiskLevel =
            calculateRiskLevel(_riskScore);

        records[_transactionId] = AuditRecord({
            transactionId: _transactionId,
            recordHash: _recordHash,
            documentHash: _documentHash,

            amount: _amount,
            timestamp: block.timestamp,
            riskScore: _riskScore,

            riskLevel: calculatedRiskLevel,
            status: AuditStatus.Pending,

            submittedBy: msg.sender,

            exists: true,
            verified: false
        });

        totalRecords++;

        emit AuditRecordAdded(
            _transactionId,
            _recordHash,
            _documentHash,
            _amount,
            _riskScore,
            msg.sender,
            block.timestamp
        );
    }

    /**
     * @dev Updates the verification status of an audit record.
     */
    function updateAuditStatus(
        string memory _transactionId,
        AuditStatus _status
    )
        external
        onlyAuthorizedAuditor
    {
        require(
            records[_transactionId].exists,
            "Audit record does not exist"
        );

        records[_transactionId].status = _status;

        // Automatically mark verified when status is Verified
        if (_status == AuditStatus.Verified) {
            records[_transactionId].verified = true;
        } else {
            records[_transactionId].verified = false;
        }

        emit AuditRecordUpdated(
            _transactionId,
            _status,
            records[_transactionId].verified,
            msg.sender
        );
    }

    /**
     * @dev Retrieves the complete audit record.
     */
    function getAuditRecord(
        string memory _transactionId
    )
        external
        view
        returns (
            string memory transactionId,
            string memory recordHash,
            string memory documentHash,
            uint256 amount,
            uint256 timestamp,
            uint256 riskScore,
            RiskLevel riskLevel,
            AuditStatus status,
            address submittedBy,
            bool verified
        )
    {
        require(
            records[_transactionId].exists,
            "Audit record does not exist"
        );

        AuditRecord memory record =
            records[_transactionId];

        return (
            record.transactionId,
            record.recordHash,
            record.documentHash,
            record.amount,
            record.timestamp,
            record.riskScore,
            record.riskLevel,
            record.status,
            record.submittedBy,
            record.verified
        );
    }

    /**
     * @dev Checks whether an audit record exists.
     */
    function recordExists(
        string memory _transactionId
    )
        external
        view
        returns (bool)
    {
        return records[_transactionId].exists;
    }

    /**
     * @dev Returns only the verification information.
     */
    function verifyAuditRecord(
        string memory _transactionId,
        string memory _recordHash
    )
        external
        view
        returns (
            bool exists,
            bool hashMatches,
            bool verified,
            AuditStatus status
        )
    {
        AuditRecord memory record =
            records[_transactionId];

        if (!record.exists) {
            return (
                false,
                false,
                false,
                AuditStatus.Pending
            );
        }

        bool matches =
            keccak256(
                abi.encodePacked(record.recordHash)
            )
            ==
            keccak256(
                abi.encodePacked(_recordHash)
            );

        return (
            true,
            matches,
            record.verified,
            record.status
        );
    }

    /**
     * @dev Calculates the risk classification based on risk score.
     *
     * 0–25   = Low
     * 26–50  = Medium
     * 51–75  = High
     * 76–100 = Critical
     */
    function calculateRiskLevel(
        uint256 _riskScore
    )
        public
        pure
        returns (RiskLevel)
    {
        require(
            _riskScore <= 100,
            "Risk score must be between 0 and 100"
        );

        if (_riskScore <= 25) {
            return RiskLevel.Low;
        }

        if (_riskScore <= 50) {
            return RiskLevel.Medium;
        }

        if (_riskScore <= 75) {
            return RiskLevel.High;
        }

        return RiskLevel.Critical;
    }

    /**
     * @dev Transfers contract ownership.
     */
    function transferOwnership(
        address _newOwner
    )
        external
        onlyOwner
    {
        require(
            _newOwner != address(0),
            "Invalid owner address"
        );

        address previousOwner = owner;

        owner = _newOwner;

        authorizedAuditors[_newOwner] = true;

        emit OwnershipTransferred(
            previousOwner,
            _newOwner
        );
    }
}
