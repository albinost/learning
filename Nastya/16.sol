Изучение спецификации ERC-20. Написать контракт с собственным токеном.
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

https://ropsten.etherscan.io/address/0x72C15eC3bb0A9583aCAC68626E19b97891437F9B#code

pragma solidity ^0.8.6;

import {SimpleMath} from './math.sol';    //для add и sub в transfer,transferFrom

interface IERC20 {
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
	
    function totalSupply() external pure returns (uint256);
	function balanceOf(address account) external view returns (uint256);
	function transfer(address to, uint256 tokens) external returns (bool);
	function allowance(address tokenOwner, address spender) external view returns (uint256);
	function approve(address spender, uint256 tokens) external returns (bool);
	function transferFrom(address from, address to, uint256 tokens) external returns (bool);
}

contract Tokens is IERC20 {       //интерфейс по рекомендации спецификации
    using SimpleMath for uint256;

    address payable public owner;
    string public _name;            
    string public _symbol;
    uint256 public constant _totalSupply = 1000; 

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances; //разрешения на передачу 
                        //токенов, от владельца к другому адресу

    constructor(string memory name_, string memory symbol_) {
        owner = payable(msg.sender);
        _name = name_;
        _symbol = symbol_;
        balances[msg.sender] = _totalSupply;    //все токены у создателя, потом - распределяет
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    //случайные деньги - к создателю контракта
    receive () external payable {    
        owner.call{value: msg.value}; 
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view  returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public override pure returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public override view returns (uint256) {
        return balances[account];
    }
    
     ///от `msg.sender` отсылаются токены, вызывается tokenOwner
    function transfer(address to, uint256 tokens) external override returns (bool) {
        require(balances[msg.sender] >= tokens);
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    ///если tokenOwner согласен с пересылкой токенов, то происходит их пересылка конкретному адресу
    ///вызывается не владельцем токена, а тем, у кого есть разрешение на пересылку
    function transferFrom(
        address from,           ///tokenOwner
        address to,
        uint256 tokens
    ) public override returns (bool) {
        uint256 currentAllowance = allowances[from][msg.sender];
        require(currentAllowance >= tokens && balances[from] >= tokens);
        balances[from] = balances[from].sub(tokens);
        allowances[from][msg.sender] = allowances[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    function approve(address spender, uint256 tokens) public override returns (bool) {
        require(spender != address(0) && tokens <= _totalSupply);        
        allowances[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
 
    function allowance(address tokenOwner, address spender) external override view returns (uint256) {
        return allowances[tokenOwner][spender];
    }
    
    ///extra functions, вызываются tokenOwner
    function increaseAllowance(address spender, uint256 addTokens) external returns (bool) {
        approve(spender, allowances[msg.sender][spender] + addTokens);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subTokens) external  returns (bool) {
        uint256 currentAllowance = allowances[msg.sender][spender];
        require(currentAllowance >= subTokens, "ERC20: decreased allowance below zero");
        approve(spender, currentAllowance - subTokens);
        return true;
    }
}
