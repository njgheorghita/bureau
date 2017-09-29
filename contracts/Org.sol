pragma solidity ^0.4.15;
import "./Client.sol";

contract Org {
  /*
    ORG INFO
    struct GeneralInfo
    GeneralInfo orgInfo
    uint256 numberOfClients
    uint256 grossClientDeposits
    address orgWallet
    Org() : 
    getGeneralInfo() :

    REPORTS
    struct QuarterlyReport
    mapping ( id (yyyy#) => QuarterlyReport ) quarterlyReportHistory
    getQuarterlyReport() :
    addQuarterlyReport() :

    CLIENTS
    mapping (numClient => address) clientList
    createClient() : onlyBy OrgWallet
    getClientAddressById() : 
    getClientPersonalInfoById() :
    addLoanToClientProfile() : onlyBy orgWallet
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
  GeneralInfo public orgInfo;
  uint256 public numberOfClients;
  uint256 public grossClientDeposits;
  address public orgWallet;
  modifier onlyBy(address _account) { require(msg.sender == _account); _; }


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
  }

  function getGeneralInfo() constant returns(uint256,bytes32,bytes32,bytes32,bytes32,address) {
    numberOfClients = 0;
    return (orgInfo.id, orgInfo.name, orgInfo.hqAddress, orgInfo.country, orgInfo.currency, orgWallet);
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

  // function createClient
  // (
  //   address _clientWallet,
  //   bytes32 _name,
  //   bytes32 _homeAddress, 
  //   bytes32 _birthday, 
  //   uint256 _age, 
  //   uint8 _gender, 
  //   uint8 _education,
  //   uint8 _householdSize,
  //   uint8 _dependents,
  //   bool _married,
  //   uint256 _monthlyHouseholdIncome,
  //   uint8 _numOfBusinesses,
  //   uint8 _numOfEmployees,
  //   uint256 _phoneNumber
  // ) onlyBy(orgWallet) {
  //   address newClientAddress = new Client(
  //     _clientWallet,
  //     _name,
  //     _homeAddress,
  //     _birthday,
  //     _age,
  //     _gender,
  //     _education,
  //     _householdSize,
  //     _dependents,
  //     _married,
  //     _monthlyHouseholdIncome,
  //     _numOfBusinesses,
  //     _numOfEmployees,
  //     _phoneNumber
  //   );
  //   numberOfClients = numberOfClients + 1;
  //   clientList[numberOfClients] = newClientAddress;
  // }

  // function getClientAddressById(uint256 _id) constant returns(address) {
  //   return clientList[_id];
  // }

  function getClientPersonalInfoById(uint256 _id) constant returns
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
    bool married
  ) {
    Client currentClient = getClient(_id);
    return currentClient.getPersonalInfo();
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

  function updateGrossDeposits(uint256 _amount, bool _type) {
    if (_type == true) {
      grossClientDeposits = grossClientDeposits + _amount;
    } else {
      grossClientDeposits = grossClientDeposits - _amount;
    }
  }
}