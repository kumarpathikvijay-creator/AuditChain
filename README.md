# AuditChain

## Blockchain-Based AI Audit and Transaction Verification System

AuditChain is a prototype system designed to demonstrate how Artificial Intelligence, workflow automation, and blockchain technology can be integrated into an audit and transaction verification process.

The project focuses on automating the extraction and processing of invoice and transaction data, performing structured analysis, maintaining audit records, and creating blockchain-based verification records for improved transparency and traceability.

---

# Project Overview

Traditional audit processes often involve manual verification of invoices, transactions, and supporting financial documents. This can be time-consuming and may create challenges related to data consistency, traceability, and audit record management.

AuditChain demonstrates a technology-driven approach where:

1. Financial or invoice data is received by the system.
2. Automation workflows process the incoming data.
3. AI is used to extract and structure relevant information.
4. Transaction and audit information is stored in a structured format.
5. Selected audit records can be recorded and verified using blockchain technology.
6. The resulting transaction can be independently verified using blockchain transaction records.

This project was developed as a prototype and proof of concept.

---

# Key Technologies

| Technology | Purpose |
|---|---|
| Google Sheets | Transaction and audit data storage |
| Make.com | Workflow automation and data integration |
| Google Gemini AI | AI-powered data extraction and structured analysis |
| Webhooks | Receiving incoming invoice or transaction data |
| Remix IDE | Smart contract development and testing |
| Solidity | Blockchain smart contract development |
| Polygon Amoy Testnet | Blockchain transaction testing environment |
| MetaMask | Blockchain wallet and transaction signing |
| Thirdweb | Blockchain development and project infrastructure |

---

# System Architecture

The AuditChain workflow consists of the following major stages:

```text
Invoice / Transaction Data
          ↓
       Webhook
          ↓
   Automation Workflow
          ↓
   AI Data Processing
          ↓
Structured Transaction Data
          ↓
    Google Sheets
          ↓
 Smart Contract Interaction
          ↓
Polygon Amoy Blockchain
          ↓
Blockchain Verification
