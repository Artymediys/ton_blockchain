pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

//IGO - Interface Game Object
interface IGO {
    function takeAttack(uint8 damage) external;
}