pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

abstract contract HasConstructorWithPubkey { 
    constructor(uint pubkey) public {}
}