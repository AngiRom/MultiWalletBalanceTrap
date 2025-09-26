# MultiWalletBalanceTrap
Multi Wallet Balance Trap — Drosera Trap SERGEANT
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}

contract MultiWalletBalanceTrap is ITrap {
    address[] public targets = [
        0xc08642612bcb9910cb444a3a5cd5a5c0630c6e57,
        0x463edff875a45a8d813db574e5cab35282d3defc,
        0xa01d8b6ef23ef2b7c6d99264e480db0fa39a8ad5
    ];

    // 10 bp = 0.01%
    uint256 public constant thresholdPercent = 10;

    /// @notice Збираємо поточні адреси і баланси всіх гаманців
    /// Повертаємо abi.encode(address[], uint256[])
    function collect() external view override returns (bytes memory) {
        uint256[] memory balances = new uint256[](targets.length);
        for (uint256 i = 0; i < targets.length; i++) {
            balances[i] = targets[i].balance;
        }
        return abi.encode(targets, balances);
    }

    /// @notice Очікується, що data[0] = abi.encode(address[], uint256[]) (current)
    ///                         data[1] = abi.encode(address[], uint256[]) (previous)
    /// Функція pure — не читає стан контракту (використовує лише передані дані та константу).
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) return (false, "Insufficient data");

        (address[] memory currentAddrs, uint256[] memory current) = abi.decode(data[0], (address[], uint256[]));
        (address[] memory previousAddrs, uint256[] memory previous) = abi.decode(data[1], (address[], uint256[]));

        if (current.length != previous.length || current.length != currentAddrs.length || previousAddrs.length != previous.length) {
            return (false, "Array length mismatch");
        }

        uint256 maxPercent = 0;
        address maxWallet = address(0);

        for (uint256 i = 0; i < current.length; i++) {
            uint256 cur = current[i];
            uint256 prev = previous[i];
            if (prev == 0) {
                continue; // skip division by zero
            }

            uint256 diff = cur > prev ? cur - prev : prev - cur;
            uint256 percent = (diff * 10000) / prev; // bp

            if (percent > maxPercent) {
                maxPercent = percent;
                maxWallet = currentAddrs[i];
            }
        }

        if (maxPercent >= thresholdPercent) {
            return (true, abi.encodePacked("Max change: ", toAsciiString(maxWallet), " delta ", uint2str(maxPercent), "bp"));
        }

        return (false, "");
    }

    // ===== Help functions (pure) =====
    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        uint160 xx = uint160(x);
        for (uint i = 0; i < 20; i++) {
            uint8 b = uint8(xx >> (8 * (19 - i)));
            uint8 hi = b >> 4;
            uint8 lo = b & 0x0f;
            s[2*i] = _nibbleToChar(hi);
            s[2*i+1] = _nibbleToChar(lo);
        }
        return string(abi.encodePacked("0x", s));
    }

    function _nibbleToChar(uint8 nibble) private pure returns (bytes1) {
        if (nibble < 10) {
            return bytes1(nibble + 0x30); // '0'..'9'
        } else {
            return bytes1(nibble + 0x57); // 'a'..'f'
        }
    }

    function uint2str(uint256 _i) internal pure returns (string memory str) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        uint256 v = _i;
        while (v != 0) {
            k -= 1;
            bstr[k] = bytes1(uint8(48 + (v % 10)));
            v /= 10;
        }
        return string(bstr);
    }
}
