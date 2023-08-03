// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Test, console2, StdStyle} from "forge-std/Test.sol";
import {ERC20} from "../contracts/ERC20.sol";

contract BaseSetup is ERC20, Test {
    address internal alice;
    address internal bob;
    address internal chris;

    constructor() ERC20("name", "SYM", 18) {}

    function setUp() public virtual {
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        chris = makeAddr("chris");

        deal(address(this), alice, 300e18);
        console2.log(StdStyle.yellow("Mint 300 token to alice."));
    }
}

contract ERC20TransferTest is BaseSetup {
    function testTransferTokenCorrect() public {
        assertEqDecimal(this.balanceOf(alice), 300e18, decimals);
        assertEqDecimal(this.balanceOf(bob), 0, decimals);

        vm.prank(alice);
        bool success = this.transfer(bob, 100e18);

        assertTrue(success);
        assertEqDecimal(this.balanceOf(alice), 200e18, decimals);
        assertEqDecimal(this.balanceOf(bob), 100e18, decimals);
    }

    function testCannotTransferMoreThanBalance() public {
        assertEqDecimal(this.balanceOf(alice), 300e18, decimals);
        assertEqDecimal(this.balanceOf(bob), 0, decimals);

        vm.prank(alice);
        vm.expectRevert("ERC20: Insufficient sender balance.");
        this.transfer(bob, 700e18);

        assertEqDecimal(this.balanceOf(alice), 300e18, decimals);
        assertEqDecimal(this.balanceOf(bob), 0, decimals);
    }

    function testEvmitTransferEvent() public {
        vm.expectEmit(true, true, true, true);
        emit Transfer(alice, bob, 100e18);

        vm.prank(alice);
        this.transfer(bob, 100e18);
    }
}

contract ERC20TransferFromTest is BaseSetup {
    function testTransferFromCorrect() public {
        assertEqDecimal(this.balanceOf(alice), 300e18, decimals);
        assertEqDecimal(this.balanceOf(bob), 0, decimals);
        assertEqDecimal(this.balanceOf(chris), 0, decimals);

        vm.prank(alice);
        bool approve_success = this.approve(bob, 200e18);

        assertTrue(approve_success);
        assertEqDecimal(this.balanceOf(alice), 300e18, decimals);
        assertEqDecimal(this.balanceOf(bob), 0, decimals);
        assertEqDecimal(this.balanceOf(chris), 0, decimals);
        assertEqDecimal(this.allowance(alice, bob), 200e18, decimals);

        vm.prank(bob);
        bool transfer_success = this.transferFrom(alice, chris, 100e18);

        assertTrue(transfer_success);
        assertEqDecimal(this.balanceOf(alice), 200e18, decimals);
        assertEqDecimal(this.balanceOf(bob), 0, decimals);
        assertEqDecimal(this.balanceOf(chris), 100e18, decimals);
        assertEqDecimal(this.allowance(alice, bob), 100e18, decimals);
    }

    function testCannotTransferFromMoreThanAllowance() public {
        assertEqDecimal(this.balanceOf(alice), 300e18, decimals);
        assertEqDecimal(this.balanceOf(bob), 0, decimals);
        assertEqDecimal(this.balanceOf(chris), 0, decimals);

        vm.prank(alice);
        bool approve_success = this.approve(bob, 200e18);

        assertTrue(approve_success);
        assertEqDecimal(this.balanceOf(alice), 300e18, decimals);
        assertEqDecimal(this.balanceOf(bob), 0, decimals);
        assertEqDecimal(this.balanceOf(chris), 0, decimals);
        assertEqDecimal(this.allowance(alice, bob), 200e18, decimals);

        vm.prank(bob);
        vm.expectRevert("ERC20: Insufficient allowance.");
        this.transferFrom(alice, chris, 300e18);

        assertEqDecimal(this.balanceOf(alice), 300e18, decimals);
        assertEqDecimal(this.balanceOf(bob), 0, decimals);
        assertEqDecimal(this.balanceOf(chris), 0, decimals);
        assertEqDecimal(this.allowance(alice, bob), 200e18, decimals);
    }

    function testCannotTransferFromMoreThanBalance() public {
        assertEqDecimal(this.balanceOf(alice), 300e18, decimals);
        assertEqDecimal(this.balanceOf(bob), 0, decimals);
        assertEqDecimal(this.balanceOf(chris), 0, decimals);

        vm.prank(alice);
        bool approve_success = this.approve(bob, 400e18);

        assertTrue(approve_success);
        assertEqDecimal(this.balanceOf(alice), 300e18, decimals);
        assertEqDecimal(this.balanceOf(bob), 0, decimals);
        assertEqDecimal(this.balanceOf(chris), 0, decimals);
        assertEqDecimal(this.allowance(alice, bob), 400e18, decimals);

        vm.prank(bob);
        vm.expectRevert("ERC20: Insufficient sender balance.");
        this.transferFrom(alice, chris, 400e18);

        assertEqDecimal(this.balanceOf(alice), 300e18, decimals);
        assertEqDecimal(this.balanceOf(bob), 0, decimals);
        assertEqDecimal(this.balanceOf(chris), 0, decimals);
        assertEqDecimal(this.allowance(alice, bob), 400e18, decimals);
    }
}
