<script>
  import { Router, Link, Route } from "svelte-navigator";
  import About from "./routes/about.svelte";
  import NFTDetail from "./routes/nftDetail.svelte";
  import NFTList from "./routes/nftList.svelte";
  import Intro from "./Intro.svelte"
 // import Auth from "./Auth.svelte"
  import Faucet from "./routes/faucet.svelte"
  

</script>

<div class="App">
<Router>
    <header>
        <nav>
            <a href="/" class="logo">
                DFINI∞SHIELDS
            </a>
            <Link class="nav-link" to="/">Home</Link>
            <Link class="nav-link" to="about">About</Link>
            <Link class="nav-link" to="faucet">Faucet</Link>
            <Link class="nav-link" to="nft">NFTs</Link>
            <!-- <Auth /> We will use pluge login -->
        </nav>
    </header>
    <div>
        <Route path="/">
            <Intro />
        </Route>
        <Route path="about" component={About} />
        <Route path="faucet" component={Faucet} />
        <Route path="nft" component="{NFTList}" />
        <Route path="nft/:id" component="{NFTDetail}" />
    </div>
</Router>



 <!--  <Intro /> -->
</div>


<style global>
    body {
        margin: 0;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Roboto", "Oxygen",
        "Ubuntu", "Cantarell", "Fira Sans", "Droid Sans", "Helvetica Neue",
        sans-serif;
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
    }

    button {
        font-weight: 600;
    }

    .App {
        text-align: center;
    }

    nav {
        overflow: hidden;
        background-color:rgb(10, 0, 37);
        padding-left: 20px;
        display: flex;
        justify-content: flex-start;
        position: fixed;
        top: 0;
        width: 100%;
    }

    nav a {
        float: left;
        color: #f2f2f2;
        text-align: center;
        padding: 22px 29px;
        text-decoration: none;
        font-size: 17px;
        font-weight: bold;
        transition: all 0.4s ease;
    }

    .nav-link:hover {
        background-color: #ddd;
        color: black;
    }
    nav a.active {
        background-color: #04AA6D;
        color: white;
        
    }

    .logo {
        color: #04AA6D;
        transition: all 0.4s ease;
        font-size: 120%;
    }

    .logo:hover {
        color:blueviolet;
    }

    a[aria-current]{
        text-decoration: underline;
        color: blueviolet;
    }
</style>
