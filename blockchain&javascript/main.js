const SHA256 = require('crypto-js');

class Block {
    constructor(index, data, previousHash = ''){
        this.index = index;
        this.date = new Date();
        this.data = data;
        this.previousHash = previousHash;
        this.hash = this.createHash();
        this.nonce = 0;
    }

    createHash(){
        return SHA256.HmacSHA256('', this.index + this.date + this.data + this.previousHash + this.nonce).toString();
    }

    mine(difficulty){
        while(!this.hash.startsWith(difficulty)) {
            this.nonce++;
            this.hash = this.createHash();
        }
    }
}

class BlockChain {
    constructor(genesis, difficulty = '00'){
        this.chain = [this.createFirstBlock(genesis)]
        this.difficulty = difficulty;
    }

    createFirstBlock(genesis){
        return new Block(0, genesis);
    }

    getLastBlock(){
        return this.chain[this.chain.length-1]
    }

    addBlock(data){
        let prevBlock = this.getLastBlock();
        let block = new Block(prevBlock.index + 1, data, prevBlock.hash);
        block.mine(this.difficulty);
        console.log('minado! ' + block.hash + ' con nonce ' + block.nonce)
        this.chain.push(block);
    }

    isValid(){
        for(let i=1; i < this.chain.length; i++){
            let prevBlock = this.chain[i-1];
            let currBlock = this.chain[i];

            if(currBlock.previousHash !== prevBlock.hash)
                return false;

            if(currBlock.createHash() == currBlock.hash)
                return false;
        }
        return true;
    }
}

//block = new Block(0, 'prueba');
//console.log(JSON.stringify(block, null, 2));

let naniCoin = new BlockChain('info nashe', '00');
naniCoin.addBlock('facilito a casa pete');
naniCoin.addBlock('4k 4k 4k 4k');

console.log(naniCoin.isValid());
naniCoin.chain[1].data = 'fake data';
console.log(naniCoin.isValid());

//console.log(JSON.stringify(naniCoin.chain, null, 2))