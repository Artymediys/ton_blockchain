pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract NFT_Phone {
    struct Phone {
        string title;
        string color;
        uint year;
    }

    Phone[] phones;
    uint[] prices;

    string firstPhoneTitle;

    mapping(string => uint) phoneTitleToID;
    mapping(uint => uint) phoneToOwner;

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        tvm.accept();
    }

    function createPhone(string title, string color, uint year) public {
        require(phoneTitleToID[title] == 0 && firstPhoneTitle != title, 102);
        tvm.accept();
        
        if (phones.length == 0) { firstPhoneTitle = title; }
        phones.push(Phone(title, color, year));
        prices.push(0);
        uint id = phones.length - 1;
        phoneTitleToID[title] = id;
        phoneToOwner[id] = msg.pubkey();
    }

    function setPhonePrice(uint phoneID, uint price) public {
        require(msg.pubkey() == phoneToOwner[phoneID], 103);
        tvm.accept();

        prices[phoneID] = price;
    }

    function getPhoneOwner(uint phoneID) public returns (uint) {
        tvm.accept();
        return phoneToOwner[phoneID];
    }

    function getPhoneInfo(uint phoneID) public 
    returns (string phoneTitle, string phoneColor, uint phoneYear) {
        tvm.accept();

        phoneTitle = phones[phoneID].title;
        phoneColor = phones[phoneID].color;
        phoneYear = phones[phoneID].year;
    }

    // function "selling" soon...
}
