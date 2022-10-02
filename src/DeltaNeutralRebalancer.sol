// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {IPositionManager} from "src/IPositionManager.sol";
import {NetTokenExposure} from "src/TokenExposure.sol";
import {TokenAllocation} from "src/TokenAllocation.sol";
import {TokenExposure} from "src/TokenExposure.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {IPriceUtils} from "src/IPriceUtils.sol";

uint256 constant FACTOR_ONE_MULTIPLIER = 1*10**6;
uint256 constant FACTOR_TWO_MULTIPLIER = 1*10**12;
uint256 constant FACTOR_THREE_MULTIPLIER = 1*10**18;

struct Trade {
  uint256 usdcAmount;
  IPositionManager positionManager; 
}

struct RebalanceData {
  TokenAllocation glpBtcAllocation;
  TokenAllocation glpEthAllocation;
  TokenAllocation btcPerpAllocation;
  TokenAllocation ethPerpAllocation;
  uint256 Pglp;
  uint256 Pbtcperp;
  uint256 Pethperp;
  uint256 totalLiquidity;
  uint256 glpMultiplier;
  uint256 btcPerpMultiplier;
}

contract DeltaNeutralRebalancer is Test {
  IPositionManager private glpPositionManager;
  IPositionManager private btcPerpPoolPositionManager;
  IPositionManager private ethPerpPoolPositionManager;
  address private btcAddress;
  address private ethAddress;

  constructor(
    address _glpPositionManagerAddress,
    address _btcPoolPositionManagerAddress,
    address _ethPoolPositionManagerAddress,
    address _btcAddress,
    address _ethAddress
  ) {
    glpPositionManager = IPositionManager(_glpPositionManagerAddress);
    btcPerpPoolPositionManager = IPositionManager(_btcPoolPositionManagerAddress);
    ethPerpPoolPositionManager = IPositionManager(_ethPoolPositionManagerAddress);
    btcAddress = _btcAddress;
    ethAddress = _ethAddress; 
  }

  function rebalance() public {
  }

  function getRebalancedAllocation() external returns (uint256, uint256, uint256) {
    uint256 totalLiquidity = getTotalLiquidity();
    // Get allocation information of assets inside positions
    TokenAllocation memory glpBtcAllocation = glpPositionManager.allocationByToken(btcAddress);
    TokenAllocation memory glpEthAllocation = glpPositionManager.allocationByToken(ethAddress);
    TokenAllocation memory btcPerpAllocation = btcPerpPoolPositionManager.allocationByToken(btcAddress);
    TokenAllocation memory ethPerpAllocation = ethPerpPoolPositionManager.allocationByToken(ethAddress);

    uint256 Pglp = glpPositionManager.price();
    uint256 Pbtcperp = btcPerpPoolPositionManager.price(); 
    uint256 Pethperp = ethPerpPoolPositionManager.price(); 

    RebalanceData memory rebalanceData = RebalanceData({
        glpBtcAllocation: glpBtcAllocation,
        glpEthAllocation: glpEthAllocation,
        btcPerpAllocation: btcPerpAllocation,
        ethPerpAllocation: ethPerpAllocation,
        Pglp: Pglp,
        Pbtcperp: Pbtcperp,
        Pethperp: Pethperp,
        totalLiquidity: totalLiquidity,
        glpMultiplier: 0,
        btcPerpMultiplier: 0
    });
    
    return this.calculateRebalancedPositions(rebalanceData);
  }

  function calculateRebalancedPositions(
    RebalanceData memory d
  )
  external returns (uint256, uint256, uint256) {
    (uint256 glpMultiplier, uint256 btcPerpMultiplier) = this.calculateMultipliers(d);
    d.glpMultiplier = glpMultiplier;
    d.btcPerpMultiplier = btcPerpMultiplier;
    return this.calculatePositionsToHave(d);
  }

  function calculateMultipliers(RebalanceData memory d) external returns (uint256, uint256) {
    uint256 glpMultiplier = d.Pbtcperp*d.btcPerpAllocation.leverage*d.btcPerpAllocation.percentage*FACTOR_ONE_MULTIPLIER/(d.Pglp*d.glpBtcAllocation.leverage*d.glpBtcAllocation.percentage);
    uint256 btcPerpMultiplier = FACTOR_TWO_MULTIPLIER * d.Pethperp * d.ethPerpAllocation.leverage * d.ethPerpAllocation.percentage / (d.Pglp * glpMultiplier * d.glpEthAllocation.leverage * d.glpEthAllocation.percentage);
    
    return (glpMultiplier, btcPerpMultiplier);
  }

  function calculatePositionsToHave(RebalanceData memory d) external returns (uint256, uint256, uint256) {
    uint256 amountOfPerpEthToHave = this.calculateAmountOfEthToHave(d);
    uint256 amountOfPerpBtcToHave = this.calculateAmountOfPerpBtcToHave(d, amountOfPerpEthToHave);
    uint256 amountOfGlpToHave = this.calculateAmountOfGlpToHave(d, amountOfPerpBtcToHave);

    return (amountOfGlpToHave, amountOfPerpBtcToHave, amountOfPerpEthToHave);
  }

  function calculateAmountOfEthToHave(RebalanceData memory d) external returns (uint256) {
    return d.totalLiquidity * FACTOR_THREE_MULTIPLIER / (d.Pglp*d.glpMultiplier*d.btcPerpMultiplier + d.Pbtcperp*d.btcPerpMultiplier*FACTOR_ONE_MULTIPLIER + (d.Pethperp*FACTOR_TWO_MULTIPLIER));
  }

  function calculateAmountOfPerpBtcToHave(RebalanceData memory d, uint256 amountOfPerpEthToHave) external returns (uint256) {
    return FACTOR_ONE_MULTIPLIER * d.Pethperp * amountOfPerpEthToHave * d.ethPerpAllocation.leverage * d.ethPerpAllocation.percentage / (d.Pglp * d.glpMultiplier * d.glpEthAllocation.leverage * d.glpEthAllocation.percentage);
  }

  function calculateAmountOfGlpToHave(RebalanceData memory d, uint256 amountOfPerpBtcToHave) external returns (uint256) {
    return d.Pbtcperp*amountOfPerpBtcToHave*d.btcPerpAllocation.leverage*d.btcPerpAllocation.percentage/(d.Pglp*d.glpBtcAllocation.leverage*d.glpBtcAllocation.percentage);
  }

  function getTotalLiquidity() private pure returns (uint256) {
    return 1000 * 10**6;
    // uint256 availableLiquidity = 0;
    // availableLiquidity += usdcToken.balanceOf(address(this));
    
    // for (uint i = 0; i < positionManagers.length; i++) {
    //   availableLiquidity += positionManagers[i].positionWorth();
    // }

    // return availableLiquidity;
  }
}