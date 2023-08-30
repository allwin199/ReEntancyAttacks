// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {EtherStore, Attack} from "../src/ReEntrancyGuard.sol";

contract ReEntrancyTest is Test {
    EtherStore etherStore;
    Attack attack;

    address private user = makeAddr("user");
    address private attacker = makeAddr("attacker");
    uint256 private constant STARTING_USER_BALANCE = 10 ether;

    function setUp() public {
        etherStore = new EtherStore();
        attack = new Attack(address(etherStore));

        vm.deal(user, STARTING_USER_BALANCE);
        vm.deal(attacker, STARTING_USER_BALANCE);
    }

    modifier depositedEther() {
        vm.startPrank(user);
        etherStore.deposit{value: 5 ether}();
        vm.stopPrank();
        _;
    }

    function test_BalanceOf_EtherStore() public depositedEther {
        uint256 etherStoreBalalnce = address(etherStore).balance;
        uint256 attackBalance = address(attack).balance;
        console2.log("EtherStore", etherStoreBalalnce);
        console2.log("Attack", attackBalance);
    }

    function test_Attack_EtherStore_ReEntrancyGuard() public depositedEther {
        vm.startPrank(attacker);
        vm.expectRevert();
        attack.attack{value: 1 ether}();
        vm.stopPrank();

        vm.startPrank(address(attack));
        (bool success,) = address(attacker).call{value: address(attack).balance}("");
        uint256 attackerbalance = address(attacker).balance;
        console2.log("attackerbalance", attackerbalance);
        vm.stopPrank();

        uint256 etherStoreBalalnce = address(etherStore).balance;
        uint256 attackBalance = address(attack).balance;

        console2.log("EtherStore", etherStoreBalalnce);
        console2.log("Attack", attackBalance);
    }
}
