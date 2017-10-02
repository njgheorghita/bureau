let Org = artifacts.require("./Org.sol");
let Client = artifacts.require("./Client.sol");
require("../node_modules/web3/packages/web3-utils/src/index.js");

contract('Org', function() {
  let org;
  let clientWallet;

  beforeEach(async function() {
    clientWallet = web3.eth.accounts[2];
    // create org
    org = await Org.new(
      123,              // id
      "MFI",            // name
      "111 First St.",  // hqAddress
      "USA",            // country
      "$"               // currency
    );
  });

  it('it instantiates correctly', async function() {
    let orgInfo = await org.getGeneralInfo();

    assert.equal(web3.toDecimal(orgInfo[0]), 123);
    assert.equal(web3.toAscii(orgInfo[1]).substring(0,3), "MFI");
    assert.equal(web3.toAscii(orgInfo[2]).substring(0,13), "111 First St.");
    assert.equal(web3.toAscii(orgInfo[3]).substring(0,3), "USA");
    assert.equal(web3.toAscii(orgInfo[4]).substring(0,1), "$");
  });

  it('can add a quarterly report', async function() {
    await org.addQuarterlyReport(
      20002,          // id: (yr) + (quarter)
      2000,           // year
      2,              // quarter
      3,              // number of offices
      15,             // number of agents
      15223334,       // gross loan portfolio
      342,            // number of active borrowers
      422233,         // gross deposits portfolio
      233,            // number of depositors
      333,            // % of portfolio at risk > 30 days ( * 100 )
      32              // write off ratio
    );

    let quarterlyReport = await org.getQuarterlyReport(20002);
    assert.equal(web3.toDecimal(quarterlyReport[0]), 20002);
    assert.equal(web3.toDecimal(quarterlyReport[1]), 2000);
    assert.equal(web3.toDecimal(quarterlyReport[2]), 2);
    assert.equal(web3.toDecimal(quarterlyReport[3]), 3);
    assert.equal(web3.toDecimal(quarterlyReport[4]), 15);
    assert.equal(web3.toDecimal(quarterlyReport[5]), 15223334);
    assert.equal(web3.toDecimal(quarterlyReport[6]), 342);
    assert.equal(web3.toDecimal(quarterlyReport[7]), 422233);
    assert.equal(web3.toDecimal(quarterlyReport[8]), 233);
    assert.equal(web3.toDecimal(quarterlyReport[9]), 333);
    assert.equal(web3.toDecimal(quarterlyReport[10]), 32);
  });

  context("with a client", async function() {
    beforeEach(async function() {
      await org.createClient(
        clientWallet,                       // Client wallet address
        "Client",                           // name
        "1234 5th Street, Denver CO 80218", // homeAddress
        "01/01/2000",                       // birthday
        100,                                // age
        0,                                  // gender
        4,                                  // education
        6,                                  // householdSize
        3,                                  // dependents
        false,                              // married
        5000,                               // monthlyHouseholdIncome
        2,                                  // numOfBusinesses
        5,                                  // numOfEmployees
        1231221323                          // phoneNumber
      )
    });

    it('can create a new client', async function() {
      let clientAddress = await org.getClientAddressById(1);
      let client = await Client.at(clientAddress);
      let personalInfo = await client.getPersonalInfo();

      assert.equal(personalInfo.length, 14)
      assert.equal(personalInfo[0], clientWallet);
    });

    it("only allows the orgWallet can create a new client", async function() {
      try {
        await org.createClient(web3.eth.accounts[3],"False","data","date",100,0,4,6,3,false,3,2,3,44, {from: web3.eth.accounts[4]})
      } catch(err) {
        assert.include(String(err), "invalid opcode");
      }
    });

    it("can add a loan to a clients profile", async function() {
      let clientAddress = await org.getClientAddressById(1);

      // client_id, loan_id, amount, startDate, endDate, interestRate (*100), numberOfPayments, status
      await org.addLoanToClientProfile(1, 12345, 100, "1/1/2000", "1/1/2001", 133, 12, true);

      let client = await Client.at(clientAddress);
      let loanHistory = await client.getLoan(12345);
      assert.equal(loanHistory.length, 7);
      assert.equal(web3.toDecimal(loanHistory[0]), 12345);
    });

    it("only allows the orgWallet to add loan to client", async function() {
      try {
        await org.addLoanToClientProfile(1, 12345, 100, "1/1/2000", "1/1/2001", 133, 12, true, {from: web3.eth.accounts[4]})
      } catch(err) {
        assert.include(String(err), "invalid opcode");
      }
    });

    it("can add a job to a clients profile", async function() {
      let clientAddress = await org.getClientAddressById(1);

      // clientId, title, employer, workAddress, startDate, endDate, monthlySalary
      await org.addJobToClientProfile(1, "Janitor", "Paddys", "Philadelphia", "1/1/2001", "1/1/2002", 1000);

      let client = await Client.at(clientAddress);
      let jobHistory = await client.getJob(1);
      assert.equal(jobHistory.length, 6);
      assert.equal(web3.toAscii(jobHistory[1]).substring(0,6), "Paddys");
    });
  
    it("only allows the orgWallet to add job to client", async function() {
      try {
        await org.addJobToClientProfile(1,"Janitor", "Paddys", "Philadelphia", "1/1/2001", "1/1/2002", 1000, {from: web3.eth.accounts[4]})
      } catch(err) {
        assert.include(String(err), "invalid opcode");
      }
    });
  });

  it("calculates the amount of savings/deposits it's clients hold", async function() {
    await org.createClient(web3.eth.accounts[5],"False","data","date",100,0,4,6,3,false,3,2,3,44)
    await org.createClient(web3.eth.accounts[6],"False","data","date",100,0,4,6,3,false,3,2,3,44)
    let clientAddress = await org.getClientAddressById(1);
    let otherClientAddress = await org.getClientAddressById(2);
    let firstClient = await Client.at(clientAddress);
    let secondClient = await Client.at(otherClientAddress);
    await firstClient.deposit({value: 100, from: web3.eth.accounts[5]});
    await secondClient.deposit({value: 100, from: web3.eth.accounts[6]});
    assert.equal(web3.toDecimal(web3.eth.getBalance(clientAddress)), 100);
    assert.equal(web3.toDecimal(web3.eth.getBalance(otherClientAddress)), 100);

    // is it better to store/update this as a variable or calculate it every time you need it?
    assert.equal(web3.toDecimal(await org.numberOfClients()), 2);
    let grossClientDeposits = await org.getGrossClientDeposits();
    // assert.equal(web3.toDecimal(grossClientDeposits), 200);
  }); 
});