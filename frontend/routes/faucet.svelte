<script>
// @ts-nocheck

    //import { Principal } from "@dfinity/principal";
    import { Actor, HttpAgent } from "@dfinity/agent";
    import { getAccountIdentifier } from "../utils/utils";
    import ledger_idl from "../utils/ledger.did";
    import { onMount } from "svelte"


    const ic_agent = new HttpAgent({ host: "https://boundary.ic0.app/" });
    let readActorCache = {}

    let tokens = 0;
    var loading = false;


    function getReadActor(cid, idl) {
        if (cid in readActorCache)
            return readActorCache[cid]

        const actor = Actor.createActor(idl, {
            agent: ic_agent,
            canisterId: cid,
        });

        readActorCache[cid] = actor;

        return actor;
    }

    const claim = async () => {
        console.log("Claim")
        loading = true

        //const publicKey = await window.ic.plug.requestConnect();

        const principalId = await window.ic.plug.getPrincipal();
        try {
            let ledger = getReadActor('yeeiw-3qaaa-aaaah-qcvmq-cai', ledger_idl)
            let account = getAccountIdentifier(principalId);
            
            let faucet_result = await ledger.faucet({to: account, created_at_time: []});
            console.log("claimed")
        } catch (error) {
            console.error(error);
        }
        getBalance()
        loading = false
    }

    const getBalance = async () => {
        console.log("Get balance")
        loading = true

        //const publicKey = await window.ic.plug.requestConnect();

        const connected = await window.ic.plug.isConnected();

        if (!connected)  {
            const publicKey = await window.ic.plug.requestConnect({ 
                //host: 'http://127.0.0.1',
                whitelist: ['rno2w-sqaaa-aaaaa-aaacq-cai','l53cn-iiaaa-aaaah-qcwia-cai'],
                timeout: 50000
            })
        }
        const principalId = await window.ic.plug.getPrincipal();

        let ledger = getReadActor('yeeiw-3qaaa-aaaah-qcvmq-cai', ledger_idl);
        let account = getAccountIdentifier(principalId);

        let balance = await ledger.account_balance_dfx({account});
        console.log(balance);
        tokens = Number(balance.e8s) / 100000000;
        loading = false
        return balance;
    }

    const transfer2 = async () => {
        // NNS Canister Id as an example
        const tokenCanisterId = 'yeeiw-3qaaa-aaaah-qcvmq-cai'
        const whitelist = [tokenCanisterId];

        // Initialise Agent, expects no return value
        await window?.ic?.plug?.requestConnect({
            whitelist,
        });

        const principalId = await window.ic.plug.agent.getPrincipal();

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
            amount: {"e8s": 1000000000000},
            fee: {"e8s": 10000},
            from_subaccount: [],
            to: "49a286bee871e2d7e9cfbd4e87d42a94942c68c3498e1ef5cbd7a021afe58382",
            created_at_time: []
        });

        console.log(stats);
    }

    onMount(getBalance)
</script>

<header class="App-header">
    <h1>Token Faucet</h1>

</header>
<h1 class=loading{loading}>Your balance <br> {tokens} ICTS</h1>
<!-- <button on:click={transfer2}>Send transaction 2</button> -->
<button class="mint-button" on:click={claim} disabled={loading}>
    {#if loading === true}
        Claiming...
    {:else}
        Claim more tokens
    {/if}
</button>


<style>
    .loadingtrue {
        color: rgb(166, 166, 166);
    }
</style>