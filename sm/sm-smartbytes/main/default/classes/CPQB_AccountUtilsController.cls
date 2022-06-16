public without sharing class CPQB_AccountUtilsController {
    @AuraEnabled
    public static void resetAccount(Id accId, Boolean deleteCP){
        CPQB_RecordReset.disableBillingTriggers(true);

        CPQB_RecordReset.deletePaymentTransactions(accId);
        CPQB_RecordReset.deletePayments(accId);
        CPQB_RecordReset.deleteCreditNotes(accId);
        CPQB_RecordReset.deleteDebitNotes(accId);
        CPQB_RecordReset.deleteRefunds(accId);
        CPQB_RecordReset.deleteAccountBalanceSnapshots(accId);
        
        CPQB_RecordReset.deleteInvoices(accId);

        CPQB_RecordReset.deleteDiscScheds(accId);
        CPQB_RecordReset.deleteQuotes(accId);
        CPQB_RecordReset.deleteOpportunities(accId);
        CPQB_RecordReset.deleteAssets(accId);
        CPQB_RecordReset.deleteSubscriptions(accId);
        CPQB_RecordReset.deleteContracts(accId);

        CPQB_RecordReset.deleteOrders(accId);
        if(deleteCP == true) {
            CPQB_RecordReset.deleteContractedPrices(accId);
        }

        CPQB_RecordReset.disableBillingTriggers(false);
        
        
        CPQB_RecordReset.delRevenueTransactions(accId);
        CPQB_RecordReset.delTransactionJournalEntryLines(accId);
        CPQB_RecordReset.delTransactionJournalEntries(accId);

        System.debug('Total Number of SOQL Queries in this apex code context: ' + Limits.getQueries());

    }

    @AuraEnabled
    public static string resetAccountAndQuote(Id accId, Boolean deleteCP){
        resetAccount(accId, deleteCP);
        Id quoteId = createOppAndQuote(accId);
        return quoteId;
    }

    @AuraEnabled
    public static void resetBillingAccount(Id accId, Boolean deleteCP){
        CPQB_RecordReset.disableBillingTriggers(true);

        CPQB_RecordReset.deletePaymentTransactions(accId);
        CPQB_RecordReset.deletePayments(accId);
        CPQB_RecordReset.deleteCreditNotes(accId);
        CPQB_RecordReset.deleteDebitNotes(accId);
        CPQB_RecordReset.deleteRefunds(accId);
        CPQB_RecordReset.deleteAccountBalanceSnapshots(accId);
        
        CPQB_RecordReset.deleteInvoices(accId);

        //CPQB_RecordReset.deleteDiscScheds(accId);
        //CPQB_RecordReset.deleteQuotes(accId);
        SBQQ__Quote__c[] quotesToClean = [SELECT Id, SBQQ__Account__c FROM SBQQ__Quote__c WHERE SBQQ__Account__c = :accId];

        for (SBQQ__Quote__c q : quotesToClean) {
                q.SBQQ__Ordered__c = false;
            }
        //CPQB_RecordReset.deleteOpportunities(accId);
        Opportunity[] opportinitiesToClean = [SELECT Id, AccountId FROM Opportunity WHERE AccountId = :accId];

        for (Opportunity o : opportinitiesToClean) {
                o.SBQQ__Contracted__c = false;
                o.SBQQ__Ordered__c = false;
            }
        
        try {
                Database.update(quotesToClean);
            	Database.update(opportinitiesToClean);
            } catch (DmlException e) {
                System.debug(e);
                throw new AuraHandledException(e.getMessage());
            }
        
        CPQB_RecordReset.deleteAssets(accId);
        CPQB_RecordReset.deleteSubscriptions(accId);
        CPQB_RecordReset.deleteContracts(accId);

        CPQB_RecordReset.deleteOrders(accId);
        if(deleteCP == true) {
            CPQB_RecordReset.deleteContractedPrices(accId);
        }

        CPQB_RecordReset.disableBillingTriggers(false);

        System.debug('Total Number of SOQL Queries in this apex code context: ' + Limits.getQueries());

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