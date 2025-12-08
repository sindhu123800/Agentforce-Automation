/**
 * Class to create a user in Salesforce with specified profile
 */
public class CreateUser {
    
    /**
     * Creates a new user with Chatter Free User profile
     * @param firstName First name of the user
     * @param lastName Last name of the user
     * @param email Email address of the user
     * @return ID of the created user
     */
    public static Id createUser(String firstName, String lastName, String email) {
        // Get the Chatter Free User profile ID
        Profile chatterFreeUserProfile = [SELECT Id FROM Profile WHERE Name = 'Chatter Free User' LIMIT 1];
        
        // Create the user
        User newUser = new User(
            FirstName = firstName,
            LastName = lastName,
            Email = email,
            ProfileId = chatterFreeUserProfile.Id,
            Username = email
        );
        
        // Insert the user
        Database.SaveResult result = Database.insert(newUser, false);
        
        if (result.isSuccess()) {
            System.debug('User created successfully with ID: ' + result.getId());
            return result.getId();
        } else {
            System.debug('Error creating user: ' + result.getErrors()[0].getMessage());
            throw new CustomException('Failed to create user: ' + result.getErrors()[0].getMessage());
        }
    }
    
    /**
     * Custom exception class for user creation errors
     */
    public class CustomException extends Exception {}
}
