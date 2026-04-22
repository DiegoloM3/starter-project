// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./SymmetryToken.sol";

/**
 * @title RewardsVault
 * @dev Contrato para la reclamación eficiente de recompensas (sistema Claim).
 * Los usuarios presentan un "ticket" firmado por el backend de Symmetry.
 */
contract RewardsVault is EIP712, Ownable {
    using ECDSA for bytes32;

    SymmetryToken public immutable token;
    address public signerAddress;

    mapping(address => uint256) public nonces;
    mapping(bytes32 => bool) public usedHashes;

    event RewardClaimed(address indexed user, uint256 amount);

    constructor(address _token, address _initialSigner) 
        EIP712("SymmetryRewards", "1")
        Ownable(msg.sender)
    {
        token = SymmetryToken(_token);
        signerAddress = _initialSigner;
    }

    /**
     * @dev Actualiza la dirección del firmante autorizado (backend).
     */
    function setSigner(address _newSigner) external onlyOwner {
        signerAddress = _newSigner;
    }

    /**
     * @dev Permite a los usuarios reclamar tokens mediante una firma del backend.
     * @param amount Cantidad de tokens a reclamar.
     * @param nonce Nonce para evitar replay attacks.
     * @param signature Firma ECDSA generada por el backend.
     */
    function claim(uint256 amount, uint256 nonce, bytes calldata signature) external {
        require(nonce == nonces[msg.sender], "RewardsVault: Invalid nonce");
        
        bytes32 structHash = _hashTypedDataV4(keccak256(abi.encode(
            keccak256("Claim(address user,uint256 amount,uint256 nonce)"),
            msg.sender,
            amount,
            nonce
        )));

        address recoveredSigner = structHash.recover(signature);
        require(recoveredSigner == signerAddress, "RewardsVault: Invalid signature");

        nonces[msg.sender]++;
        token.mint(msg.sender, amount); // Requiere que este contrato tenga MINTER_ROLE en el token

        emit RewardClaimed(msg.sender, amount);
    }
}
