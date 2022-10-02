// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IPoolCommitter} from "perp-pool/IPoolCommitter.sol";

contract PerpPoolClaimer {
  IPoolCommitter private poolCommitter;  

  constructor(address _poolCommitterAddress) {
    poolCommitter = IPoolCommitter(_poolCommitterAddress);
  }

}