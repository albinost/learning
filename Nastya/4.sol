/*
Работа с несколькими контрактами. 
Интерфейсы. Реализовать логику таким образом,
 чтобы функции из одного контракта были доступны для другого контракта. 
 Но необходимо ограничить доступ к функциям первого контракта так,
  чтобы их мог вызывать только второй контракт.

1 метод https://ropsten.etherscan.io/address/0xdc8fc39F01c48C4288FE32cF5d1aFCFeCd4F7550#code
2 метод (2 связанных контракта):
https://ropsten.etherscan.io/address/0x87B4afc111a9757fDF80E71cFBCBeb077e436790#code
https://ropsten.etherscan.io/address/0x28FFdD97D04398c0550B5d143FCbD1b1BEae2d7E#code
*/
pragma solidity 0.8.3;

///first method
contract C1 {
    mapping(address => uint) internal balances;
    
    function deposit() external payable {                    //делаем вклад
        balances[msg.sender] += msg.value;
    }

    function getMyBalance() internal view returns(uint) {             //смотрим баланс на счету контракта
        return balances[msg.sender];                                      //могут вызвать только наследственные контракты
    }

    function returnPayment() internal {                     //возврат всех своих стредств со счета контракта
        address payable caller = payable(msg.sender);                  //могут вызвать только наследственные контракты
        caller.transfer(balances[msg.sender]);
        balances[msg.sender] = 0;
    }
}

contract C2 is C1 {                                                    //вызов функций с первого контракта 
    function getBalance() public view returns(uint balance) {
        return (getMyBalance());
    }
    
    function returnDeposit() public {
        returnPayment();
    }
}


///second method
contract C11 {
    address owner;
    address ownerContract;  //может меняться,адрес "второго" контракта,который вызывает данный
        
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwnerContract() { 
        require(msg.sender == ownerContract,"Try to call from another contract");  
        _; 
    } 
    
    modifier onlyOwner() {
        require(msg.sender == owner, "You're not the owner of the contract");
	    _;
	}

    function f4() external onlyOwnerContract view returns(string memory success) {  //работает только при вызове со 2 (С12) контракта
        return("it works");
    }
    
    function setOwnerContract(address neueOwner) external onlyOwner {
        ownerContract = neueOwner;
    }
}

contract C12 {
    address owner;
    mapping(address => mapping(address => bool)) public allowedUsersAndContracts;   //пользователи которые могут вызывать функцию f4 с данного контракта
                                  //на случай одинаковых С11 - массив с адресами
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You're not the owner of the contract");
	    _;
	}
	
	function main(address addressC11) public view onlyOwner returns(string memory success) {    // вызов функции с 1 контракта
        if (allowedUsersAndContracts[msg.sender][addressC11] == false)
                  revert("You're not allowed to call the fucntion of the entererd contract");
        C11 c11 = C11(addressC11);
        return c11.f4();
    }

    function enableOnePermission(address user, address contractaddr) public onlyOwner {     //добавление в мэппинг разрешения на определенный контракт 
        allowedUsersAndContracts[user][contractaddr] = true;                                  // у определенного пользователя    
    }

    function enableManyPermission(address user,  address[] memory contractaddr) public onlyOwner {  //добавление в мэппинг разрешения на несколько контрактов
        uint len = contractaddr.length;
        for(uint i = 0; i < len; i++){
            allowedUsersAndContracts[user][contractaddr[i]] = true;
      }                                  
    }
 
    function deleteOnePermission(address user, address contractaddr) public onlyOwner{        //удаление разрешения из mapping
        allowedUsersAndContracts[user][contractaddr] = false;                                 
    }

    function deleteManyPermission(address user,  address[] memory contractaddr) public onlyOwner{
        uint len = contractaddr.length;
        for(uint i = 0; i < len; i++){
            allowedUsersAndContracts[user][contractaddr[i]] = false;
      }                                  
    }
}
