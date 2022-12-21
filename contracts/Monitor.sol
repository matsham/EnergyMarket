// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

import '@openzeppelin/contracts/access/Ownable.sol';
import './energy_market.sol';

interface IERC721 {
    
}
contract Monitor is Ownable {

    constructor () public  {
        _transferOwnership(_msgSender());
    }
    
    

}