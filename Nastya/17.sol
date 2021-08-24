Изучить и применить msg.sender и tx.origin.
Дать подробный комментарий (свой текст, не копипаст), что это и для чего используется.
---
msg.sender - адрес вызывающий транзакцию
  (это можеть быть как externally-owned аккаунт, так и смарт-контракт)
tx.origin - адрес изначально вызывающего транзакцию (только externally-owned аккаунт)

msg.sender необходим для совместимости, гибкости, которая приходит с использованием
смарт-контрактов. Нужен для полноценного взаимодействия смарт-контрактов
со смарт-контрактами и externally-owned аккаунтами. Без него, к примеру, не будет личного 
взаимодействия с различными активами (хранение по адресу в mapping пересланных 
на контракт эфиров с этого адреса). 

tx.origin может быть полезен для записи адреса externally-owned аккаунта, если он взаимодействует 
с другими смарт-контрактами через свой смарт-контракт. Таким образом у externally-owned аккаунта
всегда будет возможность взаимодействовать с другими контрактами напрямую в случае обнаружения
уязвимостей у своего смарт-контракта и без потери своих сбережений. Но лучше всего избегать
tx.origin из-за уязвимости к различным атакам.

В данных контрактах tx.origin всегда возвращает один и тот же externally-owned аккаунт,
вызывающий транзакцию.
msg.sender же постоянно изменяется в зависимости от вызываемой функции.

Контракты:
A: https://ropsten.etherscan.io/address/0x90cFe64aac88F1aA92CA298a50e1D77b8065E252#code
B: https://ropsten.etherscan.io/address/0x5FE72DF8697d1E89C300cc807FAeaE9080076dac#code
C: https://ropsten.etherscan.io/address/0x28f706F5560eE9c6e45e23E603c04568757f31f9#code

pragma solidity ^0.8.6;

contract A {
    //если функции вызваны напрямую, то
    //msg.sender = tx.origin
    function getSender() public view returns (address) {
        return msg.sender;
    }

    function getOriginalSender() public view returns (address) {
        return tx.origin;
    }
}

contract B {
    A public a;

    constructor(address _a) {
        a = A(_a);
    }
    
    //sender = адрес контракта B если функция вызывается с контракта B и C
    function callContractA() public view returns (address sender, address origin) {
       return (a.getSender(), a.getOriginalSender());
    }

    function getSender() public view returns (address) {
        return msg.sender;
    }

    function getOriginalSender() public view returns (address) {
        return tx.origin;
    }
}

contract C {
    A public a;
    B public b;

    constructor(address _a, address _b) {
        a = A(_a);
        b = B(_b);
    }

    //sender = адрес контракта С
    function callContractA() public view returns (address sender, address origin) {
       return (a.getSender(), a.getOriginalSender());
    }

    //sender = адрес контракта B (вызов A через B)
    function callContractAfromB() public view returns (address sender, address origin) {
        return b.callContractA();
    }
    //sender = адрес контракта C
    function callContractB() public view returns (address sender, address origin) {
       return (b.getSender(), b.getOriginalSender());
    }
}