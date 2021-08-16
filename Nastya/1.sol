/*
1. Написать функции геттер и сеттер для переменной типа string
2. Для двух переменных типа uint8 сделать функции для демонстрации 
арифметического переполнения: a) при сложении b) при вычитании
3. Установка контракта из пункта 2 в тестовый блокчейн Ropsten.
 Установка кошелька Metamask. Получение тестовых ETH.

 https://ropsten.etherscan.io/address/0x15cD4AD78cFCe150F10Fa7FDb6E2268f0c03f205#code
*/

pragma solidity 0.6.0;

contract First {
    string message;                    //переменная - строка

    constructor() public {
        message = "";                 //установка значения переменной по умолчанию
    }

    function getMessage() public view returns (string memory) {       //геттер
        if ((keccak256(abi.encodePacked((message))) == keccak256(abi.encodePacked((""))))) //строчка не изменена (=пустая) =>вывод сообщения
            return "The message is empty. Please set any string.";
        else
            return message;                                                //строчка не пустая=> вывод строчки
    }

    function setMessage(string memory _str) public returns(string memory) { //запись строки в переменную- сеттер
        message = _str;
    }
    
}

contract Second {
    
    uint8 public price1 = 200;          //переменные uint8 
    uint8 public price2 = 190;
    
    
    function add() public view returns (uint8) {  //вычисление суммы в uint8 и вывод
        return(price1 + price2);
    }
    
    
    function sub() public view returns(uint8) {   //вычисление разности в uint8 и вывод
        if (int(price1) - int(price2) < 0)                        // выводим такой результат который удоволетворяет задаче арифм переполнения 
            return (price1 - price2);
        else
            return (price2 - price1);
    }
  
  
    function changePrices(uint8 var1,uint8 var2) public returns(string memory) {   //изменяем переменные 
      require( 
            ((int(var1) + int(var2) > 255) && 
            ((int(var2) - int(var1) < 0) || (int(var1) - int(var2) < 0))),    //для удовлетворения условиям задачи арифм переполнения -обертывание исключений
            "Неподходящие переменные для демонстрации арифметического переполнения в uint8." );                              //чтобы не использовали газ
      price1 = var1;                //изменение переменных
      price2 = var2;
      return "Цены успешно заменены";
    } 
}
