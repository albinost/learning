/*
Циклы while и for. В наш увеличиваемый по функционалу родительский контракт добавить функцию,
 которая бы в цикле изменяла содержимое каждого элемента массива. 
 Например, для числового типа шло бы увеличение значения числа на 1.
  Реализовать двумя типами циклов. Придумать и описать свою реализацию для символьного типа.

  https://ropsten.etherscan.io/address/0xd2bd18e08E13Ad548F82c7b243042f8276ccC26b#code
*/

pragma solidity ^0.8.4;
contract Resumes {
    uint8 constant x = 5;
    uint16 constant year = 365;
    address owner;

    Resume[] res;                      
    struct Resume {
        uint256 id;
        string job;
        uint16 experience;
        uint256 time;     //связано с experience (его изменением)
        string hiredAs;             
        bool advancedEnglish;
        bool higherEdu;
    }
    
    constructor() {
        owner = msg.sender;
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

    ///7 задача
    function updateResumeForMany() public onlyOwner {  //изменение элементов массива
        int256 n = int256(res.length) - 1;                           //обновляется опыт на +j лет,если прошло от одного года
        while (n != -1) {                                                       // со времени внесения резюме в контракт 
            uint8 j = 1;
            while (res[uint256(n)].time < block.timestamp  - j*year*1 days) {
                res[uint256(n)].experience += 1;
                j++;
            }      
        res[uint256(n)].time = block.timestamp;   
        n -= 1;           
        }
    }
    
    ///если есть в elements, то людей берут на должность job
    function hired(string memory job, uint16[] calldata elements) external onlyOwner {
        for (uint16 i = 0; i < elements.length; i++) {  //elements - массив индексов,ссылаются на массив резюме
            if (elements[i] <= res.length - 1)
                res[elements[i]].hiredAs = job;    
            else
                revert('inappropriate index for resume');
        }
    }

    function isHired(uint16 element) public view onlyPosAndExisting(element) 
        returns(
            string memory job
        ) 
    {  
        if ((keccak256(abi.encodePacked((res[element].hiredAs))) == keccak256(abi.encodePacked(("")))))
            return ("none");
        else 
            return (res[element].hiredAs);
    }
    ///конец 7 задачи
    function addResume (
        uint256 id, 
        string memory job, 
        uint8 experience, 
        bool advancedEnglish, 
        bool higherEdu
        ) 
        public 
    {
        require(advancedEnglish == true,"We aren't sure you're the right fit.");
        res.push(Resume(id, job, experience, block.timestamp, "", advancedEnglish, higherEdu));
    }

    function changeResumeAll(
        uint16 element,
        string memory job, 
        uint8 experience,
        bool advancedEnglish, 
        bool higherEdu
        ) 
        onlyOwner
        onlyPosAndExisting(element) 
        external 
    {
        if(advancedEnglish == false) resetResume(element);
        else res[element] = Resume(
            res[element].id,
            job,
            experience,
            block.timestamp,
            "",
            advancedEnglish,
            higherEdu
        );
    }
    
    function updateResumeForOne(uint16 element, uint16 _experience) 
        onlyOwner 
        onlyPosAndExisting(element) 
        external 
    {
        res[element].experience = _experience;
    }
         
    function viewResume (uint16 element) public view onlyPosAndExisting(element) returns(
        uint256 id,
        string memory job, 
        uint16 experience, 
        uint256 timeExp,
        bool advancedEnglish, 
        bool higherEdu
        )
    {
        return (
            res[element].id,
            res[element].job,
            res[element].experience,
            res[element].time,
            res[element].advancedEnglish,
            res[element].higherEdu
        );
    }          //для красивого вывода без кортежа;если такого элемента нет revert автоматом
                                                                 //выдает исключение

    function resetResume(uint16 element) onlyOwner onlyPosAndExisting(element) public {
       delete  res[element];         
    }
                        
    function howMuchResume() public view returns(uint256 amount){
       return (res.length);             //длина массива
    }
}