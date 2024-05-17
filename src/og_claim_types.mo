import Principal "mo:base/Principal";
module {
    public type DiscordUserId = Text;
    public type Tokens = { e8s : Nat };
    public type FrontendSecret = Text;
    public type UserId = Principal;
    public type Role = { #og1; #og2 };
    public type User = {
        id : UserId;
        claimed : Bool;
        claimPrincipalId : Text;
        claimTimestamp : ?Int;
    };
};
