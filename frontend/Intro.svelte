<script>
// @ts-nocheck
  import plugLogo from "./assets/plug.png"
  import { onMount } from "svelte"
  import { nft } from "canisters/nft"
  import ledger_idl from "./utils/ledger.did";
  //import nft_idl from "/.dfx/ic/canisters/nft/nft.did"

  var loading = false;

  let nfts = []
  let principal = ""
  let logged_in = false
  let color1 = "#FF1616";
  let color2 = "#0034B8";
  let buttonMessage = "Mint";
  let resultMessage = "";

  // const list_nfts = async () => {
  //   const res = await nft.list_nfts_owners()
  //   console.log(res)
  //   nfts = res
  //   return nfts
  // }

  const listMyTokens = async (pricipal) => {
    console.log("Getting tokens for principal" + principal)
    const res = await nft.listMyTokens(pricipal)
    console.log(res)
    nfts = res
    return nfts
  }  

  const init_plug = async () => {
    try {
      const connected = await window.ic.plug.isConnected();

      if (!connected)  {
        const publicKey = await window.ic.plug.requestConnect({ 
            //host: 'http://127.0.0.1',
            whitelist: ['rno2w-sqaaa-aaaaa-aaacq-cai','l53cn-iiaaa-aaaah-qcwia-cai'],
            timeout: 50000
        })
        console.log(`The connected user's public key is:`, publicKey);
      } else {

      }
      // Get the user principal id
      const principalId = await window.ic.plug.getPrincipal();

      principal = principalId;
      logged_in = true;

      console.log(`Plug's user principal Id is ${principalId}`);
      //console.log(principal)
      //const result = await window.ic.plug.requestBalance();
      //console.log(result);
    } catch (e) {
      console.log(e);
      alert("Failed to initialize Plug. Are you using Google Chrome?")
    }
    listMyTokens(principal)
    //console.log(list_nfts())
    //balanceOf()
  };

  const plugMint = async () => {
        const backendCanisterId = 'l22ez-fqaaa-aaaah-qcwiq-cai'
        const whitelist = [backendCanisterId];

        // Initialise Agent, expects no return value
        await window?.ic?.plug?.requestConnect({
            whitelist,
        });

        const principalId = await window.ic.plug.agent.getPrincipal();

        // let ledger = getReadActor('yeeiw-3qaaa-aaaah-qcvmq-cai', ledger_idl);
        // let account = getAccountIdentifier(principalId);

        // A partial Interface factory
        // for the NNS Canister UI
        // Check the `plug authentication - nns` for more

        const nftIDL  = ({ IDL }) => {
          const Colors = IDL.Record({ 'color1' : IDL.Text, 'color2' : IDL.Text });
          return IDL.Service({
            'mint' : IDL.Func([IDL.Text, Colors], [IDL.Text], []),
          });
        };

        // Create an actor to interact with the NNS Canister
        // we pass the NNS Canister id and the interface factory
        const tokenFaucetActor = await window.ic.plug.createActor({
            canisterId: backendCanisterId,
            interfaceFactory: nftIDL,
        });

        // We can use any method described in the Candid (IDL)
        // for example the get_stats()
        // See https://github.com/dfinity/nns-dapp/blob/cd755b8/canisters/nns_ui/nns_ui.did
        const minter = await tokenFaucetActor.mint(document.location.host, {color1 : color1, color2 : color2});
        console.log("Plug minter finished.")
        console.log(minter);
        return true;
  }

  const transfer = async () => {
        // NNS Canister Id as an example
        const tokenCanisterId = 'yeeiw-3qaaa-aaaah-qcvmq-cai'
        const whitelist = [tokenCanisterId];

        // Initialise Agent, expects no return value
        await window?.ic?.plug?.requestConnect({
            whitelist,
        });

        const principalId = await window.ic.plug.agent.getPrincipal();

        // let ledger = getReadActor('yeeiw-3qaaa-aaaah-qcvmq-cai', ledger_idl);
        // let account = getAccountIdentifier(principalId);

        // A partial Interface factory
        // for the NNS Canister UI
        // Check the `plug authentication - nns` for more
        const tokenFaucetIDL = ledger_idl;

        // Create an actor to interact with the NNS Canister
        // we pass the NNS Canister id and the interface factory
        const tokenFaucetActor = await window.ic.plug.createActor({
            canisterId: tokenCanisterId,
            interfaceFactory: tokenFaucetIDL,
        });

        // We can use any method described in the Candid (IDL)
        // for example the get_stats()
        // See https://github.com/dfinity/nns-dapp/blob/cd755b8/canisters/nns_ui/nns_ui.did
        const stats = await tokenFaucetActor.send_dfx(
        {
            memo: 0,
            amount: {"e8s": 10000000000},
            fee: {"e8s": 10000},
            from_subaccount: [],
            to: "49a286bee871e2d7e9cfbd4e87d42a94942c68c3498e1ef5cbd7a021afe58382",
            created_at_time: []
        });

        console.log(stats);
        return true;
    }

  const disconnect = async () => {
      console.log("Disconnecting");
      logged_in = false;
      principal = false;
      const result = await window.ic.plug.disconnect();
      console.log(result);
      console.log("Disconnected");
  }

  const mint = async () => {
    loading = true;
    buttonMessage = "Setting and checking payment..."
    let transactionPassed = await transfer();
    if (transactionPassed) {
      console.log("Mint");
      buttonMessage = "Minting your nft.."
      //const result = await nft.mint(document.location.host, {color1 : color1, color2 : color2});
      let mintResult = await plugMint();
      listMyTokens(principal);
      console.log("Mint finished")
      loading = false;
      buttonMessage = "Mint";
      resultMessage = mintResult;
      return mintResult;
    }
  }

  const balanceOf = async () => {
    const result = await nft.balanceOf()
    console.log("Balance" + result)
  }

  onMount(init_plug)
