// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../../shared/Fixture.t.sol";
import "../../../src/Caviar.sol";

contract AddBuySellRemoveTest is Fixture {
    function testItAddsBuysSellsRemovesCorrectAmount(
        uint256 addBaseTokenAmount,
        uint256 addFractionalTokenAmount,
        uint256 buyTokenAmount
    ) public {
        addBaseTokenAmount = bound(addBaseTokenAmount, 100, type(uint96).max);
        addFractionalTokenAmount = bound(addFractionalTokenAmount, 2, 10_000_000 * 1e18);
        buyTokenAmount = bound(buyTokenAmount, 1, addFractionalTokenAmount - 1);

        // add liquidity
        deal(address(usd), address(this), addBaseTokenAmount, true);
        deal(address(p), address(this), addFractionalTokenAmount, true);
        uint256 lpTokenAmount = Math.sqrt(addBaseTokenAmount * addFractionalTokenAmount);
        usd.approve(address(p), type(uint256).max);
        p.add(addBaseTokenAmount, addFractionalTokenAmount, lpTokenAmount);

        // buy some amount
        uint256 baseTokenBuyAmount = p.buyQuote(buyTokenAmount);
        deal(address(usd), address(this), baseTokenBuyAmount, true);
        p.buy(buyTokenAmount, baseTokenBuyAmount);

        // remove some fraction of liquidity
        uint256 removeLpTokenAmount = lpTokenAmount / 10;
        uint256 expectedBaseTokenAmount = p.baseTokenReserves() * removeLpTokenAmount / lpToken.totalSupply();
        uint256 expectedFractionalTokenAmount =
            p.fractionalTokenReserves() * removeLpTokenAmount / lpToken.totalSupply();
        (uint256 baseTokenOutputAmount, uint256 fractionalTokenOutputAmount) = p.remove(removeLpTokenAmount, 0, 0);

        assertEq(baseTokenOutputAmount, expectedBaseTokenAmount, "Should have removed correct base token amount");
        assertEq(
            fractionalTokenOutputAmount,
            expectedFractionalTokenAmount,
            "Should have removed correct fractional token amount"
        );
    }

        function testItAddsRemovesCorrectAmount() public {
        console.log("Base:fractional:LP ",type(uint96).max);
                // add liquidity
        uint initBaseTokenAmount = 1000e18;
        uint initFractionalTokenAmount = 10e18;
        deal(address(usd), address(this), initBaseTokenAmount, true);
        deal(address(p), address(this), initFractionalTokenAmount, true);
        uint256 minLpTokenAmount = Math.sqrt(initBaseTokenAmount * initFractionalTokenAmount);
        usd.approve(address(p), type(uint256).max);
        uint initlpTokenAmount = p.add(initBaseTokenAmount, initFractionalTokenAmount, minLpTokenAmount);

        console.log("initated Pool ",initBaseTokenAmount,initFractionalTokenAmount,initlpTokenAmount);
        console.log("Pool Info ->  ",usd.balanceOf(address(p)),p.balanceOf(address(p)),lpToken.totalSupply());

        console.log("-------------------------------------------------------");

        uint addBaseTokenAmount = 300e18;
        uint addFractionalTokenAmount = 1e18;
        deal(address(usd), babe, addBaseTokenAmount, true);
        deal(address(p), babe, addFractionalTokenAmount, true);

        vm.startPrank(babe);
        usd.approve(address(p), type(uint256).max);


        console.log("adding ",addBaseTokenAmount,addFractionalTokenAmount);

        minLpTokenAmount = p.addQuote(addBaseTokenAmount,addFractionalTokenAmount);
        uint addedlpTokenAmount = p.add(addBaseTokenAmount, addFractionalTokenAmount, minLpTokenAmount);
        console.log("----------------------- after Added ---------------------");
        // console.log(lpToken.totalSupply(),addBaseTokenAmount,addFractionalTokenAmount);
        console.log("Pool Info ->  ",usd.balanceOf(address(p)),p.balanceOf(address(p)),lpToken.totalSupply());
        console.log("babe's balance ",usd.balanceOf(address(babe)),p.balanceOf(address(babe)),lpToken.balanceOf(address(babe)));


        console.log("----------------------- after Removed ---------------------");

        (uint a,uint b) = p.removeQuote(addedlpTokenAmount);
        p.remove(addedlpTokenAmount,a,b);

        console.log("Pool Info ->  ",usd.balanceOf(address(p)),p.balanceOf(address(p)),lpToken.totalSupply());
        console.log("babe's balance ",usd.balanceOf(address(babe)),p.balanceOf(address(babe)),lpToken.balanceOf(address(babe)));


        // since there is no swaps,removing will have to return same amt of token deposited

        uint baseTokenBalAfterRemoval = usd.balanceOf(address(babe));

        assertEq(addBaseTokenAmount,baseTokenBalAfterRemoval,"must return same amt deposited since no swaps");

        console.log("diff -> ",( addBaseTokenAmount - baseTokenBalAfterRemoval)/1e18,( addBaseTokenAmount - baseTokenBalAfterRemoval)%1e18);



        vm.stopPrank();

    }
}
