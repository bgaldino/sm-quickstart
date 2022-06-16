public class CPQB_ImportUsageCTRL {
    public blng__Usage__c[] usageList {get; set;}
    
    public Blob csvFileBody{get;set;}
    public string csvAsString{get;set;}
    public String[] csvFileLines{get;set;}
    
    
    public void ImportCSVFile(){
        csvFileLines = new String[]{};
        usageList = New List<blng__Usage__c>();
        csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\r\n'); 
        
        // Starts !AFTER! the first line, expects a header and ignores it.
        for(Integer i=1; i < csvFileLines.size(); i++){
            blng__Usage__c usageLine = new blng__Usage__c();
            
            string[] csvRecordData = csvFileLines[i].split(',');
            system.debug('CSV: ' + csvRecordData);
            usageLine.blng__MatchingId__c = csvRecordData[0];
            usageLine.blng__Quantity__c = Decimal.valueOf(csvRecordData[1]);               
            Date sDate = date.parse(csvRecordData[2]); 
            Date eDate = date.parse(csvRecordData[3]);
            
            
            usageLine.blng__StartDateTime__c = datetime.newInstance(sDate.year(), sDate.Month(), sDate.Day());
            usageLine.blng__EndDateTime__c = datetime.newInstance(eDate.year(), eDate.Month(), eDate.Day());
            usageLine.blng__Status__c = 'New';   
            
            
            usageList.add(usageLine);
            
        }
        system.debug(JSON.serializePretty(usageList));
        
    } 
    
    public void clearUsage(){
        usageList.clear();
    }

    public void AddUsage(){
        
        try {
            Database.insert(usageList);
            System.debug('Successfully Inserted Usage List: ' + JSON.serializePretty(usageList));
            clearUsage();
        } catch (Exception err) {
            System.debug('An Error occured: ' + err);
        }
        
        /*
PageReference pg = new PageReference('/' + ApexPages.currentPage().getParameters().get('id'));
pg.setRedirect(true);
return pg; 
*/
    }
}