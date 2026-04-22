// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

/**
 * @title SymmetryToken (SYM)
 * @dev Token core de Symmetry con gobernanza on-chain y sistema de permisos.
 */
contract SymmetryToken is ERC20, ERC20Burnable, AccessControl, ERC20Permit, ERC20Votes {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant GOVERNANCE_ROLE = keccak256("GOVERNANCE_ROLE");

    uint256 public constant MAX_SUPPLY = 110_000_000 * 10**18;

    constructor(address defaultAdmin, address initialMinter)
        ERC20("Symmetry Token", "SYM")
        ERC20Permit("Symmetry Token")
    {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, initialMinter);
        _grantRole(GOVERNANCE_ROLE, defaultAdmin);

        // Premine inicial de 5M (Líquidos para el pool inicial)
        // El resto se delegará a los contratos de vesting y vault.
        _mint(defaultAdmin, 5_000_000 * 10**18);
    }

    /**
     * @dev Función de minteo controlada para el motor de recompensas.
     * Respeta el MAX_SUPPLY definido.
     */
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        require(totalSupply() + amount <= MAX_SUPPLY, "SymmetryToken: Cap exceeded");
        _mint(to, amount);
    }

    // Overrides requeridos por Solidity para ERC20Votes
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Votes)
    {
        super._update(from, to, value);
    }

    function nonces(address owner)
        public
        view
        override(ERC20Permit, Nonces)
        returns (uint256)
    {
        return super.nonces(owner);
    }
}
