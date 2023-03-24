// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/RepayOnBehalf.sol";

contract RepayOnBehalfTest is Test {
    RepayOnBehalf repayOnBehalf;
    address owner;
    uint256 existingDebt;
    ICToken cToken;

    function setUp() public {
        owner = address(this);
        existingDebt = 50; // Assume an existing debt of 50
        address comptrollerAddress = address(0); // Replace with the correct comptroller address
        address cTokenAddress = address(0); // Replace with the correct cToken address
        repayOnBehalf = new RepayOnBehalf(comptrollerAddress, cTokenAddress);
        cToken = ICToken(cTokenAddress);
    }

    function getDebt() public returns (uint256) {
        return cToken.borrowBalanceCurrent(owner);
    }

    function testInitialDebt() public {
        assertEq(getDebt(), existingDebt); // Initial debt should match the existing debt
    }

    function testRepayOnBehalf() public {
        uint256 amount = 20;
        repayOnBehalf.repayBorrowOnBehalf(owner, amount);
        assertEq(getDebt(), existingDebt - amount); // Debt should be reduced by the repaid amount
    }

    function testRepayWithFuzzing(uint256 amount) public {
        uint256 initialDebt = getDebt();
        uint256 repayAmount = (initialDebt >= amount) ? amount : initialDebt;
        repayOnBehalf.repayBorrowOnBehalf(owner, repayAmount);
        assertEq(getDebt(), initialDebt - repayAmount); // Debt should decrease by repaid amount
    }
}
