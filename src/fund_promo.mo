import Principal "mo:base/Principal";
import Ledger "./ledger_service";
import C "./_constants"

actor {
    let ledger = actor (C.ledgerId) : Ledger.Self;

    public shared ({ caller }) func send(owner : Principal, amount : Nat) : async Ledger.Result {
        assert (caller == Principal.fromText(C.admin1));

        let to : Ledger.Account = {
            owner;
            subaccount = null;
        };

        let transferArg : Ledger.TransferArg = {
            to;
            fee = null;
            memo = null;
            from_subaccount = null;
            created_at_time = null;
            amount;
        };

        await ledger.icrc1_transfer(transferArg);
    };

    // test

    public shared query ({ caller }) func whoami() : async Text {
        return Principal.toText(caller);
    };
};
