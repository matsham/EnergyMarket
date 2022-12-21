// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import './MarketBase.sol';
import './energy_market.sol';

contract MarketFactory is MarketBase {

  address[] public instances;

  function createInstance(address _Owner) override public payable returns (address) {
    _Owner;
    EnergyMarket instance = new EnergyMarket();
    return address(instance);

    instances.push(address(instance));
    
  }

  function validateInstance(address payable _instance, address _Owner) override public returns (bool) {
    Fallback instance = Fallback(_instance);
    return instance.owner() == _Owner && address(instance).balance == 0;
  }
}