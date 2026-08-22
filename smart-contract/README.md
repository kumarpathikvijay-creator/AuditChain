# AuditChain Smart Contract

This directory contains the smart contract implementation used for blockchain-based audit record verification in the AuditChain project.

## Purpose

The AuditChain smart contract provides an immutable method for recording and verifying audit-related transaction records on the blockchain.

Each record contains:

- Transaction ID
- Record hash
- Timestamp
- Wallet address of the submitting account

## Smart Contract Functions

### Add Audit Record

The `addAuditRecord` function stores an audit record on the blockchain.

Input:

```text
Transaction ID
Record Hash
