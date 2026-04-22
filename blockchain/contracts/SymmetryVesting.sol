// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SymmetryVesting
 * @dev Contrato para el bloqueo y liberación lineal de tokens (Team/Advisors).
 */
contract SymmetryVesting is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;
    address public immutable beneficiary;
    
    uint256 public immutable start;
    uint256 public immutable duration;
    uint256 public immutable cliff;
    
    uint256 public released;

    constructor(
        address _token,
        address _beneficiary,
        uint256 _durationSeconds,
        uint256 _cliffSeconds
    ) Ownable(msg.sender) {
        token = IERC20(_token);
        beneficiary = _beneficiary;
        duration = _durationSeconds;
        cliff = block.timestamp + _cliffSeconds;
        start = block.timestamp;
    }

    /**
     * @dev Calcula la cantidad de tokens liberables en el momento actual.
     */
    function vestedAmount() public view returns (uint256) {
        if (block.timestamp < cliff) {
            return 0;
        } else if (block.timestamp >= start + duration) {
            return token.balanceOf(address(this)) + released;
        } else {
            uint256 totalBalance = token.balanceOf(address(this)) + released;
            return (totalBalance * (block.timestamp - start)) / duration;
        }
    }

    /**
     * @dev Transfiere los tokens liberados al beneficiario.
     */
    function release() external {
        uint256 unreleased = vestedAmount() - released;
        require(unreleased > 0, "SymmetryVesting: No tokens to release");

        released += unreleased;
        token.safeTransfer(beneficiary, unreleased);
    }
}
