// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC20Burnable } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";


contract SampleToken is ERC20, ERC20Burnable {

    address  gateway;


    constructor(uint256 _initialSupply, address _gateway) ERC20("SampleToken", "SC") {
        gateway = _gateway;
        _mint(msg.sender, _initialSupply);
    }


     function mint( address _recipient, uint256 _amount ) public virtual onlyBridge{
        _mint(_recipient, _amount);
    }

     function burn(uint256 _amount) public override(ERC20Burnable)   virtual onlyBridge {
        super.burn(_amount);
    }

     function burnFrom(address _requester, uint256 _amount) public override(ERC20Burnable)   virtual onlyBridge {
        super.burnFrom(_requester, _amount);
    }

   modifier onlyBridge {
      require(msg.sender == gateway, "only bridge has access to this child token function");
      _;
    }
}