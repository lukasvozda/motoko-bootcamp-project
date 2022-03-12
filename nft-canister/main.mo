import Error "mo:base/Error";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import P "mo:base/Prelude";
import Nat64 "mo:base/Nat64";

actor Dip721Nft {
	public shared query (doIOwn__msg) func doIOwn(tokenId : Nat) : async Bool {
		let caller = doIOwn__msg.caller; // First input
		_ownerOf(tokenId) == ?caller;
	};
	
	stable var name_ : Text = "DFINI-SHIELDS NFTs";
	
	stable var symbol_ : Text = "SHIELD";

	
	// Adapted from: https://github.com/SuddenlyHazel/DIP721/blob/main/src/DIP721/DIP721.mo

    // custom type for colors
    private type Colors = {
        color1 : Text;
        color2 : Text;
    };

    private type Balance = {
        e8s : Nat64;
    };

    private type AccountId = Text;
    private type Account = {
        account : AccountId;
    };

    // stable var for keeping account balance and "checking" transactions
    private stable var accountBalance : Nat64 = 0;

    private stable var colorMemory : [Text] = [];
	
	private type TokenAddress = Principal;
	private type TokenId = Nat;

	private stable var tokenPk : Nat = 0;
	
	private stable var tokenURIEntries : [(TokenId, Text)] = [];
    private stable var tokenColorsEntries : [(TokenId, Colors)] = [];
	private stable var ownersEntries : [(TokenId, Principal)] = [];
	private stable var balancesEntries : [(Principal, Nat)] = [];
	private stable var tokenApprovalsEntries : [(TokenId, Principal)] = [];
	private stable var operatorApprovalsEntries : [(Principal, [Principal])] = [];
	
	private let tokenURIs : HashMap.HashMap<TokenId, Text> = HashMap.fromIter<TokenId, Text>(tokenURIEntries.vals(), 10, Nat.equal, Hash.hash);
    // my custom hasmap that is storing color codes for each NFT
    private let tokenColors : HashMap.HashMap<TokenId, Colors> = HashMap.fromIter<TokenId, Colors>(tokenColorsEntries.vals(), 10, Nat.equal, Hash.hash);
	private let owners : HashMap.HashMap<TokenId, Principal> = HashMap.fromIter<TokenId, Principal>(ownersEntries.vals(), 10, Nat.equal, Hash.hash);
	private let balances : HashMap.HashMap<Principal, Nat> = HashMap.fromIter<Principal, Nat>(balancesEntries.vals(), 10, Principal.equal, Principal.hash);
	private let tokenApprovals : HashMap.HashMap<TokenId, Principal> = HashMap.fromIter<TokenId, Principal>(tokenApprovalsEntries.vals(), 10, Nat.equal, Hash.hash);
	private let operatorApprovals : HashMap.HashMap<Principal, [Principal]> = HashMap.fromIter<Principal, [Principal]>(operatorApprovalsEntries.vals(), 10, Principal.equal, Principal.hash);
	
	private func _unwrap<T>(x : ?T) : T {
		switch x {
			case null { P.unreachable() };
			case (?x_) { x_ };
		}
	};

	public query func listTokens(): async [(TokenId, Text)] {
        return Iter.toArray(tokenURIs.entries());
    };


    // list NFTS for given principal as a query function for fast loading
    public query func listMyTokens(p : Principal) : async [(TokenId, Text)] {
        tokenURIEntries := Iter.toArray(tokenURIs.entries());
        ownersEntries := Iter.toArray(owners.entries());
        // filter token IDs that caller owns and map them
        let ownedEntries: [(TokenId, Principal)] = Array.filter<(TokenId, Principal)>(ownersEntries, func (x) {return x.1 == p});
        let ownedTokenIds = Array.map<(TokenId, Principal), TokenId>(ownedEntries, func (x) {return x.0});
        return Array.map<TokenId, (TokenId, Text)>(ownedTokenIds, func (x) {
            let tokenURI = tokenURIs.get(x);
            // temporar solution, return empty string if no tokenURI
            return (x, Option.get<Text>(tokenURI, ""));
        });
    };
    

    public query func listTokenColors(): async [(TokenId, Colors)] {
        return Iter.toArray(tokenColors.entries());
    };
	
	public shared query func balanceOf(p : Principal) : async ?Nat {
		return balances.get(p);
	};
	
	public shared query func ownerOf(tokenId : TokenId) : async ?Principal {
		return _ownerOf(tokenId);
	};
	
	public shared query func tokenURI(tokenId : TokenId) : async ?Text {
		return _tokenURI(tokenId);
	};

    public shared query func tokenColor(tokenId : TokenId) : async ?Colors {
		return _tokenColor(tokenId);
	};
	
	public shared query func name() : async Text {
		return name_;
	};
	
	public shared query func symbol() : async Text {
		return symbol_;
	};
	
	public shared func isApprovedForAll(owner : Principal, opperator : Principal) : async Bool {
		return _isApprovedForAll(owner, opperator);
	};
	
	public shared(msg) func approve(to : Principal, tokenId : TokenId) : async () {
		switch(_ownerOf(tokenId)) {
			case (?owner) {
				assert to != owner;
				assert msg.caller == owner or _isApprovedForAll(owner, msg.caller);
				_approve(to, tokenId);
			};
			case (null) {
				throw Error.reject("No owner for token")
			};
		}
	};
	
	public shared func getApproved(tokenId : Nat) : async Principal {
		switch(_getApproved(tokenId)) {
			case (?v) { return v };
			case null { throw Error.reject("None approved") }
		}
	};
	
	public shared(msg) func setApprovalForAll(op : Principal, isApproved : Bool) : () {
		assert msg.caller != op;
		
		switch (isApproved) {
			case true {
				switch (operatorApprovals.get(msg.caller)) {
					case (?opList) {
						var array = Array.filter<Principal>(opList,func (p) { p != op });
						array := Array.append<Principal>(array, [op]);
						operatorApprovals.put(msg.caller, array);
					};
					case null {
						operatorApprovals.put(msg.caller, [op]);
					};
				};
			};
			case false {
				switch (operatorApprovals.get(msg.caller)) {
					case (?opList) {
						let array = Array.filter<Principal>(opList, func(p) { p != op });
						operatorApprovals.put(msg.caller, array);
					};
					case null {
						operatorApprovals.put(msg.caller, []);
					};
				};
			};
		};
		
	};
	
	public shared(msg) func transferFrom(from : Principal, to : Principal, tokenId : Nat) : () {
		assert _isApprovedOrOwner(msg.caller, tokenId);
		
		_transfer(from, to, tokenId);
	};

    let token_canister : actor { account_balance_dfx : (Account) -> async Balance} = actor("yeeiw-3qaaa-aaaah-qcvmq-cai");
    
    public func _getBalance() : async Nat64 {

        let account_obj : Account = {
            account = "49a286bee871e2d7e9cfbd4e87d42a94942c68c3498e1ef5cbd7a021afe58382"
        };

        var balance : Balance = await token_canister.account_balance_dfx(account_obj);
        var tokens : Nat64 = balance.e8s;
    
        return(tokens);
    };

    private func _updateBalance(new : Nat64) : async () {
        accountBalance := new;
    };

	// changed return type to text to return more explicit messagess what could went wrong
	public shared(msg) func mint(uri : Text, col : Colors) : async Text {
		tokenPk += 1;
        // this is not ideal, but checking if the balance increased and if yes, we consider the payment successfull, the token faucet canister does not provide a way how to check the block or transaction
        let newBalance : Nat64 = await _getBalance();

        // adding more checks, would be better to have make more explicit error situations
        var color1Exists : Bool = _colorExists(col.color1);
        var color2Exists : Bool = _colorExists(col.color2);
        // if all is fine, mint the NFT
        if (accountBalance < newBalance and not color1Exists and not color2Exists) {
            _mint(msg.caller, tokenPk, uri, col);
            accountBalance := newBalance;
		    return "Success";
        };
		if (color1Exists or color2Exists) {
			return "The color combination is taken!";
		};
		if (accountBalance < newBalance) {
			return "Your payment didn't arrive!"
		};
        return return "Something went wrong.";
	};
	
	
	// Internal
	
	private func _ownerOf(tokenId : TokenId) : ?Principal {
		return owners.get(tokenId);
	};
	
	private func _tokenURI(tokenId : TokenId) : ?Text {
		return tokenURIs.get(tokenId);
	};

    private func _tokenColor(tokenId : TokenId) : ?Colors {
		return tokenColors.get(tokenId);
	};
	
	private func _isApprovedForAll(owner : Principal, opperator : Principal) : Bool {
		switch (operatorApprovals.get(owner)) {
			case(?whiteList) {
				for (allow in whiteList.vals()) {
					if (allow == opperator) {
						return true;
					};
				};
			};
			case null {return false;};
		};
		return false;
	};
	
	private func _approve(to : Principal, tokenId : Nat) : () {
		tokenApprovals.put(tokenId, to);
	};
	
	private func _removeApprove(tokenId : Nat) : () {
		ignore tokenApprovals.remove(tokenId);
	};
	
	private func _exists(tokenId : Nat) : Bool {
		return Option.isSome(owners.get(tokenId));
	};

    // checks if color is already registered in the memory
    private func _colorExists(c : Text) : Bool {
        var colors = colorMemory.vals();
        for (color in colors){
            if (c == color){
                return true
            };
        };
		return false;
	};
	
	private func _getApproved(tokenId : Nat) : ?Principal {
		assert _exists(tokenId) == true;
		switch(tokenApprovals.get(tokenId)) {
			case (?v) { return ?v };
			case null {
				return null;
			};
		}
	};
	
	private func _hasApprovedAndSame(tokenId : Nat, spender : Principal) : Bool {
		switch(_getApproved(tokenId)) {
			case (?v) {
				return v == spender;
			};
			case null { return false }
		}
	};
	
	private func _isApprovedOrOwner(spender : Principal, tokenId : Nat) : Bool {
		assert _exists(tokenId);
		let owner = _unwrap(_ownerOf(tokenId));
		return spender == owner or _hasApprovedAndSame(tokenId, spender) or _isApprovedForAll(owner, spender);
	};
	
	private func _transfer(from : Principal, to : Principal, tokenId : Nat) : () {
		assert _exists(tokenId);
		assert _unwrap(_ownerOf(tokenId)) == from;
		
		// Bug in HashMap https://github.com/dfinity/motoko-base/pull/253/files
		// this will throw unless you patch your file
		_removeApprove(tokenId);
		
		_decrementBalance(from);
		_incrementBalance(to);
		owners.put(tokenId, to);
	};
	
	private func _incrementBalance(address : Principal) {
		switch (balances.get(address)) {
			case (?v) {
				balances.put(address, v + 1);
			};
			case null {
				balances.put(address, 1);
			}
		}
	};
	
	private func _decrementBalance(address : Principal) {
		switch (balances.get(address)) {
			case (?v) {
				balances.put(address, v - 1);
			};
			case null {
				balances.put(address, 0);
			}
		}
	};
	
	private func _mint(to : Principal, tokenId : Nat, uri : Text, col : Colors) : () {
		assert not _exists(tokenId);

        // creating tokenURI in the backend as a hostname/nft/ + tokenId
        var tokenURI : Text = uri # "/nft/" # Nat.toText(tokenId);
		
		_incrementBalance(to);
        tokenColors.put(tokenId, col);
        colorMemory := Array.append(colorMemory, [col.color1]);
        colorMemory := Array.append(colorMemory, [col.color2]);
		owners.put(tokenId, to);
		tokenURIs.put(tokenId,tokenURI)
	};
	
	private func _burn(tokenId : Nat) {
		let owner = _unwrap(_ownerOf(tokenId));
		
		_removeApprove(tokenId);
		_decrementBalance(owner);
		
		ignore owners.remove(tokenId);
	};
	
	system func preupgrade() {
		tokenURIEntries := Iter.toArray(tokenURIs.entries());
        tokenColorsEntries := Iter.toArray(tokenColors.entries());
		ownersEntries := Iter.toArray(owners.entries());
		balancesEntries := Iter.toArray(balances.entries());
		tokenApprovalsEntries := Iter.toArray(tokenApprovals.entries());
		operatorApprovalsEntries := Iter.toArray(operatorApprovals.entries());
		
	};
	
	system func postupgrade() {
		tokenURIEntries := [];
        tokenColorsEntries := [];
		ownersEntries := [];
		balancesEntries := [];
		tokenApprovalsEntries := [];
		operatorApprovalsEntries := [];
	};
};      