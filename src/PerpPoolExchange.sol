// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IExchange, Purchase} from "src/IExchange.sol";
import {IPoolCommitter} from "perp-pool/IPoolCommitter.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract PerpPoolExchange is IExchange {
  IPoolCommitter private poolCommitter;
  ERC20 private usdcToken;
  address private leveragedPoolAddress;
  constructor (address _poolCommitterAddress, address _usdcAddress, address _leveragedPoolAddress) {
    poolCommitter = IPoolCommitter(_poolCommitterAddress);
    usdcToken = ERC20(_usdcAddress);
    leveragedPoolAddress = _leveragedPoolAddress; 
  }

  function buy(uint256 usdcAmount) external returns (Purchase memory) {
    bytes memory commit = abi.encodePacked(usdcAmount);
    usdcToken.transferFrom(msg.sender, address(this), usdcAmount);
    usdcToken.approve(leveragedPoolAddress, usdcAmount);
    poolCommitter.commit(bytes32(commit));

    return Purchase({
      usdcAmount: usdcAmount,
      // Token amount is 0 as tokens are not minted straight away
      tokenAmount: 0
    });
  }

  function sell(uint256 usdcAmount) external returns (Purchase memory) {

  }

  function claim() external {
    poolCommitter.claim(address(this));
  }
}

