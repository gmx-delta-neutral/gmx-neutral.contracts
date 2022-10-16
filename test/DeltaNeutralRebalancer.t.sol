// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {DeltaNeutralRebalancer} from "src/DeltaNeutralRebalancer.sol";
import {IPositionManager} from "src/IPositionManager.sol";
import {TokenAllocation} from "src/TokenAllocation.sol";
import {RebalanceAction} from "src/RebalanceAction.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract DeltaNeutralRebalancerTest is Test {    
    DeltaNeutralRebalancer private deltaNeutralRebalancer;    
    address private glpPositionManagerAddress;
    address private btcPoolPositionManagerAddress; 
    address private ethPoolPositionManagerAddress; 
    address private btcAddress;
    address private ethAddress;
    address private usdcAddress;


    function setUp() public {
        glpPositionManagerAddress = address(1); 
        btcPoolPositionManagerAddress = address(2); 
        ethPoolPositionManagerAddress = address(3); 
        btcAddress = address(4);
        ethAddress = address(5);
        usdcAddress = address(6);
        
        vm.mockCall(
            address(1),
            abi.encodeCall(IPositionManager.price, ()),
            abi.encode(878726)
        );

        vm.mockCall(
            address(2),
            abi.encodeCall(IPositionManager.price, ()),
            abi.encode(1020000)
        );

        vm.mockCall(
            address(3),
            abi.encodeCall(IPositionManager.price, ()),
            abi.encode(1040000)
        );

        vm.mockCall(
            address(address(1)),
            abi.encodeCall(IPositionManager.allocationByToken, (btcAddress)),
            abi.encode(TokenAllocation({
                percentage: 150,
                tokenAddress: btcAddress,
                leverage: 1
            }))
        );

        vm.mockCall(
            address(address(1)),
            abi.encodeCall(IPositionManager.allocationByToken, (ethAddress)),
            abi.encode(TokenAllocation({
                percentage: 200,
                tokenAddress: ethAddress,
                leverage: 1
            }))
        );

        vm.mockCall(
            address(address(2)),
            abi.encodeCall(IPositionManager.allocationByToken, (btcAddress)),
            abi.encode(TokenAllocation({
                percentage: 1000,
                tokenAddress: btcAddress,
                leverage: 3
            }))
        );

        vm.mockCall(
            address(address(3)),
            abi.encodeCall(IPositionManager.allocationByToken, (ethAddress)),
            abi.encode(TokenAllocation({
                percentage: 1000,
                tokenAddress: ethAddress,
                leverage: 3
            }))
        );

        vm.mockCall(
            glpPositionManagerAddress,
            abi.encodeWithSelector(IPositionManager.getRebalanceAction.selector),
            abi.encode(RebalanceAction.Buy)
        );
        vm.mockCall(
            btcPoolPositionManagerAddress,
            abi.encodeWithSelector(IPositionManager.getRebalanceAction.selector),
            abi.encode(RebalanceAction.Buy)
        );
        vm.mockCall(
            ethPoolPositionManagerAddress,
            abi.encodeWithSelector(IPositionManager.getRebalanceAction.selector),
            abi.encode(RebalanceAction.Buy)
        );

        vm.mockCall(
            glpPositionManagerAddress,
            abi.encodeCall(IPositionManager.rebalance, (895523401)),
            abi.encode(true)
        );
        vm.mockCall(
            btcPoolPositionManagerAddress,
            abi.encodeCall(IPositionManager.rebalance, (44776170)),
            abi.encode(true)
        );
        vm.mockCall(
            ethPoolPositionManagerAddress,
            abi.encodeCall(IPositionManager.rebalance, (59701558)),
            abi.encode(true)
        );

        vm.mockCall(
            usdcAddress,
            abi.encodeWithSelector(ERC20.approve.selector),
            abi.encode(true)
        );

        deltaNeutralRebalancer = new DeltaNeutralRebalancer(btcAddress, ethAddress, usdcAddress);
        deltaNeutralRebalancer.setGlpPositionManager(glpPositionManagerAddress);
        deltaNeutralRebalancer.setBtcPerpPoolManager(btcPoolPositionManagerAddress);
        deltaNeutralRebalancer.setEthPerpPoolManager(ethPoolPositionManagerAddress);
    }

    function testRebalance() public {
        vm.expectCall(
            glpPositionManagerAddress,
            abi.encodeCall(IPositionManager.rebalance, (895523401))
        );

        vm.expectCall(
            btcPoolPositionManagerAddress,
            abi.encodeCall(IPositionManager.rebalance, (44776170))
        );

        vm.expectCall(
            ethPoolPositionManagerAddress,
            abi.encodeCall(IPositionManager.rebalance, (59701558))
        );

        deltaNeutralRebalancer.rebalance();
   }
}


