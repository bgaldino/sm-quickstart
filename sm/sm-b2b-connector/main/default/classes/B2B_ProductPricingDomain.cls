public without sharing  class B2B_ProductPricingDomain {
    @AuraEnabled
    public String productId{get;set;}

    @AuraEnabled
    public String sku{get;set;}

    @AuraEnabled
    public String productCode{get;set;}

    @AuraEnabled
    public boolean isStandardPricing{get;set;}

    @AuraEnabled
    public boolean isRecurringProduct{get;set;}

    @AuraEnabled
    public String currencyCode{get;set;}

    @AuraEnabled
    public String effectiveAccountId{get;set;}

    @AuraEnabled
    public String communityId{get;set;}

    @AuraEnabled
    public String webstore{get;set;}

    @AuraEnabled
    public String webstoreId{get;set;}

    @AuraEnabled
    public User currentUser{get;set;}

    @AuraEnabled
    public String listPrice{get;set;}

    @AuraEnabled
    public String unitPrice{get;set;}

    @AuraEnabled
    public String pricebookEntryId{get;set;}
    @AuraEnabled
    public String pricebookId{get;set;}

    @AuraEnabled
    public List<B2B_PriceAdjustments> priceAdjustmentList{get;set;}

    @AuraEnabled
    public List<B2B_SubProdTerm> subscriptions{get;set;}
    
    @AuraEnabled
    public Map<String,Object> subscriberInput{get;set;}

    public class B2B_PriceAdjustments{
        @AuraEnabled
        public String adjustmentType{get;set;}

        @AuraEnabled
        public String adjustmentValue{get;set;}

        @AuraEnabled
        public String lowerBound{get;set;}

        @AuraEnabled
        public String tierUnitPrice{get;set;}

        @AuraEnabled
        public String upperBound{get;set;}
    }
}