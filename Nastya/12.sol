/*
Конструкторы и fallback-функции. 
Рассмотреть, как они реализованы в разных версиях Solidity 
Привести примеры и комментарий к каждому примеру. 
Написать простейший контракт с конструктором и fallback-функцией для 7-ой версии.


Fallback

0.5<x<0.6:
  Нет аргументов, ничего не может вернуть
  function() external payable {   вызывается во время транзакции с пустой calldata 
      ...                         (часто с перечислением эфира за счет payable)
  }                               на контракт или когда ни одна функция 
                                  не подошла во время вызова
                    
x>=0.6:
   Разделилась на 2 функции: receive() и fallback()
   receive() external payable  — во время транзакции с пересылкой эфира (любое значение)
                                          c пустой calldata (calldata хранит аргументы) 
   fallback() external [payable]  — когда ни одна функция не подходит при вызове
     fallback() может быть payable с целью получения эфира (аналог receive())
     Для функции receive() и fallback() payable остается очень мало газа при пересылке с помощью
     send, transfer. Можно только создать event.
     Если fallback() payable и существует receive() функция в контракте, то при непустой calldata
     будет всегда выполняться fallback() (даже если с вызовом пересылается эфир).

x>=0.8:
  Появилась версия с параметрами
    fallback (bytes calldata _input) external [payable] returns (bytes memory _output) 
    _input = msg.data 


Constructors

x<4.22:
Конструкторы были определены как функции с названием контракта, к которому принадлежали. 
Могут быть public или internal ( если internal то контракт абстрактный).
После создания контракта единожды выполняется одноименная функция, а потом деплоится в сеть.
contract NFT { 
    address owner;
    function NFT() {
        owner = msg.sender;
    }
}

x>=4.22:
Новый синтаксис.
Все также могут быть public или internal. Это необходимо обязательно указывать.
contract Set {
    string public mail;
    constructor(string _mail) public {
        mail = _mail;
    }
}
Если нет конструктора, то выполняется дефолтный конструктор 
constructor() {}. 
Все переменные инициализируются до конструктора (если нет присвоения,то по умолчанию).

x>=0.7:
Можно не указывать тип конструктора (public / internal).


https://ropsten.etherscan.io/address/0x90fE759cBe1e89194Fc59f17b2Ca7f1C5c60Fff4#code
*/


pragma solidity ^0.7.0;

contract Recipient {
    address payable owner;
    uint public interactions;              //сколько раз вызывалась fallback()
    event Received(address indexed from, uint value);
    
    constructor(address payable _owner) {
        owner = _owner;
    }

    receive() external payable {                                      
        emit Received(tx.origin, msg.value);        
    }  
    
    fallback() external {                            
        interactions += 1;
    }
    
    function transferToOwner() public payable {
        owner.transfer(address(this).balance);
    } 
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
