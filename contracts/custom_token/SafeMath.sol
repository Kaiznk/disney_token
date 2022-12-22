// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
pragma experimental ABIEncoderV2;


//Implementation of the SafeMath library to perform operations safely.
//Source "https://gist.github.com/giladHaimov/8e81dbde10c9aeff69a1d683ed6870be"

library SafeMath { 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256){
        if(a == 0)
            return 0;
        

        uint256 c = a * b;
        require(c/a ==b, "SafeMath: multiplication overflow");

        return c;
    }
}