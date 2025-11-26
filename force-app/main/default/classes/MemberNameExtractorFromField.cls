public class MemberNameExtractorFromField {
 
    public static void extractAndStoreNames(Id memberId) {
        try {
            Member__c memberRecord = [
                SELECT Id, Extracted_Data__c, Extracted_Names__c 
                FROM Member__c 
                WHERE Id = :memberId
                LIMIT 1
            ];
 
            String fileContent = memberRecord.Extracted_Data__c;
            System.debug('Full Extracted_Data__c Content:\n' + fileContent);
 
            if (String.isBlank(fileContent)) return;
 
            List<String> rows = fileContent.split('\n');
            if (rows.isEmpty()) return;
 
            String[] headers = rows[0].split(',');
            System.debug('CSV Headers: ' + headers);
 
            Integer nameIndex = -1;
            for (Integer i = 0; i < headers.size(); i++) {
                if (headers[i].trim().equalsIgnoreCase('Name')) {
                    nameIndex = i;
                    break;
                }
            }
 
            System.debug('Detected "Name" Column Index: ' + nameIndex);
            if (nameIndex == -1) return;
 
            List<String> nameList = new List<String>();
 
            for (Integer i = 1; i < rows.size(); i++) {
                String[] columns = rows[i].split(',');
                if (nameIndex < columns.size()) {
                    String name = columns[nameIndex].trim();
                    System.debug('Extracted Name from Row ' + i + ': ' + name);
                    nameList.add(name);
                }
            }
 
            String combinedNames = String.join(nameList, ', ');
            System.debug('Combined Extracted Names: ' + combinedNames);
 
            memberRecord.Extracted_Names__c = combinedNames;
            update memberRecord;
 
        } catch (Exception e) {
            System.debug('Error extracting names: ' + e.getMessage());
        }
    }
}