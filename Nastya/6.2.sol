/*
Работа со структурами. Написать контракт для изменения значений полей структуры. 
Пусть это будет массив структур. 
Сделать функционал для добавления новых элементов массива и вывода содержимого n-го элемента
 (сразу всех полей структуры).

https://ropsten.etherscan.io/address/0x5C234215044656C1a57571a07BceB5811fd1364a#code
*/

pragma solidity ^0.8.4;
contract Resume {
    address owner;
    Resume[]  res;                      
   
    struct Resume {
        uint256 id;
        string job;
        uint16 experience;
        bool advancedEnglish;
        bool higherEdu;
    }
    
    constructor() {
        owner=msg.sender;
    }

    modifier onlyOwner() { 
        require(msg.sender == owner);  
        _; 
    } 

    modifier onlyPosAndExisting(uint16 element) { 
        require(element > 0 && element < howMuchResume(),
        "Inappropriate element as index of an array");  
        _; 
    }

    function addResume(
        uint256 id, 
        string memory job, 
        uint8 experience, 
        bool advancedEnglish, 
        bool higherEdu
    ) 
        public 
    {
        require(advancedEnglish == true,"We aren't sure you're the right fit.");
        res.push(Resume(id, job, experience, advancedEnglish, higherEdu));
    }

    function changeResumeAll(
        uint16 element, 
        string memory job, 
        uint8 experience, bool advancedEnglish, 
        bool higherEdu
    ) 
        external 
        onlyOwner 
        onlyPosAndExisting(element) 
    {
        if(advancedEnglish == false) resetResume(element);
        else res[element] = Resume(res[element].id, job, experience, advancedEnglish, higherEdu);
    }
    
    function updateResume(uint16 element, uint16 _experience) 
        external 
        onlyOwner 
        onlyPosAndExisting(element) 
    {
        res[element].experience = _experience;
    }
         
    function viewResume (uint16 element)
        public view
        onlyPosAndExisting(element) 
        returns (
            uint256 id, 
            string memory job, 
            uint16 experience, 
            bool advancedEnglish, 
            bool higherEdu
        )
    {
        return (
            res[element].id, 
            res[element].job, 
            res[element].experience, 
            res[element].advancedEnglish, 
            res[element].higherEdu
        );
    }          //для красивого вывода без кортежа;если такого элемента нет revert автоматом
                                                                 //выдает исключение
        
    function resetResume(uint16 element) public onlyOwner {
        delete  res[element];         
    }
                        
    function howMuchResume() public view returns(uint256 amount) {
        return res.length;             //длина массива
    }
}
