/*
Работа со структурами. Написать контракт для изменения значений полей структуры. 
Пусть это будет массив структур. 
Сделать функционал для добавления новых элементов массива и вывода содержимого n-го элемента
 (сразу всех полей структуры).

https://ropsten.etherscan.io/address/0x5C234215044656C1a57571a07BceB5811fd1364a#code
*/

pragma solidity ^0.8.4;
contract Resume{
    
    address owner;
    resume[]  res;                      
   
    struct resume {
    uint256 id;
    string job;
    uint16 experience;
    bool advancedEnglish;
    bool higherEdu;
    }
    
    constructor(){
        owner=msg.sender;
    }

    modifier onlyOwner(){ 
        require(msg.sender == owner);  
        _; 
    } 

    function addResume (uint256 id,string memory job, uint8 experience,bool advancedEnglish, bool higherEdu) public {
        require(advancedEnglish==true,"We aren't sure you're the right fit.");
        res.push(resume(id,job,experience,advancedEnglish,higherEdu));
        }

    function changeResumeAll(uint16 element,string memory job, uint8 experience,bool advancedEnglish, bool higherEdu) onlyOwner external {
        if(advancedEnglish==false) resetResume(element);
        else res[element]=resume(res[element].id,job,experience,advancedEnglish,higherEdu);
    }
    
    function updateResume(uint16 element, uint16 _experience) onlyOwner external {
        res[element].experience=_experience;
    }
         
    function output (uint16 element) public view returns(uint256 id,string memory job, uint16 experience,bool advancedEnglish, bool higherEdu){
        if (element<0)revert("Elements are positive");
         return (res[element].id,res[element].job,res[element].experience,res[element].advancedEnglish,res[element].higherEdu);
     }          //для красивого вывода без кортежа;если такого элемента нет revert автоматом
                                                                 //выдает исключение
        
    function resetResume(uint16 element) onlyOwner public {
       delete  res[element];         
   }
                        
   function howMuchResume() public view returns(uint256 amount){
       return (res.length);             //длина массива
   }

}