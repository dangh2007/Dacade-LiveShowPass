# Live show pass Dapp


## Description
This is a Celo bookshop marketplace dapp where users can:
* Explore books available on the site
* Purchase books with cUSD and pay the owner from the store
* Add your own books to the dapp

## Live Screenshot
![Screenshot from 2022-01-12 15-08-11](https://user-images.githubusercontent.com/81568615/149138236-20e03e97-3736-491a-b1d6-225e69f2030c.png)
![Screenshot from 2022-01-14 04-05-02](https://user-images.githubusercontent.com/81568615/149434558-8823a793-dc7e-4837-a68e-f8aab11ad9ff.png)
![Screenshot from 2021-12-24 20-09-40](https://user-images.githubusercontent.com/81568615/147366440-ee633552-5cb3-42be-9e21-ecc2f84869c7.png)
![Screenshot from 2021-12-24 19-19-53](https://user-images.githubusercontent.com/81568615/147366443-2cc3fa01-a90c-42a1-a798-d0ae9c2df624.png)





### Requirements
1. Install the [CeloExtensionWallet](https://chrome.google.com/webstore/detail/celoextensionwallet/kkilomkmpmkbdnfelcpgckmpcaemjcdh?hl=en) from the Google Chrome Store.
2. Create a wallet.
3. Go to [https://celo.org/developers/faucet](https://celo.org/developers/faucet) and get tokens for the alfajores testnet.
4. Switch to the alfajores testnet in the CeloExtensionWallet.

### Test
1. Create a product.
2. Create a second account in your extension wallet and send them cUSD tokens.
3. Buy product with secondary account.
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