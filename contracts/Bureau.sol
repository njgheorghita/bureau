pragma solidity 0.4.15;
import "./Org.sol";
import "./Client.sol";
import "./Ballot.sol";

/// @title Bureau contract - creates a bureau to manage orgs & borrowers
/// @author Nick Gheorghita - <nickgheorghita@gmail.com>
contract Bureau {

    /*
     *  Storage
     */
    /// @dev Org's id pointing to their address
    mapping ( uint256 => address ) public orgList;

    /// @dev Stores org addresses to auth for Ballot.sol
    address[] orgAddresses;

    /// @dev Wallet address that controls the bureau
    address public ownerAddress;

    /// @dev Address for the ballot containing all proposals & votes
    address public ballotAddress;

    /// @dev Client id ("Name" + "-" + "Birthday") pointing to their profile address
    mapping (bytes32 => address) public clientList;
    bytes32[] public clientIds;

    /// @dev Stores array of all created ballot addresses
    address[] public ballotAddresses;

    /*
     *  Fallback Function
     */ 
    function () payable { revert(); }

    /*
     *  Public Functions
     */
    /// @dev Constructor sets ownerAddress and creates a new Ballot contract
    function Bureau () {
        ownerAddress = msg.sender;
        ballotAddress = new Ballot();
    }

    /// @dev Creates and adds an org to the Bureau (both orgList and orgAddresses)
    // @param uint256 _id
    // @param bytes32 _name
    // @param bytes32 _hqAddress
    // @param bytes32 _country
    // @param bytes32 _currency
    // @param uint256 _orgWallet
    function addOrgToBureau
    (
        uint256 _id,
        bytes32 _name,
        bytes32 _hqAddress,
        bytes32 _country,
        bytes32 _currency,
        address _orgWallet
    ) {
        address newOrgAddress = new Org(
            _id, _name, _hqAddress, _country, _currency, _orgWallet
        );
        orgList[_id] = newOrgAddress;
        orgAddresses.push(newOrgAddress);
    }

    /// @dev Getter for number of clients: used by Controller.sol
    function getNumberOfClients() 
        constant 
        returns (uint) 
    {
        return clientIds.length;
    }

    /// @dev Getter for all org info to display on front end
    /// @dev Returns: id[], name[], hqAddress[], country[], currency[], orgWallet[], numberOfClients[], totalLoans[], totalSuccess[]
    function getAllOrgInfo()
        constant
        returns (uint256[], bytes32[], bytes32[], uint256[], uint256[], uint256[])
    {
        uint length = orgAddresses.length;

        uint256[] memory ids = new uint256[](length);
        bytes32[] memory names = new bytes32[](length);
        bytes32[] memory countries = new bytes32[](length);
        uint256[] memory clientNumbers = new uint256[](length);
        uint256[] memory clientTotalLoans = new uint256[](length);
        uint256[] memory clientTotalSuccess = new uint256[](length);
        for (uint i = 0; i < orgAddresses.length; i++) {
            Org currentOrg = Org(orgAddresses[i]);
            ids[i] = currentOrg.orgId();
            names[i] = currentOrg.orgName();
            countries[i] = currentOrg.orgCountry();
            clientNumbers[i] = currentOrg.numberOfClients();
            clientTotalLoans[i] = currentOrg.totalClientPayments();
            clientTotalSuccess[i] = currentOrg.totalSuccessfulClientPayments();
        }
        return (ids, names, countries, clientNumbers, clientTotalLoans, clientTotalSuccess);
    }

    /// @dev Getter for controller to return org details
    /// @dev Returns: numberOfClients, grossDeposits, totalSuccessfulPayments, totalPayments
    function getOrgDetailsById(uint256 _id)
        constant
        returns (uint256,uint256,uint256,uint256) 
    {
        Org currentOrg = getOrg(_id);
        return currentOrg.getDetailedInfo();
    }

    /// @dev Getter for the General Info (org.getGeneralInfo()) from an Org's contract
    /// @dev Returns id, name, hqAddress, country, currency, orgWallet
    // @param uint256 _id
    function getOrgInfoById(uint256 _id) 
      constant 
      returns (address, uint256, bytes32, bytes32, bytes32, bytes32, address)
    {
      Org currentOrg = getOrg(_id);
      return currentOrg.getGeneralInfo();
    }

    function getOrgAddressById(uint256 _id) 
        constant 
        returns (address) 
    {
        return orgList[_id];
    }

    /// @dev Creates a new client, increments numberOfClients, and stores contract address in 
    ///      clientList being pointed to by the input _id (aka client id: name + '-' + birthday)
    // @param bytes32 _id
    // @param address _clientWallet
    // @param bytes32 _name
    // @param bytes32 _homeAddress
    // @param bytes32 _birthday
    // @param uint256 _age
    // @param uint8 _gender: 0 = female, 1 = male
    // @param uint8 _education:  0 = none / 1 = ma / 2 = hs / 3 = college / 4 = masters
    // @param uint8 _householdSize
    // @param uint8 _dependents
    // @param bool _married
    // @param uint256 _phoneNumber
    function createClient
    (
      bytes32 _id,
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
      uint256 _phoneNumber
    ) {
      address newClientAddress = new Client(
        _id,
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
        _phoneNumber
      );
      clientIds.push(_id);
      clientList[_id] = newClientAddress;
    }

    /// @dev Getter for client's contract address from clientList mapping
    // @param bytes32 _id: name + birthday unique identifier
    function findClientAddress(bytes32 _id) 
        constant 
        returns (address) 
    {
        require(clientList[_id] != 0x0);
        return clientList[_id];
    }

    /*
    *  Private Functions
    */
    /// @dev Getter for Org
    /// @dev Returns the Org object
    // @param uint256 _orgId
    function getOrg(uint256 _orgId) 
        private 
        returns (Org) 
    {
        address currentOrgAddress = orgList[_orgId];
        Org currentOrg = Org(currentOrgAddress);
        return currentOrg;
    }
}