</script>

<header class="App-header">
  <div class="shield">
    <svg width="100%" height="100%" viewBox="0 0 64 64" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xml:space="preserve" xmlns:serif="http://www.serif.com/" style="fill-rule:evenodd;clip-rule:evenodd;stroke-linejoin:round;stroke-miterlimit:2;">
      <path d="M53.75,12.87L32.53,2.87C32.365,2.791 32.183,2.75 32,2.75C31.817,2.75 31.636,2.791 31.47,2.87L10.25,12.87C10.017,12.982 9.823,13.163 9.696,13.388C9.569,13.614 9.515,13.873 9.54,14.13L12.76,44.13C12.79,44.439 12.937,44.725 13.17,44.93L31.17,60.93C31.398,61.135 31.693,61.249 32,61.249C32.307,61.249 32.602,61.135 32.83,60.93L50.83,44.93C51.064,44.725 51.21,44.439 51.24,44.13L54.46,14.13C54.485,13.873 54.431,13.614 54.304,13.388C54.177,13.163 53.983,12.982 53.75,12.87ZM48.81,43.39L32,58.33L15.19,43.39L12.13,14.75L32,5.38L51.87,14.75L48.81,43.39Z" style="fill-rule:nonzero;"/>
      <g transform="matrix(1.07222,0,0,1.07222,-2.31098,-2.26024)">
          <path fill="{color2}" d="M31.47,9.5L16.68,16.5C16.452,16.61 16.264,16.789 16.142,17.011C16.02,17.234 15.971,17.488 16,17.74L18.51,41.19C18.543,41.498 18.689,41.783 18.92,41.99L31.17,52.91C31.401,53.109 31.695,53.219 32,53.219C32.305,53.219 32.599,53.109 32.83,52.91L45.11,42C45.341,41.793 45.487,41.508 45.52,41.2L48,17.74C48.032,17.482 47.98,17.22 47.852,16.993C47.724,16.767 47.527,16.587 47.29,16.48L32.5,9.48C32.337,9.409 32.161,9.373 31.983,9.377C31.805,9.38 31.63,9.422 31.47,9.5Z" style="fill-rule:nonzero;"/>
      </g>
      <g transform="matrix(0.0101186,0,0,0.0101186,18.3236,19.715)">
          <g>
              <path fill="{color1}" d="M72.373,651.52C62.109,212.429 541.276,-95.972 961.842,145.033C1100.39,224.43 1218.01,342.021 1344.47,470.451C1350.22,476.29 1352.88,475.687 1358.26,470.263C1556.07,270.861 1842.48,-33.191 2243.66,85.106C2412.49,134.89 2529.81,244.427 2589.91,409.483C2791.07,961.896 2214.04,1419.25 1719.22,1116.07C1594.42,1039.61 1486.64,934.093 1359.24,804.345C1352.44,797.418 1349.37,798.399 1343.15,804.669C1198.41,950.625 1042.62,1109.28 850.177,1175.69C458.575,1310.85 83.17,1077.49 72.373,651.52ZM317.418,643.008C329.903,896.647 525.008,1014.89 732.886,969.926C912.539,931.069 1063.25,773.066 1191.61,641.115C1195.93,636.669 1193.51,634.864 1190.54,632.09C1079.05,528.024 970.17,400.906 832.954,335.49C567.01,208.705 316.523,394.639 317.418,643.008ZM2385.26,632.288C2377.36,387.164 2183.98,253.585 1961.13,305.855C1785.8,346.981 1635.97,504.236 1511.49,632.134C1507.17,636.571 1508.83,638.643 1512.37,641.945C1668.01,787.19 1851.67,1016.51 2099.81,974.717C2265.1,946.877 2385.63,802.91 2385.26,632.288Z" style="fill-rule:nonzero;"/>
          </g>
      </g>
  </svg>
  </div>
  {#if logged_in}
  <div class="colors">
    <h2>Choose your colors:</h2>

    <div>
        <input type="color" id="head" name="head"
              bind:value="{color1}">
        <label for="head">Symbol color</label>
    </div>

    <div>
        <input type="color" id="body" name="body"
                bind:value="{color2}">
        <label for="body">Shield color</label>
    </div>
    <button on:click={mint} class="mint-button" disabled={loading}>
      {buttonMessage}    
    </button>
    <p>{resultMessage}</p>
    <div class="price">
      <p> Minting price is 100 ICTS 🤑</p>
      <p>Go to <a href="/faucet">faucet</a> to claim some coins.</p>
     </div>
  </div>
  {:else}
    <h2>Log in with plug to mint your SHIELD NFT</h2>
  {/if}
  <!-- <img src={logo} class="App-logo" alt="logo" /> -->
  <div class="plug">
    {#if logged_in}
      <div class="plug-button {logged_in}" on:click="{disconnect}">
        <img class="plug-logo" src="{plugLogo}" alt="Plug logo">
        <span class="plug-text">{#if logged_in}Disconnect{:else}Connect with plug{/if}</span>
      </div>
    {:else}
      <div class="plug-button {logged_in}" on:click="{init_plug}">
        <img class="plug-logo" src="{plugLogo}" alt="Plug logo">
        <span class="plug-text">{#if logged_in}Disconnect{:else}Connect with plug{/if}</span>
      </div>
    {/if}
  </div>
  {#if logged_in}
  <div class="principal">
    <b>Your principal is:</b> {principal}
  </div>
  {/if}
</header>

<body>
  <div class="container">
    {#if logged_in}
    <h1>Minted NFTs</h1>
    {/if}
    {#each nfts as nft }
    <!-- <li>{post[0]} - {post[1].title} <button on:click={() => delete_post(post[0])} class="x">x</button></li> -->
    
    <div class="shield-minted">
      <a href="/nft/{nft[0]}"><p>#{nft[0]}</p></a>
      <svg width="100%" height="100%" viewBox="0 0 64 64" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xml:space="preserve" xmlns:serif="http://www.serif.com/" style="fill-rule:evenodd;clip-rule:evenodd;stroke-linejoin:round;stroke-miterlimit:2;">
        <path d="M53.75,12.87L32.53,2.87C32.365,2.791 32.183,2.75 32,2.75C31.817,2.75 31.636,2.791 31.47,2.87L10.25,12.87C10.017,12.982 9.823,13.163 9.696,13.388C9.569,13.614 9.515,13.873 9.54,14.13L12.76,44.13C12.79,44.439 12.937,44.725 13.17,44.93L31.17,60.93C31.398,61.135 31.693,61.249 32,61.249C32.307,61.249 32.602,61.135 32.83,60.93L50.83,44.93C51.064,44.725 51.21,44.439 51.24,44.13L54.46,14.13C54.485,13.873 54.431,13.614 54.304,13.388C54.177,13.163 53.983,12.982 53.75,12.87ZM48.81,43.39L32,58.33L15.19,43.39L12.13,14.75L32,5.38L51.87,14.75L48.81,43.39Z" style="fill-rule:nonzero;"/>
        <g transform="matrix(1.07222,0,0,1.07222,-2.31098,-2.26024)">
            <path fill="{nft[1].color2}" d="M31.47,9.5L16.68,16.5C16.452,16.61 16.264,16.789 16.142,17.011C16.02,17.234 15.971,17.488 16,17.74L18.51,41.19C18.543,41.498 18.689,41.783 18.92,41.99L31.17,52.91C31.401,53.109 31.695,53.219 32,53.219C32.305,53.219 32.599,53.109 32.83,52.91L45.11,42C45.341,41.793 45.487,41.508 45.52,41.2L48,17.74C48.032,17.482 47.98,17.22 47.852,16.993C47.724,16.767 47.527,16.587 47.29,16.48L32.5,9.48C32.337,9.409 32.161,9.373 31.983,9.377C31.805,9.38 31.63,9.422 31.47,9.5Z" style="fill-rule:nonzero;"/>
        </g>
        <g transform="matrix(0.0101186,0,0,0.0101186,18.3236,19.715)">
            <g>
                <path fill="{nft[1].color1}" d="M72.373,651.52C62.109,212.429 541.276,-95.972 961.842,145.033C1100.39,224.43 1218.01,342.021 1344.47,470.451C1350.22,476.29 1352.88,475.687 1358.26,470.263C1556.07,270.861 1842.48,-33.191 2243.66,85.106C2412.49,134.89 2529.81,244.427 2589.91,409.483C2791.07,961.896 2214.04,1419.25 1719.22,1116.07C1594.42,1039.61 1486.64,934.093 1359.24,804.345C1352.44,797.418 1349.37,798.399 1343.15,804.669C1198.41,950.625 1042.62,1109.28 850.177,1175.69C458.575,1310.85 83.17,1077.49 72.373,651.52ZM317.418,643.008C329.903,896.647 525.008,1014.89 732.886,969.926C912.539,931.069 1063.25,773.066 1191.61,641.115C1195.93,636.669 1193.51,634.864 1190.54,632.09C1079.05,528.024 970.17,400.906 832.954,335.49C567.01,208.705 316.523,394.639 317.418,643.008ZM2385.26,632.288C2377.36,387.164 2183.98,253.585 1961.13,305.855C1785.8,346.981 1635.97,504.236 1511.49,632.134C1507.17,636.571 1508.83,638.643 1512.37,641.945C1668.01,787.19 1851.67,1016.51 2099.81,974.717C2265.1,946.877 2385.63,802.91 2385.26,632.288Z" style="fill-rule:nonzero;"/>
            </g>
        </g>
    </svg>
  </div>
  {/each}
  </div>
</body>

<style global>
    .App-logo {
        height: 15vmin;
        pointer-events: none;
    }


    .App-header {
        margin-top: 150px;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        font-size: calc(10px + 2vmin);
    }

    .App-link {
        color: rgb(26, 117, 255);
    }

    .demo-button {
        background: #a02480;
        padding: 0 1.3em;
        margin-top: 1em;
        border-radius: 60px;
        font-size: 0.7em;
        height: 35px;
        outline: 0;
        border: 0;
        cursor: pointer;
        color: white;
    }

    .demo-button:active {
        color: white;
        background: #979799;
    }


    .plug-button {
      margin: 50px;
      border: 2px rgb(0, 240, 140) solid;
      border-radius: 3%;
      color: black;
      background: white;
      font-weight: bold;
      padding: 0 2em;
      font-size: 1em;
      line-height: 40px;
      height: 100%;
      outline: 0;
      cursor: pointer;
      display: flex;
      align-items: center;
      transition: all 0.4s ease;
    }

    .plug-button:hover {
      border: 2px black solid;
      text-decoration: underline;
    }

    .plug-logo {
      width: 40px;
    }
    .plug-text {
      margin: 15px;
    }

    .true:hover {
      border: 2px red solid;
      text-decoration: none;
    }

    p, label {
        font: 1rem 'Fira Sans', sans-serif;
        font-weight: bold;
    }

    input {
        margin: .4rem;
    }

    svg, path {
      transition: all 1s ease;
    }
    
    .shield-minted {
      width: 220px;
      display: inline-block;

    }

    .principal {
      margin-bottom: 50px;
    }

    .mint-button {
      appearance: none;
      background-color: transparent;
      border: 2px solid #1A1A1A;
      border-radius: 15px;
      box-sizing: border-box;
      color: #3B3B3B;
      cursor: pointer;
      display: inline-block;
      font-family: Roobert,-apple-system,BlinkMacSystemFont,"Segoe UI",Helvetica,Arial,sans-serif,"Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol";
      font-size: 16px;
      font-weight: 600;
      line-height: normal;
      margin: 0;
      min-height: 60px;
      min-width: 0;
      outline: none;
      padding: 16px 24px;
      text-align: center;
      text-decoration: none;
      transition: all 300ms cubic-bezier(.23, 1, 0.32, 1);
      user-select: none;
      -webkit-user-select: none;
      touch-action: manipulation;
      width: 100%;
      max-width: 300px;
      will-change: transform;
      margin-top: 30px;
      margin-bottom: 20px;

    }

    .mint-button:disabled {
      pointer-events: none;
      background-color: #979799;
      cursor: not-allowed;
    }

    .mint-button:hover {
      color: #fff;
      background-color: #1A1A1A;
      box-shadow: rgba(0, 0, 0, 0.25) 0 8px 15px;
      transform: translateY(-2px);
    }

    .mint-button:active {
      box-shadow: none;
      transform: translateY(0);
    }
</style>
