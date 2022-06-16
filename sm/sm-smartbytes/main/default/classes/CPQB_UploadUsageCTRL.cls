public with sharing class CPQB_UploadUsageCTRL {
    
    @AuraEnabled
    public static List<blng__Usage__c> onProcessBatch(String base64){
        System.debug(base64);
        String decodedCSV = EncodingUtil.base64Decode(base64.split(',')[1]).toString();

        // this will split into a few lines on the system debug! 
        System.debug(decodedCSV);
        List<blng__Usage__c> usages = csvToUsage(decodedCSV);
        return usages;
    }

    public static List<blng__Usage__c> csvToUsage(String csvAsString) {
        List<blng__Usage__c> usageList = new List<blng__Usage__c>();
        String[] csvFileLines = csvAsString.split('\r\n'); 
        
        // Starts !AFTER! the first line, expects a header and ignores it.
        for(Integer i=1; i < csvFileLines.size(); i++){
            blng__Usage__c usageLine = new blng__Usage__c();
            
            String[] csvRecordData = csvFileLines[i].split(',');
            System.debug('CSV: ' + csvRecordData);
            usageLine.blng__MatchingId__c = csvRecordData[0];
            usageLine.blng__UnitOfMeasure__c = csvRecordData[1];
            usageLine.blng__MatchingAttribute__c = csvRecordData[2];
            usageLine.blng__Quantity__c = Decimal.valueOf(csvRecordData[3]);
            Date sDate = Date.parse(csvRecordData[4]); 
            Date eDate = Date.parse(csvRecordData[5]);
            usageLine.blng__StartDateTime__c = datetime.newInstance(sDate.year(), sDate.Month(), sDate.Day());
            usageLine.blng__EndDateTime__c = datetime.newInstance(eDate.year(), eDate.Month(), eDate.Day());

            usageList.add(usageLine);
            
        }
        return usageList;
    }

    @AuraEnabled
    public static void saveUsages(List<blng__Usage__c> usageList) {
        try {
            Database.insert(usageList);
            System.debug('Successfully Inserted Usage List: ' + JSON.serializePretty(usageList));
        } catch (DmlException err) {
            System.debug('An Error occured: ' + err);
            throw new AuraHandledException(err.getMessage());
        }
    }
}