let Bureau = artifacts.require("./Bureau.sol");
let Client = artifacts.require("./Client.sol");

require("../node_modules/web3/packages/web3-utils/src/index.js");

contract('Bureau', function() {
  let bureau;
  let clientWallet;

  beforeEach(async function() {
    bureau = await Bureau.new();
    clientWallet = web3.eth.accounts[2]
  });

  it('it instantiates correctly', async function() {
    let bureauOwner = await bureau.ownerAddress();

    assert.equal(web3.eth.accounts[0], bureauOwner)
  });

  it('it can add an org to the bureau', async function() {
    await bureau.addOrgToBureau(
      123,                // id
      "MFI",              // name
      "111 First St.",    // hqAddress
      "USA",              // country
      "USD",              // currency
      web3.eth.accounts[5]
    );

    let newOrg = await bureau.getOrgInfoById(123);
    assert.equal(newOrg[0], 123);
  });

  context("with a client", async function() {
    beforeEach(async function() {
      await bureau.createClient(
        12345,                              // id
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
    )});

    it('can create a new client', async function() {
      let clientAddress = await bureau.getClientAddressById(12345);
      let clientContract = await Client.at(clientAddress);
      let clientContractWallet = await clientContract.clientWallet();

      assert.equal(clientContractWallet, clientWallet);
    });


    // it("can add a job to a clients profile", async function() {
    //   let clientAddress = await org.getClientAddressById(1);

    //   // clientId, title, employer, workAddress, startDate, endDate, monthlySalary
    //   await org.addJobToClientProfile(1, "Janitor", "Paddys", "Philadelphia", "1/1/2001", "1/1/2002", 1000, {from: orgWallet});

    //   let client = await Client.at(clientAddress);
    //   let jobHistory = await client.getJob(1);
    //   assert.equal(jobHistory.length, 6);
    //   assert.equal(web3.toAscii(jobHistory[1]).substring(0,6), "Paddys");
    // });
  
    // it("only allows the orgWallet to add job to client", async function() {
    //   try {
    //     await org.addJobToClientProfile(1,"Janitor", "Paddys", "Philadelphia", "1/1/2001", "1/1/2002", 1000, {from: web3.eth.accounts[4]})
    //   } catch(err) {
    //     assert.include(String(err), "invalid opcode");
    //   }
    // });
  });
});