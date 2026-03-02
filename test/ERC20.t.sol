// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken token;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address spender = makeAddr("spender");

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function setUp() public {
        token = new MyToken("MyToken", "MTK", 18);
        bool ok = token.transfer(alice, 1_000 ether);
        assertTrue(ok);
    }

    function testTransfer() public {
        uint256 amount = 10 ether;
        uint256 aliceBefore = token.balanceOf(alice);
        uint256 bobBefore = token.balanceOf(bob);
        uint256 supplyBefore = token.totalSupply();

        vm.prank(alice);
        bool ok = token.transfer(bob, amount);

        assertTrue(ok);
        assertEq(token.balanceOf(alice), aliceBefore - amount);
        assertEq(token.balanceOf(bob), bobBefore + amount);
        assertEq(token.totalSupply(), supplyBefore);
    }

    function testApprove() public {
        uint256 amount = 50 ether;
        vm.expectEmit(true, true, false, true);
        emit Approval(alice, spender, amount);
        vm.prank(alice);
        bool ok = token.approve(spender, amount);
        assertTrue(ok);
        assertEq(token.allowance(alice, spender), amount);
    }

    function testTransferFrom() public {
        uint256 amount = 25 ether;
        vm.prank(alice);
        token.approve(spender, amount);
        uint256 aliceBefore = token.balanceOf(alice);
        uint256 bobbefore = token.balanceOf(bob);
        uint256 allowBefore = token.allowance(alice, spender);
        uint256 supplyBefore = token.totalSupply();

        vm.expectEmit(true, true, false, true);
        emit Transfer(alice, bob, amount);

        vm.prank(spender);
        bool ok = token.transferFrom(alice, bob, amount);
        assertTrue(ok);
        assertEq(token.balanceOf(alice), aliceBefore - amount);
        assertEq(token.balanceOf(bob), bobbefore + amount);
        assertEq(token.allowance(alice, spender), allowBefore - amount);
        assertEq(token.totalSupply(), supplyBefore);
    }

    function testTransferFromRevert_NotAllowed() public {
        uint256 amount = 1 ether;
        vm.prank(spender);
        vm.expectRevert(abi.encodeWithSelector(NotAllowed.selector, 0, amount));
        token.transferFrom(alice, bob, amount);
    }

    function testTransferFromRevert_ZeroAddress() public {
        uint256 amount = 1 ether;
        vm.prank(spender);
        vm.expectRevert(ZeroAddress.selector);
        token.transferFrom(alice, address(0), amount);
    }

    function testTransferFromRevert_InsufficientBalance() public {
        uint256 aliceBal = token.balanceOf(alice);
        uint256 amount = aliceBal + 1;
        vm.prank(alice);
        token.approve(spender, amount);
        vm.prank(spender);
        vm.expectRevert(abi.encodeWithSelector(InsufficientBalance.selector, aliceBal, amount));
        token.transferFrom(alice, bob, amount);
    }

    function testTransferRevert_ZeroAddress() public {
        uint256 amount = 1 ether;
        vm.prank(alice);
        vm.expectRevert(ZeroAddress.selector);
        token.transfer(address(0), amount);
    }

    function testTransferRevert_InsufficientBalance() public {
        uint256 aliceBal = token.balanceOf(alice);
        uint256 amount = aliceBal + 1;
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(InsufficientBalance.selector, aliceBal, amount));
        token.transfer(bob, amount);
    }

    function testMint() public {
        uint256 amount = 100 ether;
        uint256 supplyBefore = token.totalSupply();
        uint256 bobBefore = token.balanceOf(bob);
        vm.expectEmit(true, true, false, true);
        emit Transfer(address(0), bob, amount);

        bool ok = token.mint(bob, amount);
        assertTrue(ok);
        assertEq(token.totalSupply(), supplyBefore + amount);
        assertEq(token.balanceOf(bob), bobBefore + amount);
    }

    function testMintRevert_NotOwner() public {
        uint256 amount = 1 ether;
        vm.prank(alice);
        vm.expectRevert(NotOwner.selector);
        token.mint(bob, amount);
    }

    function testMintRevert_ZeroAddress() public {
        uint256 amount = 1 ether;
        vm.expectRevert(ZeroAddress.selector);
        token.mint(address(0), amount);
    }

    function testBurn() public {
        uint256 amount = 100 ether;
        uint256 supplyBefore = token.totalSupply();
        uint256 alicebefore = token.balanceOf(alice);

        vm.expectEmit(true, true, false, true);
        emit Transfer(alice, address(0), amount);

        vm.prank(alice);
        bool ok = token.burn(amount);
        assertTrue(ok);
        assertEq(token.totalSupply(), supplyBefore - amount);
        assertEq(token.balanceOf(alice), alicebefore - amount);
    }

    function testBurnRevert_InsufficientBalance() public {
        uint256 aliceBal = token.balanceOf(alice);
        uint256 amount = aliceBal + 1;

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(InsufficientBalance.selector, aliceBal, amount));
        token.burn(amount);
    }
}
