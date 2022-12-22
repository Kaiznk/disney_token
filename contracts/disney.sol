pragma solidity ^0.8.17;
pragma experimental ABIEncoderV2;
import "./custom_token/ERC20.sol";

contract Disney{

    //Token contract instance
    ERC20Basic private token;

    //Owner's address
    address payable public owner;

    //Constructor
    constructor() public {
        token = new ERC20Basic(1000);
        owner = payable(msg.sender);
    }

    //Data structure to store Disney customers
    struct costumer{
        uint purchased_tokens;
        string [] attractions_enjoyed;
    }

    //Mapping for customer registration
    mapping (address => costumer) public Costumers;

    //Function to set the price of a token
    function TokensPrice(uint _numTokens) internal pure returns (uint){
        //Tokens to Ethers: 1 Token -> 1 ether
        return _numTokens*(1 ether);
    }

    //Function to buy Disney Tokens
    function BuyTokens(uint _numTokens) public payable{
        //Set the price of the Tokens
        uint cost = TokensPrice(_numTokens);
        //the money that the client pays for the Tokens is evaluated
        require (msg.value >= cost, "Buy less tokens or pay with more ethers");
        //difference in what the customer pays
        uint returnValue = msg.value - cost;
        //Disney returns the amount of ethers to the client
        payable(msg.sender).transfer(returnValue);
        //get the number of tokens available
        uint Balance = balanceOf();
        require(_numTokens <= Balance, "Buy a smaller amount of tokens");
        //
        token.transfer(msg.sender, _numTokens);
        //Record of purchased tokens
        Costumers[msg.sender].purchased_tokens = _numTokens;

    }

    //balance of disney contract tokens
    function balanceOf() public view returns (uint){
        return token.balanceOf(address(this));
    }

    //display the number of remaining tokens of a Client
    function MyTokens() public view returns (uint){
        return token.balanceOf(msg.sender);
    }

    //Function to generate more tokens
    function GenerateTokens(uint _numTokens) public Only(msg.sender){
        token.increaseTotalSupply(_numTokens);
    }

    //Modifier to control executable functions by disney
    modifier Only(address _direction){
        require(_direction == owner, "You do not have permissions to execute this function");
        _;
    }

    //Events
    event enjoy_attraction(string, uint, address);
    event new_attraction(string, uint);
    event discontinue_attraction(string);

    event enjoy_food(string, uint, address);
    event new_food(string, uint, bool);
    event discontinue_food(string);

    struct attraction{
        string attraction_name;
        uint attraction_price;
        bool attraction_status;
    }

    struct food{
        string food_name;
        uint food_price;
        bool food_status;
    }
    
    //Mapping to relate an attraction name to an attraction data structure
    mapping (string => attraction) public MappingAttractions;

    //Mapping to relate a food name to a food data structure
    mapping (string => food) public MappingFood;

    //Array to store the name of the attractions
    string [] Attractions;

    string [] Foods;

    //Mapping to relate an identity (customer) with their history at Disney
    mapping (address => string []) AttractionsHistory;

    //Mapping to relate an identity (customer) with the food that he have eaten at Disney
    mapping (address => string []) FoodsHistory;

    //Create new attractions for Disney
    function NewAttraction( string memory _attraction_name, uint _price) public Only(msg.sender){
        //Creating an attraction at Disney
        MappingAttractions[_attraction_name] = attraction(_attraction_name, _price, true);
        //
        Attractions.push(_attraction_name);
        //
        emit new_attraction(_attraction_name, _price);
    }
    
    //Create new menus for Disney food (only executable by Disney)
    function NewFood(string memory _nameFood, uint _price) public Only(msg.sender){
        //Creating a Disney Meal
        MappingFood[_nameFood] = food(_nameFood, _price, true);
        //Store in an array the meals that a person has ordered
        Foods.push(_nameFood);
        //Broadcast event for the new food at Disney
        emit new_food(_nameFood, _price, true);

    }

    //discontinue attractions at disney
    function DiscontinueAttraction(string memory _attractionName) public Only(msg.sender){
        //The attraction status changes to False => NOT in use
        MappingAttractions[_attractionName].attraction_status = false;
        //Broadcast the event to discontinue the attraction
        emit discontinue_attraction(_attractionName);
    }

    //discontinue a Disney meal
    function DiscontinueFood(string memory _nameFood) public Only(msg.sender){
        //The food status changes to False => it cannot be eaten
        MappingFood[_nameFood].food_status = false;
        //Broadcast the event to discontinue the food
        emit discontinue_food(_nameFood);
    }

    //view Disney attractions
    function AvailableAttractions() public view returns (string [] memory){
        return Attractions;
    }

    //visualize disney foods
    function AvailableFoods() public view returns (string [] memory){
        return Foods;
    }


    //Function to get on a Disney attraction and pay in tokens
    function rideAttraction (string memory _attractionName) public{
        //Attraction price (in tokens)
        uint tokens_attraction = MappingAttractions[_attractionName].attraction_price;
        //Check the status of the attraction (if it is available for use)
        require (MappingAttractions[_attractionName].attraction_status == true, "The attraction is not available right now.");
        //Check the number of tokens the customer has to get on the attraction
        require(tokens_attraction <= MyTokens(), "You need more tokens to get on the attraction");

        token.transfer_disney(msg.sender, address(this), tokens_attraction);
        //Storage in customer attraction history
        AttractionsHistory[msg.sender].push(_attractionName);
        //Emission of the event to enjoy the attraction
        emit enjoy_attraction(_attractionName, tokens_attraction, msg.sender);
    }

    //Function to get on a Disney attraction and pay in tokens
    function BuyFood (string memory _nameFood) public{
        //Food price (in tokens)
        uint tokens_food = MappingFood[_nameFood].food_price;
        //Check the status of the attraction (if it is available for use)
        require (MappingFood[_nameFood].food_status == true, "The attraction is not available right now.");
        //Check the number of tokens the customer has to get on the attraction
        require(tokens_food <= MyTokens(), "You need more tokens to get on the attraction");

        token.transfer_disney(msg.sender, address(this), tokens_food);
        //Storage in customer attraction history
        FoodsHistory[msg.sender].push(_nameFood);
        //Emission of the event to enjoy the attraction
        emit enjoy_attraction(_nameFood, tokens_food, msg.sender);
    }

    //View the complete history of attractions enjoyed by a customer
    function HistoryA() public view returns (string [] memory){
        return AttractionsHistory[msg.sender];
    }

    //View the complete history of attractions enjoyed by a customer
    function HistoryF() public view returns (string [] memory){
        return FoodsHistory[msg.sender];
    }

    //Function for a Disney customer to return Tokens
    function ReturnTokens (uint _numTokens) public payable{
        //the number of tokens to return is positive
        require (_numTokens > 0, "You need to return a positive amount of tokens");
        //the user must have the number of tokens that he wishes to return
        require (_numTokens <= MyTokens(), "You don't have the tokens you want to return");
        //the costumer returns the tokens
        token.transfer_disney(msg.sender, address(this), _numTokens);
        //Return of ethers to the customer
        payable(msg.sender).transfer(TokensPrice(_numTokens));
    }

}