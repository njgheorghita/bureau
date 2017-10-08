let Ballot = artifacts.require("./Ballot.sol");

require("../node_modules/web3/packages/web3-utils/src/index.js");

contract('Ballot', function() {
  let ballot;

  beforeEach(async function() {
    ballot = await Ballot.new();
    clientWallet = web3.eth.accounts[0]    
  });

  it('instantiates correctly', async function() {
    let ballotOwner = await ballot.chairperson();
    assert.equal(web3.eth.accounts[0], ballotOwner)    
  });

  it('can add a 3 option proposal', async function() {
    await ballot.addProposal('More Stuff');
    await ballot.addProposal('More Things');
    await ballot.voteFor(0);
    await ballot.voteFor(0);
    await ballot.voteAgainst(0);
    await ballot.voteFor(1);
    await ballot.voteAgainst(1);
    await ballot.voteAgainst(1);
    await ballot.voteAgainst(1);
    await ballot.voteFor(1);

    let proposalData = await ballot.proposalNames(0);
    assert.equal(web3.toAscii(proposalData).substring(0,10), 'More Stuff');
  })
})