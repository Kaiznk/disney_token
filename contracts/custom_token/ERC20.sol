pragma solidity ^0.8.17;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";

//ERC20 Interface
interface IERC20{
    //returns the number of tokens in existence
    function totalSupply() external view returns(uint256);

    function increaseTotalSupply(uint newTokensAmount) external;

    //returns the number of tokens for an address indicated by parameter
    function balanceOf(address account) external view returns(uint256);

    //returns the number of tokens that the spender will be able to spend on behalf of the owner
    function allowance(address owner, address spender) external view returns(uint256);

    //returns a boolean value that is the result of the indicated operation
    function transfer(address receiver, uint256 amount) external returns(bool);

    function transfer_disney(address _costumer,address receiver, uint256 amount) external returns(bool);

    //returns a boolean value with the result of the spend operation
    function approve(address spender, uint256 amount) external returns(bool);

    //returns a boolean value with the result of the operation to pass a number of tokens using the allowance method
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool); 

    //event to be emitted when a number of tokens passes from a source to a destination
    event Transfer(address indexed from, address indexed to , uint256 value);

    //event to be emitted when an allocation is established with the allowance method
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20Basic is IERC20{

    string public constant name = "ERC20BlockchainAZ";
    string public constant symbol = "ERC";
    uint8 public constant decimals = 18;

    /*event Transfer(address indexed from, address indexed to , uint256 tokens);
    event Approval(address indexed owner, address indexed spender, uint256 tokens);*/

    using SafeMath for uint256;

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
    uint256 totalSupply_;

    constructor(uint256 initialSupply) public{
        totalSupply_ = initialSupply;
        balances[msg.sender] = totalSupply_;
    }

function totalSupply() public override view returns(uint256){
return totalSupply_;
}

function increaseTotalSupply(uint newTokensAmount) public override{
    totalSupply_ += newTokensAmount;
    balances[msg.sender] += newTokensAmount;
} 
function balanceOf(address tokenOwner) public override view returns(uint256){
    return balances[tokenOwner];
}

function allowance(address owner, address delegate) public override view returns(uint256){
return allowed[owner][delegate];     
}

function transfer(address receiver, uint256 numTokens) public override returns(bool){
    require(numTokens <= balances[msg.sender]);
    balances[msg.sender] = balances[msg.sender].sub(numTokens);
    balances[receiver] = balances[receiver].add(numTokens);
    emit Transfer (msg.sender, receiver, numTokens);
    return true;

}

function transfer_disney(address _costumer,address receiver, uint256 numTokens) public override returns(bool){
    require(numTokens <= balances[_costumer]);
    balances[_costumer] = balances[_costumer].sub(numTokens);
    balances[receiver] = balances[receiver].add(numTokens);
    emit Transfer (_costumer, receiver, numTokens);
    return true;

}

function approve(address delegate, uint256 numTokens) public override returns (bool){
    allowed[msg.sender][delegate] = numTokens;
    emit Approval(msg.sender, delegate, numTokens);
    return true;
}

function transferFrom(address owner, address buyer, uint256 numTokens) public override returns(bool){
    require(numTokens <= balances[owner]);
    allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
    balances[buyer] = balances[buyer].add(numTokens);
    emit Transfer(owner, buyer, numTokens);
    return false;
}

}