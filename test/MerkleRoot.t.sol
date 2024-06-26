// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Test, console} from "forge-std/Test.sol";
import {Whitelist} from "../src/Whitelist.sol";
import {Merkle} from "murky/src/Merkle.sol";

contract CounterTest is Test {
    Whitelist public whitelist;

    function encodeLeaf(
        address _address,
        uint64 _spots
    ) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(_address, _spots));
    }

    function test_MerkleRoot() public {
        Merkle m = new Merkle();
        
        bytes32[] memory list = new bytes32[](6);
        list[0] = encodeLeaf(vm.addr(1), 2);
        list[1] = encodeLeaf(vm.addr(2), 2);
        list[2] = encodeLeaf(vm.addr(3), 2);
        list[3] = encodeLeaf(vm.addr(4), 2);
        list[4] = encodeLeaf(vm.addr(5), 2);
        list[5] = encodeLeaf(vm.addr(6), 2);
        
        bytes32 root = m.getRoot(list);

        whitelist = new Whitelist(root);

        for (uint8 i = 0; i<6; i++) {
            bytes32[] memory proof = m.getProof(list, i);

            vm.prank(vm.addr(i+1));
            
            bool verified = whitelist.checkInWhitelist(proof, 2);
            assertEq(verified, true);
        }

        bytes32[] memory invalidProof;

        bool verifiedInvalid = whitelist.checkInWhitelist(invalidProof, 2);
        assertEq(verifiedInvalid, false);

    }


}