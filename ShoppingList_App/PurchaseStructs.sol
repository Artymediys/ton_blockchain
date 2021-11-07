pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

struct Purchase {
    uint id;
    string title;
    uint amount;
    uint createdAt;
    bool isBought;
    uint price;
}

struct PurchaseSummary {
    uint countOfPaid;
    uint countOfNotPaid;
    uint paidPrice;
}