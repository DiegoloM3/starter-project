import { ethers } from "ethers";

async function main() {
    // Generate a random mnemonic
    const mnemonicAccount = ethers.Mnemonic.entropyToPhrase(ethers.randomBytes(16));
    console.log("=== WALLET GENERATED ===");
    console.log("Mnemonic (KEEP THIS SECRET):", mnemonicAccount);
    console.log("-----------------------------------");

    // Standard BIP44 path for Ethereum
    const path0 = "m/44'/60'/0'/0/0";
    const path1 = "m/44'/60'/0'/0/1";

    const deployer = ethers.HDNodeWallet.fromPhrase(mnemonicAccount, undefined, path0);
    const founder = ethers.HDNodeWallet.fromPhrase(mnemonicAccount, undefined, path1);

    console.log("ACCOUNT 0 (Deployer):", deployer.address);
    console.log("Private Key 0:", deployer.privateKey);
    console.log("-----------------------------------");
    console.log("ACCOUNT 1 (Founder):", founder.address);
    console.log("Private Key 1:", founder.privateKey);
    console.log("===================================");
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});
