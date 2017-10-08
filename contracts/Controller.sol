pragma solidity 0.4.15;
import "./Org.sol";
import "./Bureau.sol";
import "./Loan.sol";
import "./HasLoans.sol";

contract Controller {
  address public bureauAddress;

  function Controller(address _bureauAddress) {
    // who can call this
    bureauAddress = _bureauAddress;
  }

  function getAllLoanDataForAddresses(address _orgOrClientAddress) 
    constant
    returns 
  (
    uint256[],
    uint256[],
    bytes32[],
    bytes32[],
    uint256[],
    uint256[]
  ) {
    uint length = HasLoans(_orgOrClientAddress).getNumberOfLoans();
    uint256[] memory amounts = new uint256[](length);
    uint256[] memory durationMonths = new uint256[](length);
    bytes32[] memory startDates = new bytes32[](length);
    bytes32[] memory loanStatuses = new bytes32[](length);
    uint256[] memory paymentCounts = new uint256[](length);
    uint256[] memory successfulPaymentCounts = new uint256[](length);
    for (uint i = 0; i < length; i++) {
      Loan currentLoan = Loan(HasLoans(_orgOrClientAddress).loanAddresses(i));

      amounts[i] = currentLoan.loanAmount();
      durationMonths[i] = currentLoan.loanDurationInMonths();
      startDates[i] = currentLoan.loanStartDate();
      loanStatuses[i] = currentLoan.getLoanStatus();
      paymentCounts[i] = currentLoan.currentPaymentCount();
      successfulPaymentCounts[i] = currentLoan.currentSuccessfulPayments();
    }
    return (amounts, durationMonths, startDates, loanStatuses, paymentCounts, successfulPaymentCounts);
  }


  // return detailed data for an org
  // quarterly reports (or fancy info)
  function getBasicOrgInfoById(uint256 _orgId) 
    constant
    returns(
      address,
      uint256,
      bytes32,
      bytes32,
      bytes32,
      bytes32
    ) {
      uint256 id;
      bytes32 name;
      bytes32 hqAddress;
      bytes32 country;
      bytes32 currency;
      address orgAddress;

      (orgAddress, id, name, hqAddress, country, currency, ) = Bureau(bureauAddress).getOrgInfoById(_orgId);
      return(orgAddress, id, name, hqAddress, country, currency);
    }
  
  // return detailed data for an org
  // quarterly reports (or fancy info)
  function getDetailedOrgInfoById(uint256 _orgId) 
    constant
  returns(
    uint256,
    uint256,
    uint256,
    uint256
  ) {
    uint256 numberOfClients;
    uint256 grossDeposits;
    uint256 totalSuccessfulPayments;
    uint256 totalPayments;

    (numberOfClients, grossDeposits, totalSuccessfulPayments, totalPayments) = Bureau(bureauAddress).getOrgDetailsById(_orgId);
    return(numberOfClients, grossDeposits, totalSuccessfulPayments, totalPayments);
  }

  function getOrgAddressById(uint256 _orgId) returns(address) {
    return Bureau(bureauAddress).getOrgAddressById(_orgId);
  }

  function getClientAddressById(bytes32 _clientId) returns(address) {
    return Bureau(bureauAddress).clientList(_clientId);
  }

  function getClientIdsForOrg(uint256 _orgId) constant returns(bytes32[]){
    address orgAddress = getOrgAddressById(_orgId);
    Org currentOrg = Org(orgAddress);
    uint length = currentOrg.getNumberOfClients();
    bytes32[] memory ids = new bytes32[](length);
    for (uint i = 0; i < length; i++) {
      ids[i] = currentOrg.clientIds(i);
    }
    return ids;
  }

  function getAllClientIds() constant returns(bytes32[]) {
    Bureau currentBureau = Bureau(bureauAddress);
    uint length = currentBureau.getNumberOfClients();
    bytes32[] memory ids = new bytes32[](length);
    for (uint i = 0; i < length; i++) {
      ids[i] = currentBureau.clientIds(i);
    }
    return ids;
  }

  function getClientDetailsById(bytes32 _clientId) 
    constant
  returns(
    bytes32, // id
    address, // profile address 
    bytes32, // homeAddress
    uint256, // gender
    uint256, // phonenumber
    bool,    // married?
    uint256, // numberPayments
    uint256, // numberSuccessful
    uint256 // totalDeposits

  ) {
    address clientAddress = getClientAddressById(_clientId);
    Client currentClient = Client(clientAddress);
    return (
      _clientId,
      clientAddress,
      currentClient.clientHomeAddress(),
      currentClient.clientGender(),
      currentClient.clientPhone(),
      currentClient.clientMarried(),
      currentClient.totalNumberOfPayments(),
      currentClient.totalNumberOfSuccessfulPayments(),
      currentClient.numberOfSavingsTxs()
    );
  }

  // return all proposal data
  function getBallotData() constant returns(bytes32[], uint256[], uint256[]) {
    address ballotAddress = Bureau(bureauAddress).ballotAddress();
    Ballot currentBallot = Ballot(ballotAddress);
    uint length = currentBallot.getNumberOfProposals();
    bytes32[] memory proposalNames = new bytes32[](length);
    uint256[] memory forCounts = new uint256[](length);
    uint256[] memory againstCounts = new uint256[](length);
    for (uint i = 0; i < length; i++) {
      proposalNames[i] = currentBallot.proposalNames(i);
      forCounts[i] = currentBallot.forCounts(i);
      againstCounts[i] = currentBallot.againstCounts(i);
    }
    return (proposalNames, forCounts, againstCounts );
  }

  function addProposal(bytes32 _propName) {
    address ballotAddress = Bureau(bureauAddress).ballotAddress();
    Ballot(ballotAddress).addProposal(_propName);
  }

  // vote w/o authentication
  function voteFor(uint256 _proposalId) {
    address ballotAddress = Bureau(bureauAddress).ballotAddress();
    Ballot(ballotAddress).voteFor(_proposalId);
  }
  
  function voteAgainst(uint256 _proposalId) {
    address ballotAddress = Bureau(bureauAddress).ballotAddress();
    Ballot(ballotAddress).voteAgainst(_proposalId);
  }


}
