pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "ShoppingListInterface.sol";
import "HasConstructorWithPubkey.sol";

contract ShoppingList is ShoppingListInterface, HasConstructorWithPubkey {
    uint256 private owner;
    Purchase[] public purchases;
    PurchaseSummary public summary;

    constructor(uint256 pubkey) HasConstructorWithPubkey(pubkey) public {
        require(pubkey != 0, 102);
        tvm.accept();
        owner = pubkey;
    }

    modifier onlyOwner {
        require(msg.pubkey() == owner, 103);
        _;
    }

    function getShoppingList() external override returns(Purchase[]) {
        tvm.accept();
        return purchases;
    }

    function getPurchaseSummary() external override returns(PurchaseSummary) {
        tvm.accept();
        return summary;
    }

    function addPurchase(string title, uint256 amount) external override onlyOwner {
        tvm.accept();
        Purchase newPurchase = Purchase({
            id: purchases.length + 1,
            title: title,
            amount: amount,
            createdAt: now,
            isBought: false,
            price: 0
        });
        purchases.push(newPurchase);
    }

    function removePurchase(uint256 id) external override onlyOwner {
        tvm.accept();
        for (uint256 i = 0; i < purchases.length; i++) {
            if (i == id) {
                (purchases[id], purchases[purchases.length - 1]) = (purchases[purchases.length - 1], purchases[id]);
                purchases.pop();
            }
        }
    }

    function buy(uint256 id, uint256 price) external override onlyOwner {
        require(!purchases[id].isBought, 201);
        tvm.accept();
        purchases[id].isBought = true;
        purchases[id].price = price;
        summary.countOfPaid++;
        summary.countOfNotPaid = purchases.length - summary.countOfPaid;
        summary.paidPrice += price; 
    }
}