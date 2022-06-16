public class CPQB_ExperienceCloud_OrderDetailsCTRL {
    
    @AuraEnabled
    public static SBQQ__Quote__c getQuoteDetails(Id quoteId) {
        
        SBQQ__Quote__c myQuote = [SELECT Id, Name, SBQQ__StartDate__c, Update_Flag__c FROM SBQQ__Quote__c WHERE Id =: quoteId];
		
        
        myQuote.Update_Flag__c = !myQuote.Update_Flag__c;
        update myQuote;
        
        
        //Opportunity myOpp = [SELECT Id FROM Opportunity WHERE Id =: myQuote.SBQQ__Opportunity2__c];
        //myOpp.StageName = 'Closed Won';
        //update myOpp;
        
        //Order myOrder = [SELECT Id, OrderNumber, EffectiveDate FROM Order WHERE SBQQ__Quote__c =:quoteId];
        
        return myQuote;
    }

}