/*Подключить к своему контракту библиотеку для работы с адресами:
https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol.
 Разработать логику, которая используют следующиие функции из этой библиотеки:
 isContract(), sendValue()
https://ropsten.etherscan.io/address/0x95f781DE4fC59E6Ae4572999B1f6bA49c8746119#code

 Суть изменений:
  модификатор для firstVersion(),только контракт ее может вызвать
  НОД чисел отправляется вызывающему функцию контракту с помощью sendValue()

*/
pragma solidity ^0.8.6;

import {Address} from "./Address.sol";
import {SimpleMath} from "./math.sol";


contract Euclidean {                        //представлены 2 версии алгоритма Евклида
    using SimpleMath for uint256;
    uint256 public var1;           
    uint256 public var2;

    constructor(uint256 _var1, uint256 _var2) {
        var1 = _var1;
        var2 = _var2;
    } 

    //9 задача
    //в первом случае из конструктора доступ к firstVersion() не получит контракт
    //во втором же случае получит
    modifier onlyForContracts() {
        require(Address.isContract(msg.sender) == true,
        "This function can be accessed only from existing contract");
        //require(msg.sender !=tx.origin);       // как аналог, tx.origin - всегда externally-owned account 
        _; 
    } 
    
    function charity() payable external {            //отправка денег на контракт         
        require(msg.value <= address(msg.sender).balance, "Insufficient balance");
    }

    function firstVersion() public onlyForContracts returns (bool) { 
        uint256 v1 = var1; uint256 v2 = var2;
        bool flag;
        while (v1 != 0 && v2 != 0) {
             if (v1 > v2) {
                  (flag, v1) = v1.mod(v2);           //a = a % b
                  if (flag == false)
                     revert("Inappropriate numbers for this algorithm");
             } else {
                 (flag,v2) = v2.mod(v1);               //b = b % a 
                 if (flag == false)
                     revert("Inappropriate numbers for this algorithm");
             }
        }
        (flag, v1) = v1.add(v2);
        if (flag == true)           
            return (Address.sendValue(payable(msg.sender),v1));     //НОД двух чисел отправляется вызывающему функцию контракту
        else
            return false;
    }
    
    //конец 9 задачи на этом контракте
    //внизу пример контракта для вызова функции firstVersion() и получения денег
    function secondVersion() public view returns (bool success, uint256) { 
        uint256 v1 = var1; uint256 v2 = var2;
        bool flag;
        while (v1 != v2) {
             if (v1 > v2) {
                  (flag, v1) = v1.sub(v2);           //a = a - b
                  if (flag == false)
                     revert("Inappropriate numbers for this algorithm");                 
             } else {
                 (flag,v2) = v2.sub(v1);                //b = b - a 
                 if (flag == false) 
                     revert("Inappropriate numbers for this algorithm");
             }
        }
        return (true,v1);
    }
    
    function changeVars(uint256 _var1, uint256 _var2) public returns(string memory) {   //изменяем переменные 
        var1 = _var1;                
        var2 = _var2;
        return "Vars have changed successfully";
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }   
}

//пример контракта вызывающего функцию firstVersion()
contract User {
    Euclidean con;
    bool public success;
    
    receive() external payable {    //fallback функция, без нее контракт не получит денег из первой фунции контракта     
    }
    
    function callFirstVersion(address _con) public returns(bool) {    //вызывает функцию firstVersion()
        con = Euclidean(_con);
        success = con.firstVersion();
        return success;
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
}