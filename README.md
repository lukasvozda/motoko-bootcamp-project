## DFINI∞SHIELDS motoko-bootcamp 2022 project
![Image](https://github.com/lukasvozda/motoko-bootcamp-project/blob/main/frontend/assets/shields.png?raw=true)

See the live version here: https://l53cn-iiaaa-aaaah-qcwia-cai.ic0.app

DFINI∞SHIELDS is a project developed during the event of the Motoko Bootcamp 2022 run by Dfinity Community.

You can use the token faucet to get free tokens and mint your unique NFT. **Yeach color can be used only once so nobody can have the same NFT really.**

The whole work was done under quite a time pressure as I am working full time and was working on this in the evening, so please be respectfull if you see some bugs or very lame coding :D

I use Token Faucet to claim tokens on the front end. Transaction is simply verified (if the balance increased) on the backend.

Author of the project: Lukas Vozda, Twitter: [@luke_rocks_icp](https://twitter.com/luke_rocks_icp) 

Check my other project, the [Internet Computer NFT reporting dashboard.](https://datastudio.google.com/reporting/d2b91d4e-5a3f-4652-b2de-7161010c9113/page/BcHmC) 


On local run with:
```bash
dfx start
dfx deploy

npm install
npm run dev
```

Some things especially plug, principalIDs and payment verifications works best on the mainnet.
