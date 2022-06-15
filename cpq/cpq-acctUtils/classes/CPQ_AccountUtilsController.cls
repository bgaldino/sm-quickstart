public without sharing class CPQ_AccountUtilsController {
    @AuraEnabled
    public static void resetAccount(Id accId, Boolean deleteCP){

        CPQ_RecordReset.deleteDiscScheds(accId);
        CPQ_RecordReset.deleteQuotes(accId);
        CPQ_RecordReset.deleteOpportunities(accId);
        CPQ_RecordReset.deleteAssets(accId);
        CPQ_RecordReset.deleteSubscriptions(accId);
        CPQ_RecordReset.deleteContracts(accId);

        CPQ_RecordReset.deleteOrders(accId);
        if(deleteCP == true) {
            CPQ_RecordReset.deleteContractedPrices(accId);
        }

        System.debug('Total Number of SOQL Queries in this apex code context: ' + Limits.getQueries());

    }

    @AuraEnabled
    public static string resetAccountAndQuote(Id accId, Boolean deleteCP){
        resetAccount(accId, deleteCP);
        Id quoteId = createOppAndQuote(accId);
        return quoteId;
    }


    @AuraEnabled
    public static Id createOppAndQuote(Id accId) {
        // Get Std Pricebook
        Id stdPriceBook = getPriceBookId();


        Date realStart = Date.today();
        String accName = [SELECT Name FROM Account WHERE Id = :accId].Name;

        // create opp
        Opportunity newOpp = new Opportunity(AccountId=accId,
                                            Name='New Opportunity for ' + accName,
                                            Pricebook2Id=stdPriceBook,
                                            CloseDate=realStart.addMonths(2),
                                            StageName='Qualification');
        // Insert the Opp
        try {
            Database.insert(newOpp);
            System.debug('Successfully inserted new Opp: ' + newOpp.Id);
        } catch (DmlException e) {
            System.debug('An error occurred inserting the Opportunity: ' + e);
            System.debug('Stack trace:' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }

        // Initialize New Quote
        SBQQ__Quote__c q = new SBQQ__Quote__c(SBQQ__Type__c='Quote',
                                              SBQQ__Status__c='Draft',
                                              SBQQ__Primary__c=true,
                                              SBQQ__SubscriptionTerm__c=12,
                                              SBQQ__StartDate__c=realStart.addDays(1),
                                              SBQQ__ExpirationDate__c=realStart.addMonths(2),
                                              SBQQ__PricebookId__c = stdPriceBook,
                                              SBQQ__Opportunity2__c=newOpp.Id,
                                              SBQQ__Account__c=accId);

        // Insert the quote
        try {
            Database.insert(q);
            System.debug('Successfully inserted new Quote: ' + q.Id);
        } catch (DmlException e) {
            System.debug('An error occurred inserting the Quote: ' + e);
            System.debug('Stack trace:' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
        
        return q.Id;
    }

    public static Id getPriceBookId() {
        if(Test.isRunningTest()) {
            return Test.getStandardPricebookId();
        } else {
            return [SELECT Id, IsStandard FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1].Id;
        }
    }
}