pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract ShopQueue {
    string[] public queue;

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

    function queueUp(string name) public verification {
        require(!name.empty(), 322);
        queue.push(name);
    }

    function nextInQueue() public verification {
        require(!queue.empty(), 123);
        for (uint i = 0; i < queue.length - 1; i++){
            queue[i] = queue[i + 1];
        }
        queue.pop();
    }
}