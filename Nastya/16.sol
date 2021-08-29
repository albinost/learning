/* Изучение спецификации ERC-20. Написать контракт с собственным токеном.
Комментарием до кода кратко описать функции, которые реализуются в стандартном ERC-20,
основное его назначение, а также какие еще виды спецификаций токенов существуют у Ethereum. 
---
Основное назначение: решение проблемы совместимости, поддержки различных токенов.
Функции в стандартном ERC-20: totalSupply, balanceOf, transfer, transferFrom, approve, allowance.
  totalSupply - всего токенов, константа
  balanceOf - количество токенов у адреса
  transfer, transferFrom - передача токенов от владельца к получателю 
    (transfer вызывается владельцем, transferFrom - может вызываться получателем и не только
    (при наличии разрешения у 3-ей стороны))
  approve - дать разрешение на получения n-ого количество токенов для конкретного адреса
  allowance - геттер, сколько токенов можно переслать с помощью transferFrom
  
Также у Ethereum есть спецификации ERC-223, ERC-721, ERC-777, ERC-809, ERC-1238 - самые популярные.
Расскажу о первых трех. 
ERC-223: есть totalSupply, balanceOf, 2 функции transfer (одна как в ERC-20, 
  другая - с аргументом bytes _data), без approve и allowance. 
  Предотвращает от случайных пересылок токенов.
ERC-721: есть balanceOf, transferFrom, approve, 2 safeTransferFrom (одна с bytes data),
  ownerOf(по id токена выдает адрес владельца), setApprovalForAll, isApprovedForAll.
  NFT токен - невзаимозаменяемый.
ERC-777: 
  view функции: name, symbol, totalSupply, balanceOf, granularity (самая маленькая, 
  неделимая часть токена), defaultOperators (список операторов по дефолту), isOperatorFor. 
  authorizeOperator - назначение оператора msg.sender, revokeOperator - устранить оператора.
  send (от msg.sender), operatorSend (отправка оператором от кого-то и кому-то) - передача токенов.
  burn, operatorBurn - уничтожение токенов владельцем, оператором.
  Улучшение ERC-20 (назначение операторов, быстрее транзакции), совместимость с ERC-20.

https://ropsten.etherscan.io/token/0x9e940498417dB5162fC4067E78Afb938b3763adA#readContract
*/
pragma solidity ^0.8.6;

interface IERC20 {
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
	
    function totalSupply() external view returns (uint256);
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function allowance(address owner, address spender) external view returns (uint256);
	function approve(address spender, uint256 amount) external returns (bool);
	function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}


//для мета транзакций (возможности оплаты 3-ей стороной)
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Token is  Context, IERC20 {       //интерфейс по рекомендации спецификации
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances; //разрешения на передачу 
                        //токенов, от владельца к другому адресу
    address payable public owner;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_, uint256 totalSupply_) {
        owner = payable(msg.sender);
        _name = name_;
        _symbol = symbol_;
        _totalSupply = totalSupply_;
        balances[msg.sender] = _totalSupply;    //все токены у создателя, потом - распределяет
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    //случайные деньги - к создателю контракта
    receive() external payable {    
        owner.call{value: msg.value}; 
    }

    function name() public virtual view returns (string memory) {
        return _name;
    }

    function symbol() public virtual view  returns (string memory) {
        return _symbol;
    }

    function decimals() public virtual pure returns (uint8) {
        return 18;
    }

    function totalSupply() public virtual override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public virtual override view returns (uint256) {
        return balances[account];
    }
    
    //от `msg.sender` отсылаются токены, вызывается tokenOwner
    function transfer(address to, uint256 amount) external virtual override returns (bool) {
        _transfer(_msgSender(), to, amount);     
        return true;
    }

    //если tokenOwner согласен с пересылкой токенов, то происходит их пересылка конкретному адресу
    //вызывается тем, у кого есть разрешение на пересылку
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external virtual override returns (bool) {
        uint256 currentAllowance = allowances[sender][_msgSender()];
        require(currentAllowance >= amount);
        _transfer(sender, recipient, amount);
        allowances[sender][_msgSender()] -= amount;
        return true;
    }

    function approve(address spender, uint256 amount) external virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
 
    function allowance(address tokenOwner, address spender) external virtual override view returns (uint256) {
        return allowances[tokenOwner][spender];
    }
    
    function increaseAllowance(address spender, uint256 addValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, allowances[_msgSender()][spender] + addValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subValue) public virtual returns (bool) {
        uint256 currentAllowance = allowances[_msgSender()][spender];
        require(currentAllowance >= subValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, allowances[_msgSender()][spender] - subValue);
        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        require(balances[sender] >= amount, "Unappropriate amount for transfer");
        balances[sender] -= amount;
        balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _approve(
        address tokenOwner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(amount <= _totalSupply, "Unappropriate amount for transfer"); 
        require(tokenOwner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowances[tokenOwner][spender] = amount;
        emit Approval(tokenOwner, spender, amount);
    }
}
