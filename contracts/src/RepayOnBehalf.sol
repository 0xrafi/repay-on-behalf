// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.16;

import "openzeppelin/token/ERC20/IERC20.sol";

interface IComptroller {
    function enterMarkets(address[] calldata cTokens) external returns (uint[] memory);
}

interface ICToken {
    function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint);
    function borrowBalanceCurrent(address account) external returns (uint);
}

interface CErc20Interface is ICToken {
    function underlying() external view returns (address);
}

contract RepayOnBehalf {
    address public comptrollerAddress;
    address public cTokenAddress;

    constructor(address _comptrollerAddress, address _cTokenAddress) {
        comptrollerAddress = _comptrollerAddress;
        cTokenAddress = _cTokenAddress;
    }

    function enterCompoundMarket() external {
        IComptroller comptroller = IComptroller(comptrollerAddress);
        address[] memory cTokens = new address[](1);
        cTokens[0] = cTokenAddress;
        comptroller.enterMarkets(cTokens);
    }

    function repayBorrowOnBehalf(address borrower, uint256 repayAmount) external {
        CErc20Interface cToken = CErc20Interface(cTokenAddress);
        IERC20 underlyingToken = IERC20(cToken.underlying());

        underlyingToken.transferFrom(msg.sender, address(this), repayAmount);
        underlyingToken.approve(cTokenAddress, repayAmount);

        uint result = cToken.repayBorrowBehalf(borrower, repayAmount);
        require(result == 0, "Repay failed");
    }
}
