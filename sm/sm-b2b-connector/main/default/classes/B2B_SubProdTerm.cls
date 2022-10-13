public with sharing class B2B_SubProdTerm {
    @AuraEnabled
    public String id{get;set;}

	@AuraEnabled
    public Boolean  autoRenew{get;set;}
    
    @AuraEnabled
    public String  displayName{get;set;}

	@AuraEnabled
    public Boolean  ignoreBillingFrequency{get;set;}
	
	@AuraEnabled
    public String  subConfiguration{get;set;}
	
    @AuraEnabled
    public String sku{get;set;}

    @AuraEnabled
    public double  subscriptionPrice{get;set;}

    @AuraEnabled
    public double  unitPrice{get;set;}

    @AuraEnabled
    public String renewalUplift{get;set;}

    @AuraEnabled
    public double upfront{get;set;}

    @AuraEnabled
    public double upfrontAmount{get;set;}

    @AuraEnabled
    public double uplift{get;set;}

    @AuraEnabled
    public Integer  installmentCount{get;set;}
    
    @AuraEnabled
    public Integer  installmentFrequency{get;set;}
    
    @AuraEnabled
    public String installmentFrequencyUOM{get;set;}

    @AuraEnabled
    public Integer orderCount{get;set;}
    
    @AuraEnabled
    public Integer orderFrequency{get;set;}

    @AuraEnabled
    public String orderFrequencyUOM{get;set;}

    @AuraEnabled
    public String displayNameWOUpfront{get;set;}

    @AuraEnabled
    public String displayNameUpfront{get;set;}

}