/// Bureau.sol (aka parent)

/*
 *  Storage
 */

/// @dev Org's id pointing to their address
mapping (uint256 => address) public orgList;

/// @dev Stores org addresses to auth for Ballot.sol
address [] orgAdresses;

/// @dev Wallet address that controls the bureau
address public ownerAddress;

/// @dev Client id (Name + Birthday) pointing to their profile address
mapping (bytes32 => address) public clientList;

uint256 public numberOfClients;

/// @dev Stores array of all created ballot addresses
address[] public ballotAddresses;

/*
 *  Public Functions
 */

/// @dev Constructor
function Bureau() {}

/// @dev Creates and adds an org to the Bureau (both orgList and orgAddresses)
/// @dev Returns the address of the newly created Org contract
/// @param uint256 _id
/// @param bytes32 _name
/// @param bytes32 _hqAddress
/// @param bytes32 _country
/// @param bytes32 _currency
/// @param uint256 _orgWallet
function addOrgToBureau() returns (address) {}

/// @dev Getter for the General Info (org.getGeneralInfo()) from an Org's contract
/// @dev Returns id, name, hqAddress, country, currency, orgWallet
/// @param uint256 _id
function getOrgInfoById() 
  returns (uint256, bytes32, bytes32, bytes32, bytes32, address){}

/// @dev Creates a new client, increments numberOfClients, and stores contract address in 
///      clientList being pointed to by the input _id (aka client id: name + '-' + birthday)
/// @param bytes32 _id
/// @param address _clientWallet
/// @param bytes32 _name
/// @param bytes32 _homeAddress
/// @param bytes32 _birthday
/// @param uint256 _age
/// @param uint8 _gender: 0 = female, 1 = male
/// @param uint8 _education:  0 = none / 1 = ma / 2 = hs / 3 = college / 4 = masters
/// @param uint8 _householdSize
/// @param uint8 _dependents
/// @param bool _married
/// @param uint256 _phoneNumber
function createClient() {}

/// @dev Getter for client's contract address from clientList mapping
/// @param bytes32 _id: name + birthday unique identifier
function findClientAddress() returns(address) {}

/// @dev Creates a new Ballot for a list of proposals and stores in ballotAddresses mapping
/// @param bytes32[] _proposals
function createBallot() {}

/*
 *  Private Functions
 */

/// @dev Getter for Org
/// @dev Returns the Org object
/// @param uint256 _orgId
function getOrg() returns(Org) {}






/// Org.sol (aka org profile)

/*
 *  Storage
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

/// @dev Stores QuarterlyReport structs according to their id (year + quarter)
mapping (uint256 => QuarterlyReport) public quarterlyReportHistory;

/// @dev Stores an address of client with a loan pointed to by the clientId
mapping (bytes32 => address) public clientList;

/// @dev Stores a list of loans between a Client (based on clientId) and the Org
mapping (bytes32 => address[]) loanRepo;

GeneralInfo public orgInfo;
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
/// @param address _account
modifier onlyBy() {}


/*
 *  Public Functions
 */

/// @dev Constructor & Initializes certain counter variables
/// @param uint256 _id
/// @param bytes32 _name
/// @param bytes32 _hqAddress
/// @param bytes32 _country
/// @param bytes32 _currency
/// @param bytes32 _orgWallet
function Org() {}

/// @dev Getter for general info about Org
/// @dev Returns id, name, hqAddress, country, currency, orgWallet
function getGeneralInfo() returns (uint256,bytes32,bytes32,bytes32,bytes32,address {})

/// @dev Getter for quarterly reports
/// @dev Returns id, year, quarter, numOfOffices, numOfAgents, grossLoanPortfolio
///      numOfActiveBorrowers, grossDepositsPortfolio, numOfDepositors,
///      portfolioAtRisk30Days, writeOffRatio
/// @param uint256 _id: year + quarter
function getQuarterlyReport()
  returns (uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256) {}

/// @dev Add a quarterly report to profile
/// @param uint256 _id 
/// @param uint256 _year 
/// @param uint256 _quarter 
/// @param uint256 _numOfOffices 
/// @param uint256 _numOfAgents 
/// @param uint256 _grossLoanPortfolio 
/// @param uint256 _numOfActiveBorrowers 
/// @param uint256 _grossDepositsPortfolio 
/// @param uint256 _numOfDepositors 
/// @param uint256 _portfolioAtRisk30Days 
/// @param uint256 _writeOffRatio
function addQuarterlyReport() {}

