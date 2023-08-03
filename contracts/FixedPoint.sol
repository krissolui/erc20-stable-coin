// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.21;

type FixedPoint is uint256;

using {add as +, sub as -, mul as *, div as /} for FixedPoint global;

uint256 constant DECIMALS = 18;

function add(FixedPoint a, FixedPoint b) pure returns (FixedPoint) {
    return FixedPoint.wrap(FixedPoint.unwrap(a) + FixedPoint.unwrap(b));
}

function sub(FixedPoint a, FixedPoint b) pure returns (FixedPoint) {
    return FixedPoint.wrap(FixedPoint.unwrap(a) - FixedPoint.unwrap(b));
}

function mul(FixedPoint a, FixedPoint b) pure returns (FixedPoint) {
    return FixedPoint.wrap(FixedPoint.unwrap(a) * FixedPoint.unwrap(b) / DECIMALS);
}

function div(FixedPoint a, FixedPoint b) pure returns (FixedPoint) {
    return FixedPoint.wrap(FixedPoint.unwrap(a) * DECIMALS / FixedPoint.unwrap(b));
}

function fromFraction(uint256 numerator, uint256 denominator) pure returns (FixedPoint) {
    return FixedPoint.wrap(numerator * DECIMALS / denominator);
}

function mulFixedPoint(uint256 a, FixedPoint b) pure returns (uint256) {
    return a * FixedPoint.unwrap(b) / DECIMALS;
}

function divFixedPoint(uint256 a, FixedPoint b) pure returns (uint256) {
    return a * DECIMALS / FixedPoint.unwrap(b);
}

// contract FixedPointTest {
//     function testAddition(
//         FixedPoint a,
//         FixedPoint b
//     ) external pure returns (FixedPoint) {
//         return a + b;
//     }
    
//     function testSubtraction(
//         FixedPoint a,
//         FixedPoint b
//     ) external pure returns (FixedPoint) {
//         return a - b;
//     }
    
//     function testMultiplication(
//         FixedPoint a,
//         FixedPoint b
//     ) external pure returns (FixedPoint) {
//         return a * b;
//     }
    
//     function testDivision(
//         FixedPoint a,
//         FixedPoint b
//     ) external pure returns (FixedPoint) {
//         return a / b;
//     }
// }
