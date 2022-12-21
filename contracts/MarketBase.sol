// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import '@openzeppelin/contracts/access/Ownable.sol';

abstract contract  MarketBase is Ownable {
  function createInstance(address _Owner) virtual public payable returns (address);
  function validateInstance(address payable _instance, address _Owner) virtual public returns (bool);
}