/// @dev Getter for a Client's personal info based on their id (clientId)
/// @dev Returns clientWallet, name, homeAddress, birthday, age, gender, education
///      householdSize, dependents, married, phoneNumber
function getClientPersonalInfoById() 
  returns (address,bytes32,bytes32,bytes32,uint256,uint8,uint8,uint8,uint8,bool,uint256) {}

/// @dev Creates a new loan contract between Org & Client
/// @dev Stores clientAddress in clientList
/// @dev Stores loan address in loanRepo
/// @dev Adds the loan to the client's contract 
///      (so the client's profile has a reference to the loan address)
/// @param bytes32 _clientId
/// @param uint256 _amount: _amount should == _durationInMonths * _monthlyPayment
/// @param uint256 _durationInMonths
/// @param uint256 _monthlyPayment
/// @param bytes32 _startDate: "MM/DD/YYYY"
function createLoan() {}

/// @dev Getter for array of loans via _clientId from loanRepo mapping
/// @param bytes32 _clientId
function getLoansByClientId() returns(address) {}

/// @dev Adds a job to client's job history
/// @dev Returns bool
/// @param bytes32 _clientId
/// @param bytes32 _title
/// @param bytes32 _employer
/// @param bytes32 _workAddress
/// @param bytes32 _startDate: "MM/DD/YYYY"
/// @param bytes32 _endDate: "MM/DD/YYYY"
/// @param bytes32 _monthlySalary
function addJobToClientProfile() returns(bool) {}

/// @dev Updates grossClientDeposits - called from Client contract
/// @param uint256 _amount
/// @param bool _type
function updateGrossDeposits() {}

/// @dev Updates an already created Loan contract on whether a payment was made
/// @param address _loanAddress
/// @param bool _paymentMade
function updateLoanByAddress() {}

/*
 *  Private Functions
 */
/// @dev Getter for Client object via _clientId
/// @param bytes32 _clientId
function getclient() private returns(Client) {}

/// @dev Getter for Client address from Bureau via _clientId for search functionality
/// @ param bytes32 _clientId
function getClientAddressFromBureauById() private returns(address) {}

















/// Loan.sol (aka loann profile between an Org and Client)

/*
 *  Storage
 */
struct LoanInfo {
  uint256 amount;
  uint256 durationInMonths;
  uint256 monthlyPayment;
  bytes32 startDate;
}
enum Status { Started, Default, Complete }

/// @dev History of payments with currentPaymentCount pointing to whether paid or not
mapping (uint256 => bool) paymentHistory;

/// @dev General info about loan
LoanInfo public loanInfo;
Status public loanStatus;
/// @dev Two parties taking part in this loan
address public orgWallet;
address public clientWallet;
/// @dev For stats and calculating repayment rates
uint256 public currentPaymentCount;
uint256 public curentSuccessfulPayments;

/*
 *  Modifiers
 */
modifier onlyWithStatus(Status _loanStatus) {require(loanStatus == _loanStatus); _;}

/*
 *  Public Functions
 */
/// @dev Constructor & initiates certain storage variables
/// @param uint256 _amount
/// @param uint256 _durationInMonths
/// @param uint256 _monthlyPayment
/// @param bytes32 _startDate
/// @param address _orgWallet
/// @param address _clientWallet
function Loan() {}

/// @dev Getter for the current loanStatus
/// @dev Returns a string version of the current status
function getLoanStatus() returns(bytes32) {}

/// @dev Getter for Loan general info
/// @dev Returns amount, durationInMonths, monthlyPayment, startDate, orgWallet, clientWallet
function getLoanInfo() returns(uint256, uint256, uint256, bytes32, address, address) {}

/// @dev To add another payment update (paid/not paid) to the loan history
/// @dev Increments currentPaymentCount regardless
/// @dev Increments currentSuccessfulPayments if true
/// @param bool _paymentMade
function updateLoanPayment() {}

/// @dev Updates the loanStatus when a loan is completed
///      True if completed on time / False if it was late/default
/// @param bool _onTime
function finalizeLoan() {}

/*
 *  Private Functions
 */












/// Org.sol (aka org profile)

/*
 *  Storage
 */

/// @dev Org's id pointing to their address
/// @param

/*
 *  Public Functions
 */


/*
 *  Private Functions
 */
/// Org.sol (aka org profile)

/*
 *  Storage
 */

/// @dev Org's id pointing to their address
/// @param

/*
 *  Public Functions
 */


/*
 *  Private Functions
 */