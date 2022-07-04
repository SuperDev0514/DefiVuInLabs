# DeFiVulnLabs
This was an internal Web3 solidity security training in [XREX](https://xrex.io/). I want to share these materials with everyone interested in Web3 security and how to find vulnerabilities in code and exploit them. Every vulnerability testing uses Foundry. Faster and easier!

A collection of vulnerable code snippets taken from [Solidity by Example](https://solidity-by-example.org/), [SWC Registry](https://swcregistry.io/) and [Blockchain CTF](https://github.com/blockthreat/blocksec-ctfs), etc.  
##### Education only! Please do not use it in production.

## Getting Started

* Follow the [instructions](https://book.getfoundry.sh/getting-started/installation.html) to install [Foundry](https://github.com/foundry-rs/foundry).
* Clone and run:  ```forge install openzeppelin/openzeppelin-contracts ```
* Test vulnerability: ```forge test --contracts ./src/test/Reentrancy.sol -vvvv``` 

## List of vulnerabilities
* [Integer Overflow 1](src/test/Overflow.sol) | [Integer Overflow 2](src/test/Overflow2.sol) : 
  * In previous versions of Solidity (prior Solidity 0.8.x) an integer would automatically roll-over to a lower or higher number.
  * Without SafeMath (prior Solidity 0.8.x)
* [Selfdestruct 1](src/test/Selfdestruct.sol) | [Selfdestruct 2](src/test/Selfdestruct2.sol) : 
  * Due to missing or insufficient access controls, malicious parties can self-destruct the contract.
  * The selfdestruct(address) function removes all bytecode from the contract address and sends all ether stored to the specified address.
* [Unsafe Delegatecall](src/test/Delegatecall.sol): 
  * This allows a smart contract to dynamically load code from a different address at runtime.
* [Reentrancy](src/test/Reentrancy.sol): 
  * One of the major dangers of calling external contracts is that they can take over the control flow. 
  * Not following [checks-effects-interactions](https://fravoll.github.io/solidity-patterns/checks_effects_interactions.html) pattern and no ReentrancyGuard. 
* [Unsafe low level call - call injection](src/test/UnsafeCall.sol) : 
  * Use of low level "call" should be avoided whenever possible. It can lead to unexpected behavior if return value is not handled properly. 
* [Privatedata](src/test/Privatedata.sol): 
  * Private data ≠ Secure. It's readable from slots of the contract.
  * it's important that unencrypted private data is not stored in the contract code or state.
* [Unprotected callback - NFT over mint](src/test/Unprotected-callback.sol) : 
  * _safeMint is secure? Attacker can reenter the mint function inside the onERC721Received callback.
* [Backdoor assembly](src/test/Backdoor-assembly.sol): 
  * Malicious attacker can inject inline assembly to manipulate conditions. Change implementation contract or sensitive parameters.
* [Bypass iscontract](src/test/Bypasscontract.sol) : 
  * During contract creation when the constructor is executed there is no code yet so the code size will be 0.
* [DOS](src/test/DOS.sol) : 
  * External calls can fail accidentally or deliberately, which can cause a DoS condition in the contract. (DoS with unexpected revert)
* [Randomness](src/test/Randomness.sol) : 
  * Use of global variables like block hash, block number, block timestamp and other fields is insecure, miner and attacker can control it.
* [Visibility](src/test/Visibility.sol) : 
  * Insecure visibility settings give attackers straightforward ways to access a contract's private values or logic.
* [txorigin - phishing](src/test/txorigin.sol) : 
  * tx.origin is a global variable in Solidity which returns the address of the account that sent the transaction. Using the variable for authorization could make a contract vulnerable if an authorized account calls into a malicious contract. 
* [Approve - Scam](src/test/ApproveScam.sol) : 
  * Too many scams abusing approve or setApprovalForAll to drain your tokens.

## Link reference

* [Mastering Ethereum - Smart Contract Security](https://github.com/ethereumbook/ethereumbook/blob/develop/09smart-contracts-security.asciidoc)
 
* [Ethereum Smart Contract Best Practices](https://consensys.github.io/smart-contract-best-practices/attacks/)

* [Awesome-Smart-Contract-Security](https://github.com/saeidshirazi/Awesome-Smart-Contract-Security)

* [(Not So) Smart Contracts](https://github.com/crytic/not-so-smart-contracts)

* [Smart Contract Attack Vectors](https://github.com/kadenzipfel/smart-contract-attack-vectors)

* [Secureum Security Pitfalls 101](https://secureum.substack.com/p/security-pitfalls-and-best-practices-101?s=r)

* [Secureum Security Pitfalls 201](https://secureum.substack.com/p/security-pitfalls-and-best-practices-201?s=r)
* [How to Secure Your Smart Contracts: 6 Solidity Vulnerabilities and how to avoid them (Part 1)](https://medium.com/loom-network/how-to-secure-your-smart-contracts-6-solidity-vulnerabilities-and-how-to-avoid-them-part-1-c33048d4d17d)[(Part 2)](https://medium.com/loom-network/how-to-secure-your-smart-contracts-6-solidity-vulnerabilities-and-how-to-avoid-them-part-2-730db0aa4834)
 

