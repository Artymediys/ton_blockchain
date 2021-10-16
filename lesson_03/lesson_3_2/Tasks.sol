pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract Tasks {
    struct Task {
        string title;
        uint32 currentTime;
        bool isDone;
    }

    int8 private id;
    int8 private count;
    int8[] private tasksID;
    mapping(int8 => Task) private taskList;

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        
        id = 0;
        count = 0;
    }

    modifier verification {
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
		_;
	}

    function addTask(string taskTitle) public verification {
        require(!taskTitle.empty(), 103);
        Task task = Task(taskTitle, now, false);
        tasksID.push(id);
        taskList[id++] = task;
        count++;
    }

    function getCount() public verification returns(int8) {
        return count;
    }

    function getTaskList() public verification returns(int8[]) {
        return tasksID;
    }

    function getTaskInfo(int8 key) public verification returns(Task) {
        require(!taskList[key].title.empty(), 104);
        return taskList[key];
    }

    function removeTask(int8 key) public verification {
        require(!taskList[key].title.empty(), 104);

        uint tempID = 0;
        for (uint i = 0; i < tasksID.length; i++) {
            if (tasksID[i] == key) {
                tempID = i;
                break;
            }
        }

        for (uint i = tempID; i < tasksID.length - 1; i++) {
            tasksID[i] = tasksID[i + 1];
        }
        tasksID.pop();
        
        mapping(int8 => Task) refreshedTaskList;
        for (uint i = 0; i < tasksID.length; i++) {
            refreshedTaskList[tasksID[i]] = taskList[tasksID[i]];
        }
        taskList = refreshedTaskList;
        count--;
    }

    function setTaskComplete(int8 key) public verification {
        require(!taskList[key].title.empty(), 104);
        taskList[key].isDone = true;
    }
}
