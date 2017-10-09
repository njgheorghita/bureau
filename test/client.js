let Client = artifacts.require("./Client.sol");
require("../node_modules/web3/packages/web3-utils/src/index.js");

contract('Client', function() {
  let client;
  let clientWallet;

  beforeEach(async function() {
    clientWallet = web3.eth.accounts[1]
    // create client
    client = await Client.new(
      12345,                              // id
      clientWallet,                       // Client wallet address
      "Client",                           // name
      "1234 5th Street",                  // homeAddress
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
    let personalInfo = await client.getPersonalInfo();
    let clientWalletAddress = await client.clientWallet();

    assert.equal(personalInfo.length, 11)
    assert.equal(clientWalletAddress, clientWallet);
  });

  it('returns client personal data properly', async function() {
    let personalInfo = await client.getPersonalInfo();

    assert.equal(personalInfo.length, 11)
    assert.equal(personalInfo[0], clientWallet);
    assert.equal(web3.toAscii(personalInfo[1]).substring(0,6), "Client");
    assert.equal(web3.toAscii(personalInfo[2]).substring(0,15), "1234 5th Street");
    assert.equal(web3.toAscii(personalInfo[3]).substring(0,10), "01/01/2000");
    assert.equal(web3.toDecimal(personalInfo[4]), 100);
    assert.equal(web3.toDecimal(personalInfo[5]), 0);
    assert.equal(web3.toDecimal(personalInfo[6]), 4);
    assert.equal(web3.toDecimal(personalInfo[7]), 6);
    assert.equal(web3.toDecimal(personalInfo[8]), 3);
    assert.equal(personalInfo[9], false);
    assert.equal(web3.toDecimal(personalInfo[10]), 1231221323);
  });

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