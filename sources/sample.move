module sumitha_addr::TokenWithBlacklist {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use std::vector;
    
    /// Struct representing token allowances and blacklist management
    struct TokenManager has store, key {
        allowances: vector<Allowance>,     // List of approved allowances
        blacklisted: vector<address>,      // Blacklisted addresses
        owner: address,                    // Contract owner
    }
    
    /// Struct representing an allowance for delegated transfers
    struct Allowance has store, copy, drop {
        spender: address,    // Address allowed to spend
        amount: u64,         // Amount approved for spending
        owner: address,      // Owner of the tokens
    }
    
    /// Function to initialize the token manager with blacklist capabilities
    public fun initialize_token_manager(owner: &signer) {
        let owner_addr = signer::address_of(owner);
        let token_manager = TokenManager {
            allowances: vector::empty<Allowance>(),
            blacklisted: vector::empty<address>(),
            owner: owner_addr,
        };
        move_to(owner, token_manager);
    }
    
    /// Function to approve allowance for delegated transfers with blacklist check
    public fun approve_allowance(
        owner: &signer, 
        spender: address, 
        amount: u64
    ) acquires TokenManager {
        let owner_addr = signer::address_of(owner);
        let token_manager = borrow_global_mut<TokenManager>(owner_addr);
        
        // Check if spender is blacklisted
        assert!(!vector::contains(&token_manager.blacklisted, &spender), 1);
        
        let new_allowance = Allowance {
            spender,
            amount,
            owner: owner_addr,
        };
        
        // Remove existing allowance if present
        let i = 0;
        let len = vector::length(&token_manager.allowances);
        while (i < len) {
            let allowance = vector::borrow(&token_manager.allowances, i);
            if (allowance.spender == spender && allowance.owner == owner_addr) {
                vector::remove(&mut token_manager.allowances, i);
                break
            };
            i = i + 1;
        };
        
        // Add new allowance
        vector::push_back(&mut token_manager.allowances, new_allowance);
    }
}