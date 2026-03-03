// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/MyToken.sol";

contract Handler is Test {
    MyToken public token;
    address[] public users;

    constructor(MyToken _token, address[] memory _users) {
        token = _token;
        users = _users;
    }

    function transfer(uint256 fromSeed, uint256 toSeed, uint256 amount) external {
        address from = users[fromSeed % users.length];
        address to = users[toSeed % users.length];
        if (to == address(0)) return;
        uint256 bal = token.balanceOf(from);
        if (bal == 0) return;
        amount = amount % (bal + 1);
        vm.prank(from);
        token.transfer(to, amount);
    }

    function approve(uint256 ownerSeed, uint256 spenderSeed, uint256 amount) external {
        address owner = users[ownerSeed % users.length];
        address spender = users[spenderSeed % users.length];
        vm.prank(owner);
        token.approve(spender, amount);
    }

    function increaseAllowance(uint256 ownerSeed, uint256 spenderSeed, uint256 addedValue) external {
        address owner = users[ownerSeed % users.length];
        address spender = users[spenderSeed % users.length];
        vm.prank(owner);
        addedValue = addedValue % 1_000 ether;
        token.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(uint256 ownerSeed, uint256 spenderSeed, uint256 subtractedValue) external {
        address owner = users[ownerSeed % users.length];
        address spender = users[spenderSeed % users.length];
        uint256 current = token.allowance(owner, spender);
        if (current == 0) return;
        subtractedValue = subtractedValue % (current + 1);
        vm.prank(owner);
        token.decreaseAllowance(spender, subtractedValue);
    }

    function transferFrom(uint256 spenderSeed, uint256 fromSeed, uint256 toSeed, uint256 amount) external {
        address spender = users[spenderSeed % users.length];
        address from = users[fromSeed % users.length];
        address to = users[toSeed % users.length];
        if (to == address(0)) return;
        if (from == address(0)) return;
        uint256 bal = token.balanceOf(from);
        if (bal == 0) return;
        uint256 allowed = token.allowance(from, spender);
        if (allowed == 0) return;
        uint256 max = bal < allowed ? bal : allowed;
        amount = amount % (max + 1);
        vm.prank(spender);
        token.transferFrom(from, to, amount);
    }

    function burn(uint256 whoSeed, uint256 amount) external {
        address who = users[whoSeed % users.length];
        if (who == address(0)) return;
        uint256 bal = token.balanceOf(who);
        if (bal == 0) return;
        amount = amount % (bal + 1);
        vm.prank(who);
        token.burn(amount);
    }

    function mint(uint256 toSeed, uint256 amount) external {
        address to = users[toSeed % users.length];
        if (to == address(0)) return;
        amount = amount % 1_000 ether;
        vm.prank(token.owner());
        token.mint(to, amount);
    }
}

contract ERC20InvariantTest is Test {
    MyToken token;
    address[] users;
    Handler handler;

    function setUp() public {
        token = new MyToken("MyToken", "MTK", 18);
        users = new address[](5);
        users[0] = makeAddr("alice");
        users[1] = makeAddr("bob");
        users[2] = makeAddr("spender");
        users[3] = makeAddr("carol");
        users[4] = address(this);

        token.transfer(users[0], 1_000 ether);
        token.transfer(users[1], 2_000 ether);
        token.transfer(users[2], 3_000 ether);

        handler = new Handler(token, users);
        targetContract(address(handler));
    }

    function invariant_sumBalancesEqualsTotalSupply() public view {
        uint256 sum;
        for (uint256 i = 0; i < users.length; i++) {
            sum += token.balanceOf(users[i]);
        }
        assertEq(sum, token.totalSupply());
    }
}
