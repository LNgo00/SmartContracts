// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract MultiSend {
    
    // to save the owner of the contract in construction
    address private owner;
    
    // to save the amount of ethers in the smart-contract
    using SafeMath for uint;
    
    address tokenadr;

    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    
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
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor(address token) {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
        tokenadr = token;


    }
    
    // the owner of the smart-contract can chage its owner to whoever 
    // he/she wants
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner; 
    }
    

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
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
    function depositERC20(uint  amount) public isOwner returns (uint) {
        console.log("comprobando monto aprobado");
        console.log(IERC20(tokenadr).allowance(msg.sender,address(this)));
        IERC20(tokenadr).transferFrom(msg.sender,address(this),amount); 
        console.log("transferido");
        return IERC20(tokenadr).balanceOf(address(this));
    }

    //Send ERC20 token from the Smart Contract to the receiver's address
    function sendTokens( uint  amount, address  to) public isOwner {
        require(IERC20(tokenadr).balanceOf(address(this))>=amount, "Not enough tokens to send");
        IERC20(tokenadr).transfer(to,amount);
        console.log("transferido");
    }

    function checkAllowance() view public returns (uint){
        return IERC20(tokenadr).allowance(msg.sender,address(this));
    }

    //Return ERC20 token balance of the Smart Contract
    function getBalance() public view returns (uint){
        return IERC20(tokenadr).balanceOf(address(this));
    }

    //Send distint amount of ERC20 token to distint addresses
    function multisendOwnERC20(address[] memory addrs, uint[] memory amnts) public isOwner {
        require(addrs.length == amnts.length, "The length of two array should be the same"); //Check if the array with addresses has the same length with the array with amounts
        require(IERC20(tokenadr).balanceOf(address(this))>= sum(amnts), "Not enough tokens to send"); //Check if the Contract has enough liquidity to perform all the transactions

        for(uint i=0;i<addrs.length; i++){
            sendTokens(amnts[i],addrs[i]);
        }


    }

}