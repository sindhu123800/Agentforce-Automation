// Trigger: Creates a default Contact for each newly inserted Account
trigger AccountAfterInsertCreateContact on Account (after insert) {
    AccountTriggerHandler.createDefaultContacts(Trigger.new);
}
