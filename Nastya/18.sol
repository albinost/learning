Вызовы функций между контрактами.
Отличия между Call, StaticCall и DelegateCall.
Прописать комментариями отличия и особенности.

Контракты:
А: https://ropsten.etherscan.io/address/0xFb83b9B058670D6980EF4A99F999A3976efBE57A#code
B: https://ropsten.etherscan.io/address/0x37574Cc4974d1D4677C5B9013bf08ef5D39b25FD#code

pragma solidity ^0.8.6;

contract A {
    uint32 public wasCalled;
    address public sender;
    bytes public data;
    
    function forCall() public {
        sender = msg.sender;
        data = msg.data;
        wasCalled += 1;
    }
    
    //sender = изначальный externally-owned аккаунт
    //все переменные изменяются в контракте B (используется его память)
    function forDelegateCall() public {
        sender = msg.sender;
        data = msg.data;
        wasCalled += 1;
    }
    
    //успешно выполняется с контракта B
    function forStaticCallFirst() public view returns (uint32 interactions) {
        return wasCalled;
    }
    
    //staticcall возвращает false при вызове с контаркта B
    //модифицируется память => функция revert при staticcall
    function forStaticCallSecond() public  {
        wasCalled += 1;
    }
}

contract B {
    uint32 public wasCalled;
    address public sender;
    bytes public data;
    bool public success;   //смотрим успех транзакции для call, delegatecall
    
    //просто вызывает функцию, msg.sender = контракт B
    function call(address _contract) public {
        (success,) = _contract.call(
            abi.encodeWithSignature("forCall()","0x0")
        );
    }
    
    //вызывает функцию на другом контракте, но изменения переменных происходят
    //в данном (контракт B). У контракта А берётся только код функции, который и выполняется.
    //для верного присвоения переменных требуется такое же расположение данных в памяти 
    //как в контракте A. 
    //sender = msg.sender = изначальный externally-owned аккаунт
    function delegateCall(address _contract) public {
        (success,) = _contract.delegatecall(
            abi.encodeWithSignature("forDelegateCall()","0x0")
        );
    }
    
    //у delegatecall и staticcall нет value, как у call.
    //газ на вызов функции можно выделить у всех.
    function staticCallFirst(address _contract) public view returns (bool working) {
        (bool successCall,) = _contract.staticcall(
            abi.encodeWithSignature("forStaticCallFirst()")
        );
        return successCall;
    }
    
    //всегда reverted, тк staticcall успешно вызывает только view, pure функции
    //(не модифицируют память), иначе выбрасывает исключение
    //как в функции данной ниже
    function staticCallSecond(address _contract) public view {
        (bool successCall,) = _contract.staticcall(
            abi.encodeWithSignature("forStaticCallSecond()")
        );
        require(successCall,"This function reverts");  //successCall всегда false
    }
}