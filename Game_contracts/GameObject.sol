pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "IGO.sol";

contract GameObject is IGO {
    uint8 internal _hp = 5;

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        tvm.accept();
    }

    modifier acceptance {
        tvm.accept();
        _;
    }

    function getHP() public acceptance returns(uint8) {
        return _hp;
    }

    function setHP (uint8 hp) public acceptance {
        require(hp >= 1 && hp <= 5, 201);
        _hp = hp;
    }

    function takeAttack(uint8 damage) external acceptance override {
        if (damage >= _hp) {
            _hp = 0;
            objKilled();
        } else {
            _hp -= damage;
        }
    }

    function isKilled() private acceptance returns (bool) {
        if (_hp == 0) {
            return true;
        } else {
            return false;
        }
    }

    function objKilled() virtual internal acceptance {
        require(isKilled() == true, 200);
        msg.sender.transfer(1, true, 160);
    }
}
