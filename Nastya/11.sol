/*
Интерфейсы и модификаторы доступа.
 Написать контракт работающий с другим контрактом с помощью интерфейса. 

Контракты: 
Vote(голосование): 
https://ropsten.etherscan.io/address/0xBD0C6a7Bd00290F9Cf44bAe59Cebb8eCc4E6c014#code
ProcessVotes(обработка голосов с помощью интерфейса):
https://ropsten.etherscan.io/address/0x521C7C19566aB1D3B47a4e82BC059E8353b14B74#code

*/

pragma solidity ^0.8.6;

import './ownable.sol';


contract Vote is Ownable {
    bool public votingIsOver;

    mapping(address => Form) private vote;     //голоса участников добавляются в структуру
    address[] private alreadyVoted;           //адреса тех, кто уже проголосовал, для поиска в mapping
    struct Form { 
        uint16 region;
        bool firstQuestion;
        bool secondQuestion;
    }
    
    constructor(address _owner) {
        owner = _owner;
    }

    modifier notOver() {
        require(votingIsOver == false, "Sorry, but voting is over");
        _;
    }

    modifier notAlreadyVotedUser() {  //для предотвращения добавления голосов с помощью контрактов
        require(vote[msg.sender].region == 0 && msg.sender == tx.origin); //и добавления в массив новой формы
        _;
    }
    //заполнение формы, ее добавление в mapping
    function fillForm(uint16 region, bool firstQue, bool secondQue) external  
        notOver 
        notAlreadyVotedUser
    {  
        alreadyVoted.push(msg.sender);
        vote[msg.sender] = Form(region,firstQue,secondQue);
    }  

    function endVote() onlyOwner public {      // прекращение голосования
        votingIsOver = true;
    }

    function getAlreadyVoted() external view returns (address[] memory) {  
        return alreadyVoted;
    } 

    function getForm(address id) external view returns (uint16, bool, bool) {
        return (vote[id].region,vote[id].firstQuestion,vote[id].secondQuestion);
    }
    
    function howMuchVoted() external view returns (uint256) {   //количество всех форм 
        return alreadyVoted.length;
    }
}


interface IVoteInterface {
    function getForm(address id) external view returns (uint16, bool, bool);
    function getAlreadyVoted() external view returns (address[] memory);
    function howMuchVoted() external view returns (uint256);
}


contract ProcessVotes is Ownable {
    IVoteInterface voteContract;

    constructor(address _owner) {
        owner = _owner;
    }

    function setVoteContract(address _address) external onlyOwner {  //для записи нового адреса контракта Vote
        voteContract = IVoteInterface(_address);                      
    }

    function getVoted() public view returns (address[] memory) {
        return voteContract.getAlreadyVoted();
    }

    function getFormByAddress(address id) 
        public view 
        returns (
            uint16 region, 
            bool firstQuestion,
            bool secondQuestion
        ) 
    {
        return voteContract.getForm(id);
    }
    
    function receivedVotes() public view returns (uint256) {
        return voteContract.howMuchVoted();
    }
}