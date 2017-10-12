### MFI Credit Bureau

`npm install`

This repo contains the solidity contracts for Bureau. 


`Ballot.sol ` : Contains the primary voting logic for all proposals.
`Bureau.sol` : Parent contract for the whole bureau. Tracks clients and orgs.
`Client.sol` : Profile contract for an individual client (aka borrower).
`Controller.sol` : Interface contract for the front-end to get certain data.
`HasLoans.sol` : Helper contract.
`Loan.sol` : Contract for an individual loan between an Org and Client. Tracks payments.
`Org.sol` : Profile contract for an individual Org (aka MFI).

TODO:
Implement authentication
Move all front-end calls to `Controller.sol`