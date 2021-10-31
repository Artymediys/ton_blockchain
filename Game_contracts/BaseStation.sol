pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "GameObject.sol";

contract BaseStation is GameObject {
    address[] private militaryUnits;

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        tvm.accept();
    }

    function addMilitaryUnit(address unit) public acceptance {
        militaryUnits.push(unit);
    }

    function deleteMilitaryUnit(address unit) public acceptance {
        uint id = 0;
        for (; id < militaryUnits.length; id++) {
            if (militaryUnits[id] == unit) {
                break;
            }
        }

        for (uint i = id; i < militaryUnits.length - 1; i++){
            militaryUnits[i] = militaryUnits[i + 1];
        }
        militaryUnits.pop();
    }

    function objKilled() internal acceptance override {
        require(_hp == 0, 202);
        for (uint i = 0; i < militaryUnits.length; i++) {
            militaryUnits.pop();
        }
        msg.sender.transfer(1, true, 160);
    }
}
