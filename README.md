# Live show pass Dapp
Demo: https://dacade-live-show-pass.vercel.app/



This is a Celo marketplace dapp where users can:
* Purchase live passes with cUSD and pay the owner from the store
* Add your own passes to the dapp

## Live Demo




### Requirements
1. Install the [CeloExtensionWallet](https://chrome.google.com/webstore/detail/celoextensionwallet/kkilomkmpmkbdnfelcpgckmpcaemjcdh?hl=en) from the Google Chrome Store.
2. Create a wallet.
3. Go to [https://celo.org/developers/faucet](https://celo.org/developers/faucet) and get tokens for the alfajores testnet.
4. Switch to the alfajores testnet in the CeloExtensionWallet.

### Test
1. Create a pass.
2. Create a second account in your extension wallet and send them cUSD tokens.
3. Buy pass with secondary account.
4. Check if balance of first account increased.


## Project Setup

### Install
```
npm install
```

### Start
```
npm run dev
```

### Build
```
npm run build
