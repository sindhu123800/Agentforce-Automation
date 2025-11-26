public class AgentChatPdfController {

  //  public String rawText { get; set; }
    
 //   public AgentChatPdfController() {
        
 //       rawText = ApexPages.currentPage().getParameters().get('responseText');
 //   }

public List<List<String>> tableData { get; set; }

    public AgentChatPdfController() {
        String rawText = ApexPages.currentPage().getParameters().get('responseText');
		rawText = rawText.replaceAll('[*#-]', '');
        tableData = new List<List<String>>();

        if (String.isNotBlank(rawText)) {
            // Assume rows are separated by newline
            List<String> rows = rawText.split('\n');
            for (String row : rows) {
                // Columns are separated by commas
                //List<String> cols = row.split(',');
                //tableData.add(cols);
                 tableData.add(new List<String>{ row });
            }
        }
    }
}