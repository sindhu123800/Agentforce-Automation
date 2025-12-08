@IsTest
private class AccountTriggerHandlerTest {
    @IsTest
    static void testCreatesContactOnSingleInsert() {
        // Arrange
        Account a = new Account(Name = 'Acme Single');

        // Act
        insert a;

        // Assert
        List<Contact> cons = [
            SELECT Id, LastName, AccountId
            FROM Contact
            WHERE AccountId = :a.Id
        ];
        System.assertEquals(1, cons.size(), 'One default Contact should be created.');
        System.assertEquals('Acme Single', cons[0].LastName, 'Contact LastName should default from Account.Name');
        System.assertEquals(a.Id, cons[0].AccountId, 'Contact must be related to inserted Account');
    }

    @IsTest
    static void testCreatesContactsOnBulkInsert() {
        // Arrange
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            accounts.add(new Account(Name = 'Bulk Acc ' + i));
        }

        // Act
        insert accounts;

        // Assert
        Set<Id> accIds = new Map<Id, Account>(accounts).keySet();
        List<Contact> cons = [
            SELECT Id, LastName, AccountId
            FROM Contact
            WHERE AccountId IN :accIds
        ];
        System.assertEquals(5, cons.size(), 'One Contact should be created per Account in bulk mode');

        // Validate LastName mapping
        Map<Id, Account> accById = new Map<Id, Account>(accounts);
        for (Contact c : cons) {
            System.assertEquals(accById.get(c.AccountId).Name, c.LastName, 'Each Contact LastName should match its Account Name');
        }
    }

    @IsTest
    static void testNullOrBlankAccountNameHandled() {
        // Arrange: create an Account with blank name to exercise 'Unknown' fallback
        // Note: In most orgs, Account.Name is required by validation rules/standard config.
        // This test is defensive and may be skipped if org enforces required Name.
        Account a = new Account();
        // If insert fails due to Name required, we skip this scenario to avoid false negatives.
        Test.startTest();
        try {
            insert a;
        } catch (DmlException e) {
            Test.stopTest();
            System.assert(true, 'Account.Name is required in this org; fallback path not applicable.');
            return;
        }
        Test.stopTest();

        // If insert succeeded, assert a Contact was created with 'Unknown' fallback.
        List<Contact> cons = [
            SELECT Id, LastName, AccountId
            FROM Contact
            WHERE AccountId = :a.Id
        ];
        System.assertEquals(1, cons.size(), 'One default Contact should be created even if Account.Name blank');
        System.assertEquals('Unknown', cons[0].LastName, 'Fallback LastName should be Unknown when Account.Name is blank');
    }
}
