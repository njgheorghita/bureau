pragma solidity 0.4.15;
import "./Client.sol";
import "./Loan.sol";
import "./Bureau.sol";
import "./HasLoans.sol";

contract Org is HasLoans {
  /*
   *  Storage
   */

  struct QuarterlyReport {
    uint256 grossLoanPortfolio; 
    uint256 numOfActiveBorrowers; 
    uint256 grossDepositsPortfolio; 
    uint256 numOfDepositors; 
    uint256 totalSuccess;
    uint256 totalPayments;
  }

  /// @dev Stores QuarterlyReport structs according to their id (year + quarter)
  mapping ( uint256 => QuarterlyReport ) public quarterlyReportHistory;
  uint256[] public quarterlyReportList;

  /// @dev Stores an address of client with a loan pointed to by the clientId
  mapping ( bytes32 => address ) public clientList;
  bytes32[] public clientIds;

  function getNumberOfClients() constant returns(uint) {
    return clientIds.length;
  }

  /// @dev Stores a list of loans between a Client (based on clientId) and the Org
  mapping ( bytes32 => address[]) loanRepo;
  address[] public loanAddresses;

  function getNumberOfLoans() constant returns(uint) {
    return loanAddresses.length;
  }

  function getNumberOfQrs() constant returns(uint) {
    return quarterlyReportList.length;
  }

  function getLoanAddresses() returns(address[]) {
    uint length = loanAddresses.length;
    address[] memory addresses = new address[](length);

    for (uint i = 0; i < length; i++) {
      addresses[i] = loanAddresses[i];
    }
    return addresses;
  }
  
  uint256 public orgId;
  bytes32 public orgName;
  bytes32 public orgHqAddress;
  bytes32 public orgCountry;
  bytes32 public orgCurrency;
  uint256 public numberOfClients;

  /// @dev !!!! needs to be fixed & changed to collateral
  uint256 public grossClientDeposits;

  /// @dev wallet that controls the Org's txs: used for auth
  address public orgWallet;

  /// @dev wallet of the bureau this Org belongs to: there's only one Bureau
  address public bureauAddress;

  /// @dev Stats used to calculate the Org's repayment rate (aka reputation score)
  uint256 public totalSuccessfulClientPayments;
  uint256 public totalClientPayments;

  /*
   *  Modifiers
   */

  /// @dev Authentication
  // @param address _account
  modifier onlyBy(address _account) {require(msg.sender == _account); _;}

  /*
   *  Public Functions
   */

  /// @dev Constructor & Initializes certain counter variables
  // @param uint256 _id
  // @param bytes32 _name
  // @param bytes32 _hqAddress
  // @param bytes32 _country
  // @param bytes32 _currency
  // @param bytes32 _orgWallet
  function Org(
    uint256 _id,
    bytes32 _name,
    bytes32 _hqAddress,
    bytes32 _country,
    bytes32 _currency,
    address _orgWallet
  ) {
    orgWallet = _orgWallet;
    grossClientDeposits = 0;
    bureauAddress = msg.sender;
    totalClientPayments = 0;
    totalSuccessfulClientPayments = 0;
    orgId = _id;
    orgName = _name;
    orgHqAddress = _hqAddress;
    orgCountry = _country;
    orgCurrency = _currency;
  }

  /// @dev Getter for general info about Org
  /// @dev Returns id, name, hqAddress, country, currency, orgWallet
  function getGeneralInfo() constant returns(uint256,bytes32,bytes32,bytes32,bytes32,address) {
    numberOfClients = 0;
    return (orgId, orgName, orgHqAddress, orgCountry, orgCurrency, orgWallet);
  }

  function getDetailedInfo() constant returns(uint256, uint256, uint256, uint256) {
    return(numberOfClients, grossClientDeposits, totalSuccessfulClientPayments, totalClientPayments);
  }

  function getQuarterlyReportData()
    constant
    returns
  (
    uint256[],
    uint256[],
    uint256[],
    uint256[],
    uint256[],
    uint256[]
  ) {
    uint length = quarterlyReportList.length;
    uint256[] memory ids = new uint256[](length);
    uint256[] memory grossPortfolios = new uint256[](length);
    uint256[] memory activeBorrowers = new uint256[](length);
    uint256[] memory grossDeposits = new uint256[](length);
    uint256[] memory totalPayments = new uint256[](length);
    uint256[] memory totalSuccess = new uint256[](length);
    for (uint i = 0; i < length; i++) {
      uint256 qrId = quarterlyReportList[i];
      QuarterlyReport currentQr = quarterlyReportHistory[qrId];
      ids[i] = qrId;
      grossPortfolios[i] = currentQr.grossLoanPortfolio;
      activeBorrowers[i] = currentQr.numOfActiveBorrowers;
      grossDeposits[i] = currentQr.grossDepositsPortfolio;
      totalPayments[i] = currentQr.totalPayments;
      totalSuccess[i] = currentQr.totalSuccess;
    }
    return(ids, grossPortfolios, activeBorrowers, grossDeposits, totalPayments, totalSuccess);
  }


  function addQuarterlyReport(
    uint256 _id, 
    uint256 _grossLoanPortfolio, 
    uint256 _numOfActiveBorrowers, 
    uint256 _grossDepositsPortfolio, 
    uint256 _numOfDepositors
  ) {
    QuarterlyReport memory newReport = QuarterlyReport(
    _grossLoanPortfolio, 
    _numOfActiveBorrowers, 
    _grossDepositsPortfolio, 
    _numOfDepositors,
    totalSuccessfulClientPayments,
    totalClientPayments
    );
    quarterlyReportHistory[_id] = newReport;
    quarterlyReportList.push(_id);
  }

  /// @dev Getter for a Client's personal info based on their id (clientId)
  /// @dev Returns clientWallet, name, homeAddress, birthday, age, gender, education
  ///      householdSize, dependents, married, phoneNumber
  function getClientPersonalInfoById(bytes32 _id) 
    constant 
    returns
  (
    address,bytes32,bytes32,bytes32,uint256,uint8,uint8,uint8,uint8,bool,uint256
  ) {
    Client currentClient = getClient(_id);
    return currentClient.getPersonalInfo();
  }

  /// @dev Getter for all clients & basic data for frontend
  function getAllClientData() 
    constant
    returns(address[], bytes32[], uint256[], uint256[], uint256[])
  {
    uint length = clientIds.length;
    address[] memory clientAddresses = new address[](length);
    bytes32[] memory tempClientIds = new bytes32[](length);
    uint256[] memory numberOfLoans = new uint256[](length);
    uint256[] memory paymentCounts = new uint256[](length);
    uint256[] memory successfulPaymentCounts = new uint256[](length);
    for (uint i = 0; i < length; i++) {
      address currentClientAddress = getClientAddressFromBureauById(clientIds[i]);
      Client currentClient = Client(currentClientAddress);
      uint numOfLoans = loanRepo[clientIds[i]].length;
      clientAddresses[i] = currentClientAddress;
      tempClientIds[i] = clientIds[i];
      numberOfLoans[i] = numOfLoans;
      paymentCounts[i] = currentClient.totalNumberOfPayments();
      successfulPaymentCounts[i] = currentClient.totalNumberOfSuccessfulPayments();
    }
    return(clientAddresses, tempClientIds, numberOfLoans, paymentCounts, successfulPaymentCounts);
  }

  /// @dev Creates a new loan contract between Org & Client
  /// @dev Stores clientAddress in clientList
  /// @dev Stores loan address in loanRepo
  /// @dev Adds the loan to the client's contract 
  ///      (so the client's profile has a reference to the loan address)
  // @param bytes32 _clientId
  // @param uint256 _amount: _amount should == _durationInMonths * _monthlyPayment
  // @param uint256 _durationInMonths
  // @param uint256 _monthlyPayment
  // @param bytes32 _startDate: "MM/DD/YYYY"
  function createLoan
  (
    bytes32 _clientId,
    uint256 _amount,
    uint256 _durationInMonths,
    uint256 _monthlyPayment,
    bytes32 _startDate
  ) {
    address clientAddress = getClientAddressFromBureauById(_clientId);
    clientList[_clientId] = clientAddress;
    address newLoanAddress = new Loan(
      _amount, _durationInMonths, _monthlyPayment, 
      _startDate, this, clientAddress  
    );
    address[] storage tempAddresses = loanRepo[_clientId];
    tempAddresses.push(newLoanAddress);
    Client currentClient = Client(clientAddress);
    currentClient.addLoanToClient(newLoanAddress);
    loanAddresses.push(newLoanAddress);
    clientIds.push(_clientId);
  }

  /// @dev Getter for array of loans via _clientId from loanRepo mapping
  // @param bytes32 _clientId
  function getLoansByClientId(bytes32 _clientId) constant returns(address[]) {
    return loanRepo[_clientId];
  }

  /// @dev Updates grossClientDeposits - called from Client contract
  // @param uint256 _amount
  // @param bool _type
  function updateGrossDeposits(uint256 _amount, bool _type) {
    if (_type == true) {
      grossClientDeposits = grossClientDeposits + _amount;
    } else {
      grossClientDeposits = grossClientDeposits - _amount;
    }
  }

  /// @dev Updates an already created Loan contract on whether a payment was made
  // @param address _loanAddress
  // @param bool _paymentMade
  function updateLoanByAddress(address _loanAddress, bool _paymentMade) {
    Loan currentLoan = Loan(_loanAddress);
    currentLoan.updateLoanPayment(_paymentMade);
    address currentClient = currentLoan.clientWallet();
    Client(currentClient).updateRepaymentRateStats(_paymentMade);
    if (_paymentMade)
      totalSuccessfulClientPayments += 1;
    totalClientPayments += 1;
  }

  /*
   *  Private Functions
   */
  /// @dev Getter for Client object via _clientId
  // @param bytes32 _clientId
  function getClient(bytes32 _clientId) private returns(Client) {
    address currentClientAddress = clientList[_clientId];
    Client currentClient = Client(currentClientAddress);
    return currentClient;
  }

  /// @dev Getter for Client address from Bureau via _clientId for search functionality
  /// @ param bytes32 _clientId
  function getClientAddressFromBureauById(bytes32 _clientId) private returns(address) {
    Bureau currentBureau = Bureau(bureauAddress);
    address currentClientAddress = currentBureau.findClientAddress(_clientId);
    return currentClientAddress;
  }
}