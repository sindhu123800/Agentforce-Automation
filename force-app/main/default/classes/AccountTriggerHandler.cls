public with sharing class AccountTriggerHandler {
    /**
     * Create a default Contact for each newly inserted Account.
     * Defaults:
     * - Contact.LastName = Account.Name (falls back to 'Unknown' if blank)
     * - Contact.AccountId = Account.Id
     */
    public static void createDefaultContacts(List<Account> newAccounts) {
        if (newAccounts == null || newAccounts.isEmpty()) {
            return;
        }
        List<Contact> contactsToInsert = new List<Contact>();
        for (Account acc : newAccounts) {
            if (acc == null || acc.Id == null) continue;

            String lastName = String.isBlank(acc.Name) ? 'Unknown' : acc.Name.trim();

            contactsToInsert.add(new Contact(
                LastName  = lastName,
                AccountId = acc.Id
            ));
        }
        if (!contactsToInsert.isEmpty()) {
            insert contactsToInsert;
        }
    }
}
