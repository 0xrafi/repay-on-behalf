// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/RepayOnBehalf.sol";

contract RepayOnBehalfTest {
    RepayOnBehalf repayOnBehalf;
    address owner;
    uint256 existingDebt;

    function setUp() public {
        owner = address(this);
        existingDebt = 50;
        repayOnBehalf = new RepayOnBehalf(owner, existingDebt);
    }

    function testInitialDebt() public {
        assertEq(repayOnBehalf.getDebt(), existingDebt, "Initial debt should match the existing debt");
    }

    function testRepayOnBehalf() public {
        uint256 amount = 20;
        address payer = address(this);
        repayOnBehalf.repay(payer, amount);
        assertEq(repayOnBehalf.getDebt(), existingDebt - amount, "Debt should be reduced by the repaid amount");
    }

    function testRepayWithFuzzing(uint256 amount) public {
        uint256 initialDebt = repayOnBehalf.getDebt();
        uint256 repayAmount = (initialDebt >= amount) ? amount : initialDebt;
        address payer = address(this);
        repayOnBehalf.repay(payer, repayAmount);
        assertEq(repayOnBehalf.getDebt(), initialDebt - repayAmount, "Debt should decrease by repaid amount");
    }
}
