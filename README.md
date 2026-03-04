# ERC20 From Scratch

A protocol-level implementation of an ERC20 token built **without OpenZeppelin**, designed to understand how token state machines work internally.

The project focuses on **correct state transitions, testing discipline, and gas-aware Solidity design**.

---

# Overview

This repository contains a **minimal but production-grade ERC20 implementation** with:

- full ERC20 interface
- custom errors
- mint / burn functionality
- allowance management
- gas optimizations
- invariant testing
- fuzz testing

The goal of the project is to **build a token from first principles** instead of relying on abstractions.

---

# ERC20 Standard

The token implements the required interface defined in the official ERC-20 specification:

https://eips.ethereum.org/EIPS/eip-20

Required functions:


totalSupply()
balanceOf(address)
transfer(address,uint256)
approve(address,uint256)
transferFrom(address,address,uint256)
allowance(address,address)


Required events:


Transfer(address,address,uint256)
Approval(address,address,uint256)


Because these signatures match the ERC20 interface, the token is compatible with wallets and protocols such as:

- MetaMask
- Uniswap
- Etherscan

---

# Architecture

The token behaves as a **state machine**.

Core state variables:


balanceOf[address]
totalSupply
allowance[owner][spender]


Each function represents a valid **state transition**.


transfer -> move tokens between accounts
approve -> grant spending permission
transferFrom -> delegated transfer
mint -> increase supply
burn -> decrease supply


Invariant enforced by tests:


sum(balanceOf) == totalSupply


This invariant ensures that token accounting always remains correct.

---

# Security Design

The contract includes several safety mechanisms.

## Custom Errors

Custom errors replace `require` strings to reduce gas costs and provide structured revert data.

Examples:

```solidity
error InsufficientBalance(uint256 available, uint256 required);
error NotAllowed(uint256 allowed, uint256 requested);
error ZeroAddress();
error NotOwner();
Access Control

Minting is restricted using:

onlyOwner

This prevents arbitrary inflation of the token supply.

Zero Address Protection

The contract rejects invalid interactions involving the zero address.

Examples:

transfer(address(0))
transferFrom(..., address(0))
mint(address(0))
approve(address(0))

This keeps behavior consistent and avoids ambiguous edge cases.

Gas Optimizations

Several optimizations were applied to reduce transaction costs.

Gas Report

Measured with forge test --gas-report.

Values vary depending on storage state. The table uses median gas from Foundry results.

Operation	Median Gas
transfer	34,866
transferFrom	40,778
approve	29,729
increaseAllowance	29,984
decreaseAllowance	30,115
mint	36,918
burn	34,123
Deployment

Deployment Cost: 1,403,808
Deployment Size: 8,169 bytes

unchecked arithmetic
unchecked {
    balanceOf[from] = fromBal - amount;
}

Used only when safety is guaranteed by preconditions.

Cached storage reads
uint256 fromBal = balanceOf[from];

Avoids repeated expensive SLOAD operations.

Infinite Allowance (OpenZeppelin behavior)
if (allowed != type(uint256).max) {
    allowance[from][spender] -= amount;
}

This prevents unnecessary storage writes when users grant maximum approval.

Testing

Testing is implemented using Foundry.

Three testing strategies are used.

Unit Tests

Verify expected behavior of each state transition.

Covered cases include:

transfer

approve

transferFrom

mint

burn

allowance updates

revert conditions

Fuzz Testing

Randomized inputs test contract behavior across many possible states.

This helps detect unexpected edge cases.

Invariant Testing

The core accounting rule must always hold:

sum(balanceOf) == totalSupply

Example invariant output:

runs: 256
calls: 128000

This confirms the token remains consistent across thousands of state transitions.

Project Structure
src/
  MyToken.sol

test/
  ERC20.t.sol
  invariants/
    ERC20.invariant.t.sol
Tooling

Development stack:

Solidity 0.8.20

Foundry

Common commands:

forge build
forge test
forge fmt
forge clean
Learning Goals

This project demonstrates how to:

implement ERC20 from first principles

design safe state transitions

write protocol-level tests

apply invariant testing

perform gas optimizations

understand the ERC20 standard deeply

License

MIT