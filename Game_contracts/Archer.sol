pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "MilitaryUnit.sol";

contract Archer is MilitaryUnit {
    constructor(BaseStation obj) public {
        require(tvm.pubkey() != 0, 101);
        tvm.accept();
        
        baseStation = obj;
        unitAddr = address(this);
        baseStation.addMilitaryUnit(unitAddr);
    }
}
