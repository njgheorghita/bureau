pragma solidity ^0.4.15;
import "./Client.sol";
import "./Loan.sol";
import "./Bureau.sol";

contract Org {
  /*
    ORG INFO
    struct GeneralInfo
    GeneralInfo orgInfo
    uint256 numberOfClients
    uint256 grossClientDeposits
    address orgWallet
    address bureauAddress
    Org() : 
    getGeneralInfo() :

    LOANS
    createLoan() : 
    mapping (uint256 => address[]) loan repo

    REPORTS
    struct QuarterlyReport
    mapping ( id (yyyy#) => QuarterlyReport ) quarterlyReportHistory
    getQuarterlyReport() :
    addQuarterlyReport() :

    CLIENTS
    mapping (numClient => address) clientList
    getClientAddressById() : 
    getClientPersonalInfoById() :
    addJobToClientProfile() : onlyBy orgWallet
    getClient() : returns Client
    updateGrossDeposits() : 
  */
  struct GeneralInfo {
    uint256 id;
    bytes32 name;
    bytes32 hqAddress;
    bytes32 country;
    bytes32 currency;
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
  modifier onlyBy(address _account) {require(msg.sender == _account); _;}
  mapping ( uint256 => QuarterlyReport ) public quarterlyReportHistory;
  mapping ( bytes32 => address ) public clientList;
  mapping ( bytes32 => address[]) loanRepo;
  GeneralInfo public orgInfo;
  uint256 public numberOfClients;
  uint256 public grossClientDeposits;
  address public orgWallet;
  address public bureauAddress;
  uint256 public totalSuccessfulClientPayments;
  uint256 public totalClientPayments;


  function Org(
    uint256 _id,
    bytes32 _name,
    bytes32 _hqAddress,
    bytes32 _country,
    bytes32 _currency,
    address _orgWallet
  ) {
    orgInfo = GeneralInfo(_id, _name, _hqAddress, _country, _currency);
    orgWallet = _orgWallet;
    grossClientDeposits = 0;
    bureauAddress = msg.sender;
    totalClientPayments = 0;
    totalSuccessfulClientPayments = 0;
  }

  function getGeneralInfo() constant returns(uint256,bytes32,bytes32,bytes32,bytes32,address) {
    numberOfClients = 0;
    return (orgInfo.id, orgInfo.name, orgInfo.hqAddress, orgInfo.country, orgInfo.currency, orgWallet);
  }

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

  function getClientAddressById(bytes32 _id) constant returns(address) {
    return clientList[_id];
  }

  function getClientPersonalInfoById(bytes32 _id) constant returns
  (
    address clientWallet,
    bytes32 name,
    bytes32 homeAddress, 
    bytes32 birthday, 
    uint256 age, 
    uint8 gender, 
    uint8 education,
    uint8 householdSize,
    uint8 dependents,
    bool married,
    uint256 phoneNumber
  ) {
    Client currentClient = getClient(_id);
    return currentClient.getPersonalInfo();
  }

  function createLoan
  (
    bytes32 _clientId,
    uint256 _amount,
    uint256 _durationInMonths,
    uint256 _monthlyPayment,
    bytes32 _startDate
  ) {
    address clientAddress = getClientAddressFromBureauById(_clientId);
    address newLoanAddress = new Loan(
      _amount, _durationInMonths, _monthlyPayment, 
      _startDate, this, clientAddress  
    );
    address[] storage tempAddresses = loanRepo[_clientId];
    tempAddresses.push(newLoanAddress);
    Client currentClient = Client(clientAddress);
    currentClient.addLoanToClient(newLoanAddress);
  }

  function getLoansByClientId(bytes32 _clientId) constant returns(address[]) {
    return loanRepo[_clientId];
  }

  function getClient(bytes32 _clientId) returns(Client) {
    address currentClientAddress = clientList[_clientId];
    Client currentClient = Client(currentClientAddress);
    return currentClient;
  }

  function getClientAddressFromBureauById(bytes32 _clientId) returns(address) {
    Bureau currentBureau = Bureau(bureauAddress);
    address currentClientAddress = currentBureau.findClientAddress(_clientId);
    return currentClientAddress;
  }

  function addJobToClientProfile
  (
    bytes32 _clientId,
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

  function updateGrossDeposits(uint256 _amount, bool _type) {
    if (_type == true) {
      grossClientDeposits = grossClientDeposits + _amount;
    } else {
      grossClientDeposits = grossClientDeposits - _amount;
    }
  }

  function updateLoanByAddress(address _loanAddress, bool _paymentMade) {
    Loan currentLoan = Loan(_loanAddress);
    currentLoan.updateLoanPayment(_paymentMade);
    address currentClient = currentLoan.clientWallet();
    Client(currentClient).updateRepaymentRateStats(_paymentMade);
    if (_paymentMade)
      totalSuccessfulClientPayments += 1;
    totalClientPayments += 1;
  }
}