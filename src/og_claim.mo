import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Nat "mo:base/Nat";

// ...
import Ledger "./ledger_service";
import T "./og_claim_types";
import C "./_constants"

shared actor class _OG_CLAIM(fs : T.FrontendSecret) = Self {
    let token = actor (C.ledgerId) : Ledger.Self;
    let nodeId = "";
    let adminPrincipal = Principal.fromText(C.admin1);
    let e8s = 10 ** 8;
    let og1Amount = 0 * e8s;
    let og2Amount = 0 * e8s;

    // stable

    private stable var frontendSecret = fs;

    stable var usersOg1Entries : [(T.DiscordUserId, T.User)] = [];
    let usersOg1 = HashMap.fromIter<T.DiscordUserId, T.User>(usersOg1Entries.vals(), 10, Text.equal, Text.hash);

    stable var usersOg2Entries : [(T.DiscordUserId, T.User)] = [];
    let usersOg2 = HashMap.fromIter<T.DiscordUserId, T.User>(usersOg2Entries.vals(), 10, Text.equal, Text.hash);

    // funcs

    private func _sendTokens(user : Principal, amount : Nat) : async Ledger.Result {
        let to : Ledger.Account = { owner = user; subaccount = null };

        let transferArg : Ledger.TransferArg = {
            to;
            fee = null;
            memo = null;
            from_subaccount = null;
            created_at_time = null;
            amount;
        };
        await token.icrc1_transfer(transferArg);
    };

    public shared ({ caller }) func claim(discordUserId : T.DiscordUserId, principalId : Text, role : Text) : async ?Ledger.Result {
        assert (caller == Principal.fromText(nodeId));
        var user : T.User = {
            id = Principal.fromText("");
            claimed = false;
            claimPrincipalId = "";
            claimTimestamp = null;
        };

        if (role == "og1") {
            switch (usersOg1.get(discordUserId)) {
                case (null) return null;
                case (?u) user := u;
            };
        };

        if (role == "og2") {
            switch (usersOg2.get(discordUserId)) {
                case (null) return null;
                case (?u) user := u;
            };
        };

        if (not user.claimed) {
            let id = Principal.fromText(principalId);

            if (role == "og1") {
                let transferRes = await _sendTokens(id, og1Amount);
                usersOg1.put(discordUserId, { user with claimed = true; claimTimestamp = ?Time.now() });
                return ?transferRes;
            };

            if (role == "og2") {
                let transferRes = await _sendTokens(id, og2Amount);
                usersOg2.put(discordUserId, { user with claimed = true; claimTimestamp = ?Time.now() });
                return ?transferRes;
            };
        };

        return null;
    };

    public shared ({ caller }) func claimFrontend(discordUserId : T.DiscordUserId, role : T.Role, claimPrincipalId : Text, fs : T.FrontendSecret) : async ?Ledger.Result {
        assert (not Principal.isAnonymous(caller));
        assert (fs == frontendSecret);
        var user : T.User = {
            id = caller;
            claimed = false;
            claimPrincipalId = claimPrincipalId;
            claimTimestamp = null;
        };

        // verify

        switch (role) {
            case (#og1) {
                let transferRes = await _sendTokens(Principal.fromText(claimPrincipalId), og1Amount);
                usersOg1.put(discordUserId, { user with claimed = true; claimTimestamp = ?Time.now() });
                return ?transferRes;
            };
            case (#og2) {
                let transferRes = await _sendTokens(Principal.fromText(claimPrincipalId), og2Amount);
                usersOg2.put(discordUserId, { user with claimed = true; claimTimestamp = ?Time.now() });
                return ?transferRes;
            };
        };
    };

    // query

    public shared query ({ caller }) func claimedOg1UsersNum() : async Text {
        if (caller != Principal.fromText(nodeId)) return "";
        var num = 0;
        for (user in usersOg1.vals()) if (user.claimed) num += 1;
        return Nat.toText(num) # "/" # Nat.toText(usersOg1.size());
    };

    public shared query ({ caller }) func claimedOg2UsersNum() : async Text {
        if (caller != Principal.fromText(nodeId)) return "";
        var num = 0;
        for (user in usersOg2.vals()) if (user.claimed) num += 1;
        return Nat.toText(num) # "/" # Nat.toText(usersOg2.size());
    };

    // ...

    public shared ({ caller }) func updateFrontendSecret(newFrontendSecret : T.FrontendSecret) : async () {
        assert (caller == adminPrincipal);
        frontendSecret := newFrontendSecret;
    };

    // state

    system func preupgrade() {
        usersOg1Entries := Iter.toArray(usersOg1.entries());
        usersOg2Entries := Iter.toArray(usersOg2.entries());
    };

    system func postupgrade() {
        usersOg1Entries := [];
        usersOg2Entries := [];
    };
};
