pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "GameObject.sol";
import "BaseStation.sol";


// !!!!!This contract only for use as a template for child contracts!!!!!
contract MilitaryUnit is GameObject {
    uint8 internal dmg; 

    address internal unitAddr;
    BaseStation internal baseStation;

    // Constructor implemented in child contracts, 
    // because if you give arguments to the parent constructor, 
    // there was an error in the child contracts asking to make them abstract.

    function getDMG() public acceptance returns(uint8) {
        return dmg;
    }

    function setDMG(uint8 damage) public acceptance {
        require(damage >= 1 && damage <= 5, 203);
        dmg = damage;
    }

    function attack(IGO addr) public acceptance {
        addr.takeAttack(dmg);
    }

    function objKilled() internal acceptance override {
        require(_hp == 0, 202);
        baseStation.deleteMilitaryUnit(unitAddr);
        msg.sender.transfer(1, true, 160);
    }
}
