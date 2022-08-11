// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Burnable}  from './IERC20Burnable.sol';



contract Bridge {

    mapping(address => mapping(address=> bool)) private tokensmap;
    address gateway;


    // Source chain events
    event TokensLocked(address indexed makerContract, address indexed takerContract, address requester, uint256 amount, uint timestamp);
    event TokensUnlocked(address indexed makerContract,address indexed takerContract, address requester, uint256 amount, uint timestamp);
    
    event TokensMapped(address indexed makerContract, address indexed takerContract);
   
    // Destination chain event
    event TokensBridged(address indexed makerContract,address indexed takerContract, address requester, uint256 amount, uint timestamp);
    event TokensReturned(address indexed makerContract,address indexed takerContract, address requester, uint256 amount, uint timestamp);
    
    constructor(address _gateway) {
        gateway = _gateway;
    }


    // Source Chain Methods
    // MakerContract = source chain contract 
    // TakerContract = dest chain contract
     function lockTokens (address _makerContract, address _takerContract, address _requester, uint256 _bridgedAmount) onlyGateway external {
        require(_bridgedAmount > 1*10**(18), "please select more than 1 AMT");
        require(tokensmap[_makerContract][_takerContract] == true, "tokens are  not mapped");

        IERC20 mainToken = IERC20(_makerContract);
        mainToken.transferFrom(_requester, address(this), _bridgedAmount);
        emit TokensLocked(_makerContract, _takerContract, _requester,  _bridgedAmount,block.timestamp);
    }

    function unlockTokens(address _makerContract, address _takerContract, address _requester, uint256 _bridgedAmount) onlyGateway external {
         IERC20 mainToken = IERC20(_makerContract);
         require(mainToken.balanceOf(address(this)) >= _bridgedAmount, "unable to transfer; due to insuffient funds");

        mainToken.transfer(_requester, _bridgedAmount);
        emit TokensUnlocked(_makerContract, _takerContract, _requester, _bridgedAmount, block.timestamp);
    }


    // Destination Chain Methods
    //Note: source chain takerContract here is makerContract
    function mint(address _makerContract, address _takerContract, address _requester, uint256 _bridgedAmount)  onlyGateway external {

        IERC20Burnable  mainToken = IERC20Burnable(_makerContract);
        mainToken.mint(_requester, _bridgedAmount);
        emit TokensBridged(_makerContract, _takerContract, _requester, _bridgedAmount, block.timestamp);
    }

     function burn(address _makerContract, address _takerContract, address _requester, uint256 _bridgedAmount) onlyGateway external {
         require(tokensmap[_makerContract][_takerContract] == true, "tokens are  not mapped");

        IERC20Burnable  mainToken = IERC20Burnable(_makerContract);
        mainToken.burnFrom(_requester, _bridgedAmount);
        emit TokensReturned(_makerContract, _takerContract, _requester, _bridgedAmount, block.timestamp);
    }

    
    // Make sure to add source chain first and then destination chain 
    function addTokenMap(address _makerContract, address _takerContract) onlyGateway external {
        require(tokensmap[_makerContract][_takerContract] == false, "Already tokens are mapped");
        tokensmap[_makerContract][_takerContract] = true;
        emit TokensMapped( _makerContract, _takerContract);
    }


    modifier onlyGateway {
      require(msg.sender == gateway, "only gateway can execute this function");
      _;
}
    

}
