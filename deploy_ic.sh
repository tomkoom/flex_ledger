# export MINTER_ID=$(dfx identity get-principal)
# echo "minter: $MINTER_ID"

export MINTER_ID="ci35a-cqaaa-aaaag-acmvq-cai"
echo "minter: $MINTER_ID"

# export ARCHIVE_CONTROLLER=$(dfx identity get-principal)
# echo "archive_controller: $ARCHIVE_CONTROLLER"

export ARCHIVE_CONTROLLER="ci35a-cqaaa-aaaag-acmvq-cai"
echo "archive_controller: $ARCHIVE_CONTROLLER"

# ...

export DEPLOY_ID=$(dfx identity get-principal)
echo "deploy_id: $DEPLOY_ID"

# ...

export TOKEN_NAME="FLEX"
echo "name: $TOKEN_NAME"

export TOKEN_SYMBOL="FLEX"
echo "symbol: $TOKEN_SYMBOL"

export PRE_MINTED_TOKENS=0
echo "pre_minted_tokens: $PRE_MINTED_TOKENS"

export TRANSFER_FEE=10_000
echo "transfer_fee: $TRANSFER_FEE"

export TRIGGER_THRESHOLD=2000
echo "trigger_threshold: $TRIGGER_THRESHOLD"

export NUM_OF_BLOCK_TO_ARCHIVE=1000
echo "num_of_block_to_archive: $NUM_OF_BLOCK_TO_ARCHIVE"

export CYCLE_FOR_ARCHIVE_CREATION=10000000000000
echo "cycle_for_archive_creation: $CYCLE_FOR_ARCHIVE_CREATION"

export FEATURE_FLAGS=true
echo "feature_flags: $FEATURE_FLAGS"

echo "start deploy"

dfx deploy --network=ic icrc1_ledger --argument "(variant {Init = 
record {
     token_symbol = \"${TOKEN_SYMBOL}\";
     token_name = \"${TOKEN_NAME}\";
     minting_account = record { owner = principal \"${MINTER_ID}\" };
     transfer_fee = ${TRANSFER_FEE};
     metadata = vec {};
     feature_flags = opt record{icrc2 = ${FEATURE_FLAGS}};
     initial_balances = vec { record { record { owner = principal \"${DEPLOY_ID}\"; }; ${PRE_MINTED_TOKENS}; }; };
     archive_options = record {
         num_blocks_to_archive = ${NUM_OF_BLOCK_TO_ARCHIVE};
         trigger_threshold = ${TRIGGER_THRESHOLD};
         controller_id = principal \"${ARCHIVE_CONTROLLER}\";
         cycles_for_archive_creation = opt ${CYCLE_FOR_ARCHIVE_CREATION};
     };
 }
})"
