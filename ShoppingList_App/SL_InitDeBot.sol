pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "ProjectBasis/Debot.sol";
import "ProjectBasis/Terminal.sol";
import "ProjectBasis/Menu.sol";
import "ProjectBasis/AddressInput.sol";
import "ProjectBasis/ConfirmInput.sol";
import "ProjectBasis/Upgradable.sol";
import "ProjectBasis/Sdk.sol";

import "Transactable.sol";
import "ShoppingListInterface.sol";
import "HasConstructorWithPubkey.sol";

// SL - ShoppingList
abstract contract SL_InitDeBot is Debot, Upgradable {
    TvmCell SL_Code;
    TvmCell SL_Data;
    TvmCell SL_StateInit;

    address SL_Address;
    uint userPubKey;
    address userWalletAddress;
    uint32 INITIAL_BALANCE = 200000000;

    PurchaseSummary purshSumm;

    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "ShoppingList Debot";
        version = "0.1";
        publisher = "Pletnyov Artyom";
        key = "ShoppingList manager";
        author = "Pletnyov Artyom";
        support = address.makeAddrStd(0, 0xd1283075b576a199597ed60f55feaa1ca40349c1058f421529d76330764a0b4e);
        hello = "Hello, i'm a shopping list debot!";
        language = "en";
        dabi = m_debotAbi.get();
        icon = "";
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [Terminal.ID, Menu.ID, AddressInput.ID, ConfirmInput.ID];
    }

    function setShoppingListCode(TvmCell code, TvmCell data) public {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();

        SL_Code = code;
        SL_Data = data;
        SL_StateInit = tvm.buildStateInit(SL_Code, SL_Data);
    }

    function savePublicKey(string pkey) public {
        (uint res, bool status) = stoi("0x" + pkey);
        if (status) {
            userPubKey = res;
            Terminal.print(0, "Checking if you already have a shopping list ...");
            TvmCell deployState = tvm.insertPubkey(SL_StateInit, userPubKey);
            SL_Address = address.makeAddrStd(0, tvm.hash(deployState));

            Terminal.print(0, format("Info: your ShoppingList contract address is {}", SL_Address));
            Sdk.getAccountType(tvm.functionId(checkStatus), SL_Address);
        } else {
            Terminal.input(
                tvm.functionId(savePublicKey), 
                "Wrong public key. Please enter your public key again", 
                false);
        }
    }
    
    function checkStatus(int8 acc_type) public {
        if (acc_type == 1) {
            _getSummary(tvm.functionId(setSummary));
        } else if (acc_type == -1) {
            Terminal.print(0, "You don't have a shopping list yet, so a new contract with an initial balance of 0.2 tokens will be deployed");
            AddressInput.get(tvm.functionId(creditAccount), "Select a wallet for payment. We will ask you to sign two transactions");
        } else if (acc_type == 0) {
            Terminal.print(0, format(
                "Deploying new contract. If an error occurs, check if your ShoppingList contract has enough tokens on its balance"));
            deploy();
        } else if (acc_type == 2) {
            Terminal.print(0, format("Can not continue: account {} is frozen", SL_Address));
        }
    }

    function creditAccount(address value) public {
        userWalletAddress = value;
        optional(uint256) pubkey;
        TvmCell empty;

        Transactable(userWalletAddress).sendTransaction {
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(waitBeforeDeploy),
            onErrorId: tvm.functionId(onErrorRepeatCredit)
        }(SL_Address, INITIAL_BALANCE, false, 3, empty);
    }

    function waitBeforeDeploy() public {
        Sdk.getAccountType(tvm.functionId(checkIfDeployed), SL_Address);
    }

    function checkIfDeployed(int8 acc_type) public {
        if (acc_type == 0) {
            deploy();
        } else {
            waitBeforeDeploy();
        }
    }

    function deploy() private view {
        TvmCell image = tvm.insertPubkey(SL_StateInit, userPubKey);
        optional(uint256) none;

        TvmCell deployMsg = tvm.buildExtMsg({
            abiVer: 2,
            dest: SL_Address,
            callbackId: tvm.functionId(onSuccess),
            onErrorId: tvm.functionId(onErrorRepeatDeploy),
            time: 0,
            expire: 0,
            sign: true,
            pubkey: none,
            stateInit: image,           
            call: {HasConstructorWithPubkey,  userPubKey}
        });
        tvm.sendrawmsg(deployMsg, 1);
    }

    function setSummary(PurchaseSummary summary)  public {
        purshSumm = summary;
        _menu();
    }

    function _getSummary(uint32 answerId) private view {
        optional(uint256) none;
        ShoppingListInterface(SL_Address).getPurchaseSummary{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: answerId,
            onErrorId: 0
        }();
    }

    function onSuccess() public {
        _getSummary(tvm.functionId(setSummary));
    }

    function onErrorRepeatCredit(uint32 sdkError, uint32 exitCode) public {
        creditAccount(userWalletAddress);
    }

    function onErrorRepeatDeploy(uint32 sdkError, uint32 exitCode) public view {
        deploy();
    }

    function onCodeUpgrade() internal override {
        tvm.resetStorage();
    }

    function _menu() internal virtual;
}