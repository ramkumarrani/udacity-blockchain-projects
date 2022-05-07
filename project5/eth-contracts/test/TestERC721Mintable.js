var ERC721MintableComplete = artifacts.require('ERC721MintableComplete');

const truffleAssert = require("truffle-assertions");

contract('TestERC721Mintable', accounts => {
    const name = "RR_ERC721MintableToken";
    const symbol = "RRE721MT";

    const account_zero = accounts[0];
    const account_one = accounts[1];

    describe('match erc721 spec', function () {
        beforeEach(async function () { 
            this.contract = await ERC721MintableComplete.new(name, symbol, {from: account_zero});

            // TODO: mint multiple tokens
            await this.contract.mint(account_zero, 0, {from: account_zero});
            await this.contract.mint(account_one, 1, {from: account_zero});
            await this.contract.mint(account_zero, 2, {from: account_zero});
            await this.contract.mint(account_one, 3, {from: account_zero});
            await this.contract.mint(account_zero, 4, {from: account_zero});
            await this.contract.mint(account_one, 5, {from: account_zero});
        });

        it('should return total supply', async function () { 
            // const totalSupply = await this.contract.totalSupply.call({from: accounts[9]});
            const totalSupply = await this.contract.totalSupply.call();
            assert.equal(totalSupply.toNumber(), 6);
        })

        it('should get token balance', async function () { 
            const tokenBalance1 = await this.contract.balanceOf.call(account_zero);
            const tokenBalance2 = await this.contract.balanceOf.call(account_one);
            
            assert.equal(tokenBalance1, 3, "error: token balance1 is not in sync");
            assert.equal(tokenBalance2, 3, "error: token balance2 is not in sync");
        })

        // token uri should be complete i.e: https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/1
        it('should return token uri', async function () { 
            const myURI = "https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/1";
            const setURI = await this.contract.tokenURI.call(1);
            
            assert.equal(setURI, myURI, "error: URIs do not match");
        })

        it('should transfer token from one owner to another', async function () { 
            await this.contract.transferFrom(account_one, account_zero, 5, {from: account_one});
            const  newOwner = await this.contract.ownerOf.call(5);

            // console.log("====>>> new owner: " + newOwner)

            assert.equal(newOwner, account_zero, "error: owner transfer not complete");
        })
    });

    describe('have ownership properties', function () {
        beforeEach(async function () { 
            this.contract = await ERC721MintableComplete.new(name, symbol, {from: account_zero});
        });

        it('should fail when minting when address is not contract owner', async function() {
            let error;

            try {
                await this.contract.mint(account_one, 98, {from: accounts[7]});
            } catch (err) {
                error = err;
            }

            assert.notEqual(error, null, "only owner can call this");
        });

        it('should return contract owner', async function () { 
            const currOwner = await this.contract.getOwner.call();
            assert.equal(currOwner, account_zero, "error: not a right owner");
        });

    });
})