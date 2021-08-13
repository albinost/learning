/*Для наглядности (чтобы не было очень много итераций) 
реализовала функцию  generate() (43 строка),заполняет массив некими значениями.
Считала энергию и получилось, что при x>21.15 будет достигнут лимит по умолчанию (300trx)
=>  при x=22  цикл прекратит работу

https://shasta.tronscan.org/#/contract/TJaAr8p7AHEPzfqEuR4DGK5uLXCZoG8fnj/code
*/

pragma solidity 0.8.0;
contract Resume{
    uint32 public maxRes;                  //+максимальное количество резюме,можно менять
    uint256 start;   //+когда начал действовать контракт (к примеру по времени будет действовать 5 лет)
    address owner;
    resume[]  res;                      
     
    struct resume {
    uint256 id;
    string job;
    uint16 experience;
    uint256 time;     //связано с experience (его изменением)
    string hiredAs;             
    bool advancedEnglish;
    bool higherEdu;
    }
    
    constructor(uint32 maxResume){
        owner=msg.sender;
        maxRes=maxResume;          
        start=block.timestamp;      
    }

    modifier onlyOwner(){ 
        require(msg.sender == owner);  
        _; 
    } 
    modifier checkMaxResAndDay(){         
        require(res.length+1<=maxRes && start+5*365 days>block.timestamp ,"Limit of resumes has been exceeded or contract time is overdue."); 
        _; 
    } 

/////////

   function generate(uint32 amount) public onlyOwner{ 
       for(uint32 i=0;i<amount;i++){                  
           res.push(resume(i,"artist",0,block.timestamp,"",true,true));
       }
   }

///////

   function changeMaxRes(uint32 amount) external onlyOwner{
       require(amount>maxRes,"the number of resumes can only be changed upwards");
       maxRes=amount;
    }

    function maxIterForWhile() public view returns(uint32 max1while,uint32 max2while) { 
         uint32 max2=0;                                   
         for(uint i=1;i<6;i++){
            if (start<block.timestamp-i*365 days){ 
                max2=uint32(i);
            }
            else{
                return(uint32(res.length), max2); 
            }
         }
         return(uint32(res.length), uint32(5));           //+ если >5 лет прошло,то все равно остаётся 
     }                                               //+5 итераций второго цикла while(из-за ограничения)

    function updateResumeForMany() public onlyOwner{  //изменение элементов массива
        int256 n=int256(res.length)-1;                           //обновляется опыт на +j лет,если прошло от одного года
        while(n!=-1){                                                       // со времени внесения резюме в контракт 
           if(res[uint256(n)].id==0){  //+ не тратим газ на тех кого удалили и не проходим в супер долгий второй while
               n-=1;
               continue;
           }
            uint8 j=1;
            while(res[uint256(n)].time < block.timestamp  - j*365 days){
                res[uint256(n)].experience+=1;
                j++;
            }      
            res[uint256(n)].time=block.timestamp;   
            n-=1;  
                    
        }
    }
    
//если есть в elements, то людей берут на должность job
    function hire(string memory job, uint32[] calldata elements) external onlyOwner{
        require(elements.length>0 && elements.length<40);  //+
        for(uint16 i=0;i<elements.length;i++){  //elements - массив индексов,ссылаются на массив резюме
            if(res[elements[i]].id==0) continue;     //+кого удалили не изменяем
            if (elements[i]<=res.length-1 ){
                res[elements[i]].hiredAs=job;    
            }
            else{
                revert('inappropriate index for resume');
            }
        }
    }

      function isHired(uint32 element) public view returns(string memory job){  //геттер
        if ((keccak256(abi.encodePacked((res[element].hiredAs))) == keccak256(abi.encodePacked((""))))){
            return ("none");
        }
        else {
            return (res[element].hiredAs);
        }
    }

    function addResume (uint256 id,string memory job, uint8 experience,bool advancedEnglish, bool higherEdu) public checkMaxResAndDay(){
        require(advancedEnglish==true,"We aren't sure you're the right fit.");
        res.push(resume(id,job,experience,block.timestamp,"",advancedEnglish,higherEdu));
        }

    function changeResumeAll(uint32 element,string memory job, uint8 experience,bool advancedEnglish, bool higherEdu) onlyOwner external {
        if(advancedEnglish==false) setToDeafultResume(element);
        else res[element]=resume(res[element].id,job,experience,block.timestamp,"",advancedEnglish,higherEdu);
    }
    
    function updateResumeForOne(uint32 element, uint16 _experience) onlyOwner external {
        res[element].experience=_experience;
    }
         
    function output (uint32 element) public view returns(uint256 id,string memory job, uint16 experience, uint256 timeExp,bool advancedEnglish, bool higherEdu){
        if (element<0)revert("Elements are positive");
         return (res[element].id,res[element].job,res[element].experience,res[element].time,res[element].advancedEnglish,res[element].higherEdu);
     }          //для красивого вывода без кортежа;если такого элемента нет revert автоматом
                                                                 //выдает исключение

    function setToDeafultResume(uint32 element) onlyOwner public {
       delete  res[element];      
   }
                        
   function howMuchResume() public view returns(uint256 amount){
       return (res.length);             //длина массива
   }

}