let Client = artifacts.require("./Client.sol");
require("../node_modules/web3/packages/web3-utils/src/index.js");

contract('Client', function() {
  let client;
  let clientWallet;

  beforeEach(async function() {
    clientWallet = web3.eth.accounts[1]
    // create client
    client = await Client.new(
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
      1231221323                          // phoneNumber
      );
  });

  it('is instantiated properly', async function() {
    let numOfJobs = await client.numberOfJobs();
    let personalInfo = await client.getPersonalInfo();
    let clientWalletAddress = await client.clientWallet();
    let orgWalletAddress = await client.orgWallet();

    assert.equal(web3.toDecimal(numOfJobs), 0);
    assert.equal(personalInfo.length, 11)
    assert.equal(clientWalletAddress, clientWallet);
    assert.equal(orgWalletAddress, web3.eth.accounts[0]);
  });

  it('returns client personal data properly', async function() {
    let personalInfo = await client.getPersonalInfo();

    assert.equal(personalInfo.length, 11)
    assert.equal(personalInfo[0], clientWallet);
    assert.equal(web3.toAscii(personalInfo[1]).substring(0,6), "Client");
    assert.equal(web3.toAscii(personalInfo[2]).substring(
      0,32), "1234 5th Street, Denver CO 80218");
    assert.equal(web3.toAscii(personalInfo[3]).substring(0,10), "01/01/2000");
    assert.equal(web3.toDecimal(personalInfo[4]), 100);
    assert.equal(web3.toDecimal(personalInfo[5]), 0);
    assert.equal(web3.toDecimal(personalInfo[6]), 4);
    assert.equal(web3.toDecimal(personalInfo[7]), 6);
    assert.equal(web3.toDecimal(personalInfo[8]), 3);
    assert.equal(personalInfo[9], false);
    assert.equal(web3.toDecimal(personalInfo[10]), 1231221323);
  });

  it('can add a loan to the profile', async function() {
    let addLoan = await client.addLoan(
      12345,          // id
      100,            // amount
      "01/01/2000",   // start date
      "01/01/2001",   // end date
      1200,           // interest rate * 100
      12,             // number of payments
      true            // status 
    )

    let loanHistory = await client.getLoan(12345);
    assert.equal(loanHistory.length, 7);
    assert.equal(web3.toDecimal(loanHistory[0]), 12345);
    assert.equal(web3.toDecimal(loanHistory[1]), 100);
    assert.equal(web3.toAscii(loanHistory[2]).substring(0,10), "01/01/2000");
    assert.equal(web3.toAscii(loanHistory[3]).substring(0,10), "01/01/2001");
    assert.equal(web3.toDecimal(loanHistory[4]), 1200);
    assert.equal(web3.toDecimal(loanHistory[5]), 12);
    assert.equal(loanHistory[6], true);
  });

  it('only allows org to add loan to profile', async function() {
    try {
      await client.addLoan(
        12345, 100, "01/01/2000", "01/01/2001", 1200, 12, true, {from: web3.eth.accounts[5]}
      )
    } catch(err) {
      assert.include(String(err), "invalid opcode");
    }
  })

  it('can calculate the loan repayment rate', async function() {
    await client.addLoan(1,100,"01/01/2000","01/01/2001",1200,12,true);
    await client.addLoan(2,100,"01/01/2000","01/01/2001",1200,12,false);
    await client.addLoan(3,100,"01/01/2000","01/01/2001",1200,12,false);
    
    // returns uint = successful loans, uint = loanCount
    let getRateVariables = await client.getLoanRepaymentRate();
    let a = web3.toDecimal(getRateVariables[0]);
    let b = web3.toDecimal(getRateVariables[1]);
    assert.equal(Math.round((a/b)*1000), 333);
  });

  it('can add a job to the profile', async function() {
    let addJob = await client.addJob(
      "Baker",        // title
      "My Bakery",    // Employer
      "11 First St.", // work address
      "01/01/2000",   // start date
      "01/01/2001",   // end date
      100             // monthly salary
    )

    let jobHistory = await client.getJob(1);
    assert.equal(web3.toAscii(jobHistory[0]).substring(0,5), "Baker");
    assert.equal(web3.toAscii(jobHistory[1]).substring(0,9), "My Bakery");
    assert.equal(web3.toAscii(jobHistory[2]).substring(0,12), "11 First St.");
    assert.equal(web3.toAscii(jobHistory[3]).substring(0,10), "01/01/2000");
    assert.equal(web3.toAscii(jobHistory[4]).substring(0,10), "01/01/2001");
    assert.equal(web3.toDecimal(jobHistory[5]), 100);
  });

  it('only allows org to add job to profile', async function() {
    try {
      await client.addJob(
        "Baker", "My Bakery", "11 First St.", "1/1/2001", "1/1/2002", 100, {from: web3.eth.accounts[5]}
      )
    } catch(err) {
      assert.include(String(err), "invalid opcode");
    }
  })

  it('can deposit multiple savings to the contract', async function() {
    await client.deposit({value: 100, from: clientWallet});
    let firstDeposit = await client.getSavingsTx(1);

    assert.equal(web3.eth.getBalance(client.address), 100);
    assert.equal(web3.toDecimal(firstDeposit[0]), 100);
    assert.equal(firstDeposit[2], true);
  });

  it('only allows client to deposit to contract', async function() {
    try {
      await client.deposit({value: 100});
    } catch(err) {
      assert.include(String(err), "invalid opcode");
    }
  });

  it('deposit checks that value sent with tx is > 0', async function() {
    try {
      await client.deposit({value: 0, from: clientWallet});
    } catch(err) {
      assert.include(String(err), "invalid opcode");
    }
  });

  it('only allows the client to extract funds', async function() {
    await client.deposit({value: 100, from: clientWallet});
    await client.withdrawFunds(50, {from: clientWallet});
    let numberOfSavingsTxs = await client.numberOfSavingsTxs();
    assert.equal(web3.toDecimal(numberOfSavingsTxs), 2);
    assert.equal(web3.eth.getBalance(client.address), 50);
    try {
      await client.withdrawFunds(5);
    } catch(err) {
      assert.include(String(err), "invalid opcode");
    }
  });
});