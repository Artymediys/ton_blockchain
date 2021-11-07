pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "SL_InitDeBot.sol";

contract SL_DeBot is SL_InitDeBot {
    uint256 purchaseID;

    function start() public override {
        Terminal.input(tvm.functionId(savePublicKey), "Please enter your public key", false);
    }

    function _menu() private {
        ShoppingListInterface shoppingList = ShoppingListInterface(SL_Address);
        
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You have {}/{}/{} (count of not paid/count of paid/total) purchases",
                    purshSumm.countOfNotPaid,
                    purshSumm.countOfPaid,
                    purshSumm.countOfPaid + purshSumm.countOfNotPaid
            ),
            sep,
            [
                MenuItem("Buy", "", tvm.functionId(buy)),
                MenuItem("Show purchases", "", tvm.functionId(showPurchases)),
                MenuItem("Remove purchase", "", tvm.functionId(removePurchase))
            ]
        );
    }

    function buy(uint index) public {
        index = index;
        Terminal.input(tvm.functionId(buy_), "Please enter id of the purchase:", false);
    }

    function buy_(string value) public {
        (purchaseID,) = stoi(value);
        Terminal.input(tvm.functionId(buy__), "Please enter price of the purchase:", false);
    }

    function buy__(string value) public {
        (uint price,) = stoi(value);
        ShoppingListInterface(SL_Address).buy{
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: 0,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(onSuccess),
            onErrorId: 0
        }(purchaseID, price);
    }

    function showPurchases(uint index) public {
        index = index;
        ShoppingListInterface(SL_Address).getShoppingList{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: 0,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(showPurchases_),
            onErrorId: 0
        }();
    }

    function showPurchases_(Purchase[] purchases) public {
        if (purchases.length > 0) {
            Terminal.print(0, "Your shopping list:");

            string boughtStatus;
            for (uint i = 0; i < purchases.length; i++) {
                Purchase purchase = purchases[i];
                if (purchase.isBought) {
                    boughtStatus = "✓";
                } else {
                    boughtStatus = "x";
                }

                Terminal.print(0, format(
                    "{} {} {} {} {} {}", 
                    purchase.id, purchase.title, 
                    purchase.amount, purchase.createdAt, 
                    boughtStatus, purchase.price));
            }
        } else {
            Terminal.print(0, "You haven't bought anything yet!");
        }
        _menu();
    }

    function removePurchase(uint index) public {
        index = index;
        if (purshSumm.countOfPaid + purshSumm.countOfNotPaid > 0) {
            Terminal.input(tvm.functionId(removePurchase_), "Please enter id of the purchase:", false);
        } else {
            Terminal.print(0, "You have no purchases to remove!");
            _menu();
        }
    }

    function removePurchase_(string value) public {
        (uint id,) = stoi(value);
        ShoppingListInterface(SL_Address).removePurchase{
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: 0,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(onSuccess),
            onErrorId: 0
        }(id);
    }
}