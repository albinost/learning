/* Область видимости функций и переменных.

Написать контракт и подсчитать расход газа при работе с функциями и переменными,
с разной областью видимости и одной логикой работы.
Дать комментарии, какие области видимости в Solidity есть,
а также комментарии, содержащие выводы анализа затратности газа
 для работы с функциями и переменными с разной областью видимости
---
Есть 4 области видимости для функций (public, external, internal, private),
для переменных - 3 (public, internal, private).

Про переменные:
При работе с переменными больше всего газа уходит на private тип, 
далее по уменьшению расходов идет internal и public (маленькая разница даже между private и public
при выполнении одного арифметического действия).

Про функции:
  Если внешне вызываем функцию, то самая затратная функция с public типом 
  Если же вызываем функцию изнутри (в самом контракте), то самая затратная private.
Далее в сторону уменьшения затратности идет internal, public.

Контракты:
VariablesEstimation: https://ropsten.etherscan.io/address/0xb68648634b06e9e4a6578C058D8f95954764bA3A#code
InsideCalls: https://ropsten.etherscan.io/address/0xf49354A1880874B88bDD671c4bE88DE458Dcce6b#code
OutsideCalls: https://ropsten.etherscan.io/address/0x4F7f72e27E8D4Cb0ca257AFCc0e8c4141F6356f7#code
*/

pragma solidity ^0.8.6;

contract VariablesEstimation {  
    //исследование газа при разной видимости переменных                      
    uint256 public var1;           
    uint256 internal var2;
    uint256 private var3;
    
    function addToVar1() public { 
        for (uint i=0; i<30; i++)
            var1 += 1;
    }
    
    function addToVar2() public {
        for (uint i=0; i<30; i++)
            var2 += 1;
    }
    
    function addToVar3() public {
        for (uint i=0; i<30; i++)
            var3 += 1;
    }
}


contract OutsideCalls {
    //исследование газа при вызовах снаружи
    uint256 public var1;  
    uint256 public var2;
    
    function firstType() public {
        for (uint i=0; i<40; i++)
            var1 += 1;
    }
    
    function secondType() external { 
        for (uint i=0; i<40; i++)
            var2 += 1;
    }
}


contract InsideCalls {
     //исследование газа при вызовах внутри контракта
    uint256 public var1; 
    uint256 public var2; 
    uint256 public var3; 
        
    function firstType() public {
        for (uint i=0; i<80; i++)
            var1 += 1;
    }
    
    function secondType() internal { 
        for (uint i=0; i<80; i++)
            var2 += 1;
    }
    
    function thirdType() private { 
        for (uint i=0; i<80; i++)
            var3 += 1;
    }
    
     function firstCall() public {    
        firstType();
    }

    function secondCall() public {    
        secondType();
    }

    function thirdCall() public {   
        thirdType();
    }
}