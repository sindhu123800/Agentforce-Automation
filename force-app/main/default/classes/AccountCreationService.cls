/**
 * Service class for creating Accounts
 * This class can be invoked from flows to create new accounts
 */
public with sharing class AccountCreationService {
    
    /**
     * Creates a new account with the provided details
     * @param accountName Name of the account to create
     * @param accountType Type of the account
     * @param industry Industry of the account
     * @return Id of the created account
     */
    @InvocableMethod(label='Create Account' description='Creates a new account with the provided details')
    public static Id createAccount(
        @InvocableVariable(label='Account Name' description='Name of the account to create') String accountName,
        @InvocableVariable(label='Account Type' description='Type of the account') String accountType,
        @InvocableVariable(label='Industry' description='Industry of the account') String industry
    ) {
        // Validate input parameters
        if (String.isBlank(accountName)) {
            throw new AuraHandledException('Account Name is required');
        }
        
        // Create the account
        Account newAccount = new Account(
            Name = accountName,
            Type = accountType,
            Industry = industry
        );
        
        try {
            // Insert the account with user mode for proper security context
            Database.SaveResult result = Database.insert(newAccount, false);
            
            if (result.isSuccess()) {
                return result.getId();
            } else {
                // Throw the first error encountered
                throw new AuraHandledException(result.getErrors()[0].getMessage());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Failed to create account: ' + e.getMessage());
        }
    }
    
    /**
     * Creates multiple accounts at once
     * @param accountList List of account details to create
     * @return List of created account IDs
     */
    @InvocableMethod(label='Create Multiple Accounts' description='Creates multiple accounts from a list of details')
    public static List<Id> createMultipleAccounts(
        @InvocableVariable(label='Account Details' description='List of account details to create') List<Account> accountList
    ) {
        List<Account> accountsToInsert = new List<Account>();
        List<Id> createdAccountIds = new List<Id>();
        
        // Validate input
        if (accountList == null || accountList.isEmpty()) {
            throw new AuraHandledException('Account list cannot be null or empty');
        }
        
        // Build list of accounts to insert
        for (Account acc : accountList) {
            if (acc != null && !String.isBlank(acc.Name)) {
                accountsToInsert.add(acc);
            }
        }
        
        // Insert all accounts
        try {
            List<Database.SaveResult> results = Database.insert(accountsToInsert, false);
            
            for (Database.SaveResult result : results) {
                if (result.isSuccess()) {
                    createdAccountIds.add(result.getId());
                } else {
                    // Log error but continue processing other accounts
                    System.debug('Error creating account: ' + result.getErrors()[0].getMessage());
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('Failed to create accounts: ' + e.getMessage());
        }
        
        return createdAccountIds;
    }
}
