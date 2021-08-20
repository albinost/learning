Область видимости функций и переменных.

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
  Если внешне вызываем функцию, то самая затратная функция с external типом 
(при одной логике работы, что дано по условию, разница с public очень маленькая)
  Если же вызываем функцию изнутри (в самом контракте), то самая затратная internal.
Далее в сторону уменьшения затратности идет public, private.

https://ropsten.etherscan.io/address/0x29131156C7aB36c1b55d03df2Ea6bAe92415716A#code

pragma solidity ^0.8.6;

contract Estimation {                        
    uint256 public var1 = 10;           
    uint256 internal var2 = 10;
    uint256 private var3 = 10;
    uint256 public var4 = 1;
    
    //исследование газа при разной видимости переменных
    function addToVar1() public {    
        var1 += 1;
    }
    
    function addToVar2() public { 
        var2 += 1;
    }
    
    function addToVar3() public { 
        var3 += 1;
    }
    
    //исследование газа при разной видимости функций
    function firstType() public {    
        var4 += 1;
    }
    
    function secondType() external { 
        var4 += 1;
    }
    
    function thirdType() internal { 
        var4 += 1;
    }
    
    function fourthType() private { 
        var4 += 1;
    }
    
    function firstCalling() public {    ///вызов public
        firstType();
    }

    function thirdCalling() public {    ///вызов internal
        thirdType();
    }

    function fourthCalling() public {   ///вызов private
        fourthType();
    }
}