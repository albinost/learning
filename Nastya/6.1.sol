/*
Добавить в контракт из задачи 5 функционал такой, чтобы одно из полей было типа enum.
https://ropsten.etherscan.io/address/0xb0e9c2e826a839CCB5D1B19A8CF0FD4a65e927a3#code
* обозначила начало и конец 6 задачи ниже по коду *
*/

pragma solidity ^0.8.3;
//10% -кредит,непополняемый; 5%-вклад,пополняемый,неснимаемый,замораживается на установленное время
//начало 6 задачи с 38 строки
contract Bank {
    address payable owner;
    uint256 ownersFee;
    uint8 constant x = 60;
    uint16 constant y = 300;
    uint8 constant month = 31;

    mapping (address => Investors) private invest;                     //информация о вкладах:на сколько и сумма
    struct Investors{                                             
        uint256 timestamp;
        uint256 outcome;  
    }
     
    event DepositReceived(address indexed sender, uint256 sum);
    event DepositReturned(address indexed sender, uint256 sum);

    event LoanGot(address indexed creditor, uint256 sum);
    event LoanPayed(address indexed creditor);

    constructor() {
        owner = payable(msg.sender);
    }

    modifier onlyOwner() { 
        require(msg.sender == owner);  
        _; 
    } 

    modifier notSoLong(uint256 months) {          //чтобы не могли взять кредит на очень долгий срок
        require(months <= x,
        "You can invest or take a credit only for 5 years for each deal.");               //maximum на пять лет кредит
        _; 
    } 

    receive() external payable {               //fallback функция
        owner.transfer(msg.value);  
    }
    
    ///все что поменяла для решения 6 задачи, тк 
    ///банк самое логичное переделать переменную "verified" в enum ///////
    enum CreditorState { Unverified, Verified }     
                // "+" отмечаю что поменяла для решения 6-ой задачи
    
    mapping (address => Creditors) private cred;                     //информация о кредиторах
    struct Creditors {                                             
        uint256 time;
        uint256 creditSum;
        CreditorState status;                            ///  "+" только проверенные пользователи могут взять кредит
    }

    modifier onlyVerified(address client, CreditorState state) {  
        require(state == CreditorState.Verified,"You are not allowed to take a loan"); ///"+" 
        _; 
    } 

    function setPermission(address creditor) external onlyOwner {   //добавить в проверенные пользователи кредитора
        cred[creditor].status = CreditorState.Verified;                    ///"+"                                
    }

    function deletePermission(address creditor) external onlyOwner {  
        cred[creditor].status = CreditorState.Unverified;                 ///"+"                  
    }

    function repayCredit() public payable {                   //для выплаты кредита
        if (cred[msg.sender].creditSum <= msg.value) {
            cred[msg.sender].time = 0;                 //если все выплатил -  обнуление информации о кредите
            emit LoanPayed(msg.sender);
        }
        if (cred[msg.sender].time < block.timestamp && cred[msg.sender].time != 0)   //если не уплатил в срок
            cred[msg.sender].status == CreditorState.Unverified;     
        if (cred[msg.sender].creditSum < msg.value)
            payable(msg.sender).transfer(msg.value - cred[msg.sender].creditSum); 
        cred[msg.sender].creditSum = 0;
    }

    function getInformationOfMyCredit() public view 
        returns(
            uint sum, 
            uint time, 
            string memory
        ) 
    {   //получение информации о кредите   
        string memory userIs;
        if(cred[msg.sender].status == CreditorState.Verified)            ///"+" 
            userIs = "verified";
        else
            userIs = "unverified";
        return (cred[msg.sender].creditSum, cred[msg.sender].time, userIs);                                      
    }
    ///конец 6 задачи

    function payFee(uint256 amount)  private returns(uint256 Fee) {     //вызывается из другой функции для перечисления налога
        ownersFee = amount / y;                                                   // владельцу контракта
        owner.transfer(ownersFee); 
        return(ownersFee);                         
    }
    ///functions for investors
    function deposit(uint16 months) external payable notSoLong(months) {                    //делаем вклад
        uint256 sum = msg.value;
        uint256 temp=invest[msg.sender].outcome;
        emit DepositReceived(msg.sender, sum);
        uint256 fee = payFee(sum);                                        //платим налог от каждой транзакции
        if (invest[msg.sender].timestamp == 0)                  
            invest[msg.sender].timestamp = block.timestamp + months*month*1 days;
        else                                                //если уже есть другой вклад то прибавляем к нему время
            invest[msg.sender].timestamp += months*month*1 days;
        temp += sum;
        for(uint16 i = 0; i < months; i++){                   //начисляем процент
            temp = temp * 105/100;
        }
        temp -= fee;
        invest[msg.sender].outcome = temp;
    }

    function returnDeposit() public {                      //возврат вклада и обнуление информации о вкладе
        require(invest[msg.sender].timestamp < block.timestamp,
        "Wait for the expiration date of the deposit");
        address payable caller = payable(msg.sender);     
        assert((caller.send(invest[msg.sender].outcome) == true));            
        emit DepositReturned(caller, invest[caller].outcome);
        invest[caller].outcome = 0;
        invest[caller].timestamp = 0;
    }
    ///end for investors

    /// functions for creditors
    function takeCredit(uint256 amount,uint16 months) public notSoLong(months) onlyVerified(msg.sender,cred[msg.sender].status) {
        require(amount <= 1000 ether, "An amount for loan is too big");  // берем кредит с реальными ограничениями
        address payable caller = payable(msg.sender);                        //на не очень долгое время+не целое состояние
        require(cred[caller].time == 0, "You cant take another loan");  //если уже есть кредит,то больше выдать не можем
        uint256 fee = payFee(amount);
        uint256 temp;
        cred[caller].time = block.timestamp + months*31 days;
            temp = amount;
        for(uint16 i = 0; i < months; i++){
            temp = temp * 11/10;    //начисление процентов
        }
        temp += fee;
        assert((caller.send(temp) == true));     //перечисление средств в долг
        emit LoanGot(msg.sender, temp);
        cred[caller].creditSum = temp;
    }
    
    ///end for creditors 
    function getInformationAsInvestor() public view returns(uint sum, uint time) {        //получение информации о вкладе
        return (invest[msg.sender].outcome, invest[msg.sender].timestamp);                                      
    }
    
    function getCOntractBalance() public view returns(uint balance) {            
        return address(this).balance;                                      
    }
}
