### MFI Credit Bureau

A self-governed credit bureau for Microfinance Institutions to share / sell borrower data in order to reduce costs of evaluating a borrower, improve repayment rate, and establish a financial history for unbanked borrowers. 

A project for the [BSIC Hackathon](https://www.blockchainforsocialimpact.com/hackathon/) Fall 2017 by [David Knott](https://github.com/davidknott), [Ethan Bennett](https://github.com/ethanbennett) and [Nick Gheorghita](https://github.com/njgheorghita). 

The live site can be found [here](http://blockchain-credit-bureau.herokuapp.com/).

A business pitch and code demo can be found [here](https://youtu.be/GId1luAYIK0). This project is still very much in the proof-of-concept / development stage. We'd love any feedback on how to best build out this concept, especially with features that MFIs might find helpful.

The front end React repo can be found [here](https://github.com/ethanbennett/credit-bureau-client).
This repo contains the solidity backend for Bureau. 
- `Ballot.sol ` : Contains the primary voting logic for all proposals.
- `Bureau.sol` : Parent contract for the whole bureau. Tracks clients and orgs.
- `Client.sol` : Profile contract for an individual client (aka borrower).
- `Controller.sol` : Interface contract for the front-end to get certain data.
- `HasLoans.sol` : Helper contract.
- `Loan.sol` : Contract for an individual loan between an Org and Client. Tracks payments.
- `Org.sol` : Profile contract for an individual Org (aka MFI).

TODO:
- Implement authentication
- Move all front-end calls to `Controller.sol`
- Create a node/rails server to store metadata
