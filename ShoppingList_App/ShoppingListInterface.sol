pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "PurchaseStructs.sol";

interface ShoppingListInterface {
    function getShoppingList() external returns(Purchase[] purchases);
    function getPurchaseSummary() external returns(PurchaseSummary summary);
    function addPurchase(string title, uint amount) external;
    function removePurchase(uint id) external;
    function buy(uint id, uint price) external;
}