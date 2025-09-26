// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LogAlertReceiver {
    event BalanceAnomalyDetected(address indexed wallet, string message, uint256 basisPointsChange, uint256 timestamp);

    function logAnomaly(address wallet, string calldata message, uint256 basisPointsChange) external {
        emit BalanceAnomalyDetected(wallet, message, basisPointsChange, block.timestamp);
    }
}
