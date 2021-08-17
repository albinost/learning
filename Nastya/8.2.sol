/*Библиотеки. Подключить к своему контракту с арифметическими операциями 
(сложение и вычитание, также пусть тип будет uint256) библиотеку безопасной математики.
Разработать логику, которая используют арифметические операции с использованием этой библиотеки
https://ropsten.etherscan.io/address/0x9200E6566FE3e3618260be0f675654a11ab7f2bF#code

Вследствие использования современного компилятора пользовалась новой версией библиотеки отсюда:
https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol
Для демонстрации арифм операций в данной задаче реализовала 2 версии алгоритма Евклида
*/

pragma solidity ^0.8.6;

import {SimpleMath} from "./math.sol";


contract Euclidean {                        //представлены 2 версии алгоритма Евклида
    using SimpleMath for uint256;
    uint256 public var1;           
    uint256 public var2;

    constructor(uint256 _var1, uint256 _var2) {
        var1 = _var1;
        var2 = _var2;
    } 

    function firstVersion() public view returns (bool success, uint256) { 
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
        return (v1.add(v2));     
    }
    
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
}
