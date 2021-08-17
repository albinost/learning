/*
Добавить такой функционал, чтобы можно было убедиться, 
что число итераций цикла в рамках одной транзакции ограничено. 
Опытным путем вычислить это число для своего цикла.
https://ropsten.etherscan.io/address/0xc7e3db479035dedE12Cc6A3DB25A5617F76E89Cd#code

"+" - что добавила для решения 8 задачи.
Как понимаю, цель задания - защита контракта от многочисленных(зачастую ненужных,избыточных) итераций цикла.
Поэтому ввела ограничение на количество резюме и работу контракта(5 лет). Работа контракта сказывается только
на добавление новых резюме. Остальной функционал будет продолжать работать. 
* maxIterForWhile() (62 стр) - функция для определения на данный момент числа итераций 
функции updateResumeForMany() (73 стр), которая содержит 2 while
* в функции hire() (91 стр) цикл for => ввела ограничение на количество элементов вводимого массива(<20)
*/

pragma solidity ^0.8.4;

contract Resumes {
    uint8 constant x = 5;
    uint32 public maxRes;                  //+максимальное количество резюме,можно менять
    uint256 start;   //+когда начал действовать контракт (к примеру по времени будет действовать 5 лет)
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
    
    constructor(uint32 maxResume) {
        owner = msg.sender;
        maxRes = maxResume;          
        start = block.timestamp;      
    }

    modifier onlyOwner() { 
        require(msg.sender == owner);  
        _; 
    } 
    modifier checkMaxResAndDay() {         
        require(res.length + 1 <= maxRes && start + x*365 days > block.timestamp,
        "Limit of resumes has been exceeded or contract time is overdue."); 
        _; 
    } 

    modifier onlyPosAndExisting(uint32 element) { 
        require(element > 0 && element < howMuchResume(),
        "Inappropriate element as index of an array");  
        _; 
    }

    function changeMaxRes(uint32 amount) external onlyOwner {
        require(amount > maxRes,"the number of resumes can only be changed upwards");
        maxRes = amount;
    }

    function maxIterForWhile() public view returns(uint32 max1while, uint32 max2while) { 
        uint32 max2 = 0;                                   
        for(uint i = 1; i < 6; i++){
            if (start < block.timestamp - i*365 days)
                max2 = uint32(i);
            else
                return(uint32(res.length), max2); 
        }
        return(uint32(res.length), uint32(x));     //+ если >5 лет прошло,то все равно остаётся 
    }                                       //+5 итераций второго цикла while(из-за ограничения)

    function updateResumeForMany() public onlyOwner{  //изменение элементов массива
        int256 n = int256(res.length) - 1;    //обновляется опыт на +j лет,если прошло от одного года
        while(n != -1){                   // со времени внесения резюме в контракт 
           if(res[uint256(n)].id == 0){  //+ не тратим газ на тех кого удалили и не проходим в супер долгий второй while
               n -= 1;
               continue;
           }
            uint8 j = 1;
            while(res[uint256(n)].time < block.timestamp  - j*365 days) {
                res[uint256(n)].experience += 1;
                j++;
            }      
            res[uint256(n)].time = block.timestamp;   
            n -= 1;         
        }
    }
    
//если есть в elements, то людей берут на должность job
    function hire(string memory job, uint32[] calldata elements) external onlyOwner {
        require(elements.length > 0 && elements.length < 20);  //+
        for(uint16 i = 0; i < elements.length; i++){  //elements - массив индексов,ссылаются на массив резюме
            if(res[elements[i]].id == 0) continue;     //+кого удалили не изменяем
            if (elements[i] <= res.length - 1 )
                res[elements[i]].hiredAs = job;    
            else
                revert('inappropriate index for resume');
        }
    }

    function isHired(uint32 element)
        public view
        onlyPosAndExisting(element)
        returns (
            string memory job
        ) 
    {  
        if ((keccak256(abi.encodePacked((res[element].hiredAs))) == keccak256(abi.encodePacked(("")))))
            return "none";
        else 
            return res[element].hiredAs;
    }

    function addResume (
        uint256 id, 
        string memory job, 
        uint8 experience, 
        bool advancedEnglish, 
        bool higherEdu) 
        public 
        checkMaxResAndDay()
    {
        require(advancedEnglish == true, "We aren't sure you're the right fit.");
        res.push(Resume(id, job, experience, block.timestamp, "", advancedEnglish, higherEdu));
    }

    function changeResumeAll(
        uint32 element,
        string memory job, 
        uint8 experience, 
        bool advancedEnglish, 
        bool higherEdu) 
        external
        onlyOwner 
        onlyPosAndExisting(element) 
    {
        if(advancedEnglish == false) 
            setToDeafultResume(element);
        else 
            res[element] = Resume (
            res[element].id, job, experience, 
            block.timestamp, "",
            advancedEnglish,
            higherEdu
            );
    }
    
    function updateResumeForOne(uint32 element, uint16 _experience)
        external 
        onlyOwner 
        onlyPosAndExisting(element) 
    {
        res[element].experience=_experience;
    }
         
    function viewResume(uint32 element) 
        public view
        onlyPosAndExisting(element) 
        returns (
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

    function setToDeafultResume(uint32 element) public  onlyOwner onlyPosAndExisting(element) {
       delete  res[element];      
    }
                        
    function howMuchResume() public view returns(uint256 amount) {
       return (res.length);             //длина массива
    }
}
