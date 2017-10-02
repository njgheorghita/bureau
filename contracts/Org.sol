pragma solidity ^0.4.10;
import "./Client.sol";

contract Org {
  struct GeneralInfo {
    uint256 id;
    bytes32 name;
    bytes32 hqAddress;
    bytes32 country;
    bytes32 currency;
  }
  GeneralInfo public orgInfo;
  uint256 public numberOfClients;
  address public orgWallet;
  modifier onlyBy(address _account) { require(msg.sender == _account); _; }


  function Org(
    uint256 _id,
    bytes32 _name,
    bytes32 _hqAddress,
    bytes32 _country,
    bytes32 _currency
  ) {
    orgInfo = GeneralInfo(_id, _name, _hqAddress, _country, _currency);
    orgWallet = msg.sender;
  }

  function getGeneralInfo() constant returns(uint256,bytes32,bytes32,bytes32,bytes32) {
    numberOfClients = 0;
    return (orgInfo.id, orgInfo.name, orgInfo.hqAddress, orgInfo.country, orgInfo.currency);
  }

  struct QuarterlyReport {
    uint256 year; 
    uint256 quarter; 
    uint256 numOfOffices; 
    uint256 numOfAgents; 
    uint256 grossLoanPortfolio; 
    uint256 numOfActiveBorrowers; 
    uint256 grossDepositsPortfolio; 
    uint256 numOfDepositors; 
    uint256 portfolioAtRisk30Days; 
    uint256 writeOffRatio; 
  }
  mapping ( uint256 => QuarterlyReport ) public quarterlyReportHistory;

  function getQuarterlyReport(uint256 _id) constant returns (uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256) {
    QuarterlyReport memory currentReport = quarterlyReportHistory[_id];
    return (
      _id,
      currentReport.year,
      currentReport.quarter,
      currentReport.numOfOffices,
      currentReport.numOfAgents,
      currentReport.grossLoanPortfolio,
      currentReport.numOfActiveBorrowers,
      currentReport.grossDepositsPortfolio,
      currentReport.numOfDepositors,
      currentReport.portfolioAtRisk30Days,
      currentReport.writeOffRatio
    );
  }

  function addQuarterlyReport(
    uint256 _id, 
    uint256 _year, 
    uint256 _quarter, 
    uint256 _numOfOffices, 
    uint256 _numOfAgents, 
    uint256 _grossLoanPortfolio, 
    uint256 _numOfActiveBorrowers, 
    uint256 _grossDepositsPortfolio, 
    uint256 _numOfDepositors, 
    uint256 _portfolioAtRisk30Days, 
    uint256 _writeOffRatio
  ) {
    QuarterlyReport memory newReport = QuarterlyReport(
    _year, 
    _quarter, 
    _numOfOffices, 
    _numOfAgents, 
    _grossLoanPortfolio, 
    _numOfActiveBorrowers, 
    _grossDepositsPortfolio, 
    _numOfDepositors, 
    _portfolioAtRisk30Days, 
    _writeOffRatio
    );
    quarterlyReportHistory[_id] = newReport;
  }

  mapping ( uint256 => address ) public clientList;

  function createClient
  (
    address _clientWallet,
    bytes32 _name,
    bytes32 _homeAddress, 
    bytes32 _birthday, 
    uint256 _age, 
    uint8 _gender, 
    uint8 _education,
    uint8 _householdSize,
    uint8 _dependents,
    bool _married,
    uint256 _monthlyHouseholdIncome,
    uint8 _numOfBusinesses,
    uint8 _numOfEmployees,
    uint256 _phoneNumber
  ) onlyBy(orgWallet) {
    address newClientAddress = new Client(
      _clientWallet,
      _name,
      _homeAddress,
      _birthday,
      _age,
      _gender,
      _education,
      _householdSize,
      _dependents,
      _married,
      _monthlyHouseholdIncome,
      _numOfBusinesses,
      _numOfEmployees,
      _phoneNumber
    );
    numberOfClients = numberOfClients + 1;
    clientList[numberOfClients] = newClientAddress;
  }

  function getClientAddressById(uint256 _id) constant returns(address) {
    return clientList[_id];
  }

  function addLoanToClientProfile
  (
    uint256 _clientId,
    uint256 _loanId,
    uint256 _amount, 
    bytes32 _startDate,
    bytes32 _endDate,
    uint256 _interestRate, 
    uint8 _numberOfPayments, 
    bool _status // true - success / false - success
  ) 
    onlyBy(orgWallet)
    returns (bool) 
  {
    Client currentClient = getClient(_clientId);
    currentClient.addLoan(
      _loanId, _amount, _startDate, _endDate, _interestRate, _numberOfPayments, _status
    );
    return true;
  }

  function getClient(uint256 _clientId) returns(Client) {
    address currentClientAddress = clientList[_clientId];
    Client currentClient = Client(currentClientAddress);
    return currentClient;
  }

  function addJobToClientProfile
  (
    uint256 _clientId,
    bytes32 _title,
    bytes32 _employer,
    bytes32 _workAddress,
    bytes32 _startDate,
    bytes32 _endDate,
    uint256 _monthlySalary
  ) 
    onlyBy(orgWallet)
    returns(bool) 
  {
    Client currentClient = getClient(_clientId);
    currentClient.addJob(
      _title, _employer, _workAddress, _startDate, _endDate, _monthlySalary
    );
    return true;
  }

  function getGrossClientDeposits() returns(uint) {
    uint totalDeposits = 0;
    for (uint i = 0; i <= numberOfClients; i++) {
      address currentAddress = clientList[i];
      uint tempBalance = totalDeposits + currentAddress.balance;
      totalDeposits = tempBalance;
    }
    return totalDeposits;
  }
}