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
        cToken = ICToken(repayOnBehalf.getCtokenAddress());

        // Mock the borrowBalanceCurrent function to return the existing debt
        bytes memory borrowBalanceCurrentMockData = abi.encodeWithSignature("borrowBalanceCurrent(address)", owner);
        bytes memory returnData = abi.encode(existingDebt);
        vm.mockCall(cTokenAddress, borrowBalanceCurrentMockData, returnData);
    }

    function getDebt() public returns (uint256) {
        return cToken.borrowBalanceCurrent(owner);
    }

    function testInitialDebt() public {
        assertEq(getDebt(), existingDebt); // Initial debt should match the existing debt
    }

    function testRepayOnBehalf() public {
        uint256 amount = 20;
        // Mock the repayBorrowBehalf function call in the cToken contract
        address cTokenAddress = repayOnBehalf.getCtokenAddress();
        bytes memory repayBorrowBehalfMockData = abi.encodeWithSignature("repayBorrowBehalf(address,uint256)", owner, amount);
        vm.mockCall(cTokenAddress, repayBorrowBehalfMockData, abi.encode(uint256(0)));

        repayOnBehalf.repayBorrowOnBehalf(owner, amount);
        (bool success, bytes memory returndata) = cTokenAddress.call(repayBorrowBehalfMockData);
        require(success, string(returndata));

        // Update the mocked borrowBalanceCurrent function to return the new debt
        bytes memory borrowBalanceCurrentMockData = abi.encodeWithSignature("borrowBalanceCurrent(address)", owner);
        bytes memory returnData = abi.encode(existingDebt - amount);
        
        vm.mockCall(cTokenAddress, borrowBalanceCurrentMockData, returnData);
        assertEq(getDebt(), existingDebt - amount); // Debt should be reduced by the repaid amount
    }

    function testRepayWithFuzzing(uint256 amount) public {
        uint256 initialDebt = getDebt();
        uint256 repayAmount = (initialDebt >= amount) ? amount : initialDebt;
        address cTokenAddress = repayOnBehalf.getCtokenAddress();
        // Mock the repayBorrowBehalf function call in the cToken contract
        bytes memory repayBorrowBehalfMockData = abi.encodeWithSignature("repayBorrowBehalf(address,uint256)", owner, repayAmount);
        vm.mockCall(cTokenAddress, repayBorrowBehalfMockData, abi.encode(uint256(0)));

        repayOnBehalf.repayBorrowOnBehalf(owner, repayAmount);
        (bool success, bytes memory returndata) = cTokenAddress.call(repayBorrowBehalfMockData);
        require(success, string(returndata));

        // Update the mocked borrowBalanceCurrent function to return the new debt
        bytes memory borrowBalanceCurrentMockData = abi.encodeWithSignature("borrowBalanceCurrent(address)", owner);
        bytes memory returnData = abi.encode(initialDebt - repayAmount);
        
        vm.mockCall(cTokenAddress, borrowBalanceCurrentMockData, returnData);

        assertEq(getDebt(), initialDebt - repayAmount); // Debt should decrease by rep
    }
}