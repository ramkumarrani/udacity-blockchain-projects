// Importing the StartNotary Smart Contract ABI (JSON representation of the Smart Contract)
const StarNotary = artifacts.require("StarNotary");

var accounts; // List of development accounts provided by Truffle
var owner; // Global variable use it in the tests cases

// This called the StartNotary Smart contract and initialize it
contract('StarNotary', (accs) => {
    accounts = accs; // Assigning test accounts
    owner = accounts[0]; // Assigning the owner test account
});

// unit test case: for createStar() function
it('Can create a star', async() => {
    let tokenId = 1;
    let instance = await StarNotary.deployed();

    // creating a star
    await instance.createStar('Awesome Star', tokenId, {from: owner} );
    let thisStar = await instance.tokenIdToStarInfo.call(tokenId);

    // asserting
    assert.equal(thisStar, 'Awesome Star');
});

// unit test case: user1 to put up the star for sale
it('lets user1 put up the star for sale', async() => {
    let instance = await StarNotary.deployed();
    let user1 = accounts[1];
    let starId = 2;
    let starPrice = web3.utils.toWei(".02", "ether");

    // creating a star and putting it for sale
    await instance.createStar('awesome star', starId, {from: user1});
    await instance.putStarUpForSale(starId, starPrice, {from: user1});
    let thisPrice = await instance.starsForSale.call(starId);

    // asserting
    assert.equal(thisPrice, starPrice);
});

it('lets user1 get the funds after the sale', async() => {
    let instance = await StarNotary.deployed();
    let user1 = accounts[8];
    let user2 = accounts[9];
    let starId = 3;
    let starPrice = web3.utils.toWei(".01", "ether");
    let balance = web3.utils.toWei(".05", "ether");
    await instance.createStar('awesome star', starId, {from: user1});
    await instance.putStarUpForSale(starId, starPrice, {from: user1});
    let balanceOfUser1BeforeTransaction = await web3.eth.getBalance(user1);

    // approve the ownership change
    await instance.approve(user2, starId, {from: user1});
    await instance.buyStar(starId, {from: user2, value: balance});
    let balanceOfUser1AfterTransaction = await web3.eth.getBalance(user1);
    let value1 = Number(balanceOfUser1BeforeTransaction) + Number(starPrice);
    let value2 = Number(balanceOfUser1AfterTransaction);

    // asserting
    assert.equal(value1, value2);
});

// unit test case - verify if the ownership is changed for a star
it('lets user2 buy a star, if it is put up for sale', async() => {
    let instance = await StarNotary.deployed();
    let user1 = accounts[1];
    let user2 = accounts[2];
    let starId = 4;
    let starPrice = web3.utils.toWei(".01", "ether");
    let balance = web3.utils.toWei(".05", "ether");
    await instance.createStar('awesome star test case4', starId, {from: user1});
    await instance.putStarUpForSale(starId, starPrice, {from: user1});
    await instance.approve(user2, starId, {from: user1});
    await instance.buyStar(starId, {from: user2, value: balance});
    let newOwner = await instance.ownerOf.call(starId);
    assert.equal(newOwner, user2);
});

// unit test case - checking the balance after buy a star
it('lets user2 buy a star and see if the balance is decreasing', async() => {
    let instance = await StarNotary.deployed();
    let user1 = accounts[8];
    let user2 = accounts[9];
    let starId = 5;
    let starPrice = web3.utils.toWei(".01", "ether");
    let balance = web3.utils.toWei(".05", "ether");
    await instance.createStar('awesome star test case5', starId, {from: user1});
    await instance.putStarUpForSale(starId, starPrice, {from: user1});
    await instance.approve(user2, starId, {from: user1});
    let balanceOfUser2BeforeTransaction = await web3.eth.getBalance(user2);
    await instance.buyStar(starId, {from: user2, value: balance, gasPrice: 20000})
    let balanceOfUser2AfterTransaction = await web3.eth.getBalance(user2);
    let value = Number(balanceOfUser2BeforeTransaction) - Number(balanceOfUser2AfterTransaction);
    assert.equal(value, starPrice);
    assert.equal(balanceOfUser2BeforeTransaction, balanceOfUser2AfterTransaction);
});

// Implement Task 2 Add supporting unit tests

it('can add the star name and star symbol properly', async() => {
    // 1. create a Star with different tokenId
    // 2. Call the name and symbol properties in your Smart Contract and compare with the name and symbol provided
    let tokenId = 11;
    let instance = await StarNotary.deployed();
    await instance.createStar('aquarius', tokenId, {from: owner} );
    let thisStar = await instance.tokenIdToStarInfo.call(tokenId);

    // asserting
    assert.equal(thisStar, 'aquarius');
    assert.equal(await instance.starName.call(), 'Star Token Project2');
    assert.equal(await instance.starSymbol.call(), 'ST2');
});

it('lets 2 users exchange stars', async() => {
    // 1. create 2 Stars with different tokenId
    // 2. Call the exchangeStars functions implemented in the Smart Contract
    // 3. Verify that the owners changed
    let tokenId1 = 12;
    let tokenId2 = 13;
    let instance = await StarNotary.deployed();

    // create 2 stars
    await instance.createStar('Awesome Star1', tokenId1, {from: owner} );
    await instance.createStar('Awesome Star2', tokenId2, {from: accounts[1]});
    
    // approve new star owners
    await instance.approve(accounts[1], tokenId1, {from: owner});
    await instance.approve(owner, tokenId2, {from: accounts[1]});

    // exchange stars ownerships
    await instance.exchangeStars(tokenId1, tokenId2, {from: owner});
    
    // identify new owners
    let newOwner1 = await instance.ownerOf.call(tokenId1);
    let newOwner2 = await instance.ownerOf.call(tokenId2);

    // asserting
    assert.equal(newOwner1, accounts[1]);
    assert.equal(newOwner2, accounts[0]);
});

it('lets a user transfer a star', async() => {
    // 1. create a Star with different tokenId
    // 2. use the transferStar function implemented in the Smart Contract
    // 3. Verify the star owner changed.
    let tokenId1 = 21;
    let instance = await StarNotary.deployed();

    // create a star
    await instance.createStar('leo', tokenId1, {from: owner} );
    assert.equal(await instance.ownerOf.call(tokenId1), owner);

    // call transferStar to transfer token ownership to a new owner
    await instance.transferStar(accounts[1], tokenId1, {from: owner});

    // asserting
    assert.equal(await instance.ownerOf.call(tokenId1), accounts[1]);
});

it('lookUptokenIdToStarInfo test', async() => {
    // 1. create a Star with different tokenId
    // 2. Call your method lookUptokenIdToStarInfo
    // 3. Verify if you Star name is the same

    let tokenId = 31;
    let instance = await StarNotary.deployed();

    // create a star
    await instance.createStar('neptune', tokenId, {from: owner} );
    assert.equal(await instance.ownerOf.call(tokenId), owner);

    let starName = await instance.lookUptokenIdToStarInfo.call(tokenId);

    // asserting
    assert.equal(starName, 'neptune');
}); 