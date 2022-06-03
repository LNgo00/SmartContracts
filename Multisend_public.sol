// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MultiSendPublic is ReentrancyGuard {
    
    // to save the owner of the contract in construction
    address private owner;
    
    // to save the amount of ethers in the smart-contract
    using SafeMath for uint;
    
    uint public feeAmount;

    // map to save the amount of tokends stored from each user divided for each token address
    mapping (address=>mapping(address=>uint)) Token_User_Amount;

    // map to save Admin addresses
    mapping (address => bool) AdminAddresses;

    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    
    // event for Deposit token and Sending token
    event TokenTransfer(uint oldAmount, uint newAmount);
    
    // modifier to check if the caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    modifier isAdmin() {
        require(AdminAddresses[msg.sender] == true, "Caller is not admin");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor(uint _fee) ReentrancyGuard() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
        AdminAddresses[owner] = true;
        feeAmount = _fee;
    }
    
    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }


    function getBalanceOfAddress(address tokenadr, address user) external view returns (uint) {
        return Token_User_Amount[tokenadr][user];
    }


    // the owner of the smart-contract can chage its owner to whoever 
    // he/she wants
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner; 
    }

    function setFee(uint _fee) public isOwner {
        feeAmount = _fee;
    }

    function getFee() public view returns (uint) {
        return feeAmount;
    }

    function addAdmin(address newAdmin) public isAdmin {
        AdminAddresses[newAdmin] = true;
    }

    function deleteAdmin(address noAdmin) public isAdmin {
        AdminAddresses[noAdmin] = false;
    }

    function checkAdminRole(address user) public view returns (bool) {
        return AdminAddresses[user];
    }
    
    function withdrawTokens(address tokenadr, uint amount) public nonReentrant {
        sendTokens(tokenadr,amount, msg.sender);
       
    }
    
    
    
    // sum adds the different elements of the array and return its sum
    function sum(uint[] memory amounts) private pure returns (uint retVal) {
        // the value of message should be exact of total amounts
        uint totalAmnt = 0;
        bool x;

        for (uint i=0; i < amounts.length; i++) {
          ( x ,totalAmnt) = totalAmnt.tryAdd(amounts[i]);
        }
        
        return totalAmnt;
    }
    
    
    //Charge the smart contract with ERC20 token
    function depositERC20(address tokenadr, uint  amount) public nonReentrant {
        console.log("comprobando monto aprobado");
        require(amount>0, "Deposit an amount greater than 0");

        uint oldAmount = Token_User_Amount[tokenadr][msg.sender];
        uint newAmount = Token_User_Amount[tokenadr][msg.sender] + amount;
        IERC20(tokenadr).transferFrom(msg.sender,address(this),amount);
        Token_User_Amount[tokenadr][msg.sender] = newAmount;
         
        emit TokenTransfer(oldAmount, newAmount);

        console.log("transferido");
    }

    //Send ERC20 token from the Smart Contract to the receiver's address
    function sendTokens(address tokenadr, uint  amount, address  to) internal  {
        require(Token_User_Amount[tokenadr][msg.sender]>=amount, "Not enough tokens to send");

        uint oldAmount =  Token_User_Amount[tokenadr][msg.sender];
        uint newAmount =  Token_User_Amount[tokenadr][msg.sender] - amount;
        Token_User_Amount[tokenadr][msg.sender] = newAmount;
        IERC20(tokenadr).transfer(to,amount);
        emit TokenTransfer(oldAmount, newAmount);

        console.log("transferido");
    }

    function checkAllowance(address tokenadr) view public returns (uint){
        return IERC20(tokenadr).allowance(msg.sender,address(this));
    }

    //Return ERC20 token balance of the Smart Contract
    function getBalance(address tokenadr) public view returns (uint){
        return IERC20(tokenadr).balanceOf(address(this));
    }

    //Send distint amount of ERC20 token to distint addresses
    function multisendOwnERC20(address tokenadr, address[] memory addrs, uint[] memory amnts) public nonReentrant {
        require(addrs.length == amnts.length, "The length of two array should be the same"); //Check if the array with addresses has the same length with the array with amounts
        uint amountToTransfer = sum(amnts);
        require(Token_User_Amount[tokenadr][msg.sender]>= amountToTransfer, "Not enough tokens to send"); //Check if the Contract has enough liquidity to perform all the transactions
        require(AdminAddresses[msg.sender] == true || IERC20(tokenadr).transferFrom(
                msg.sender, // from the user
                owner, // to this contract
                feeAmount * 10 ** 18) // 50 tokens, incl. decimals of the token contract
             == true ,
            'Could not transfer tokens from your address to this contract' // error message in case the transfer was not successful
        );
        uint oldAmount =  Token_User_Amount[tokenadr][msg.sender];
        uint newAmount =  Token_User_Amount[tokenadr][msg.sender] - amountToTransfer;
        for(uint i=0;i<addrs.length; i++){
            sendTokens(tokenadr,amnts[i],addrs[i]);
        }

        emit TokenTransfer(oldAmount, newAmount);
    }

}