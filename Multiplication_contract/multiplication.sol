pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract Multiplication {
	uint8 public result = 1;

	constructor() public {
		require(tvm.pubkey() != 0, 101);
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
	}

	modifier verification {
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
		_;
	}

	function mult(uint8 value) public verification {
        require(value >= 1 && value <= 10, 322);
		result *= value;
	}
}