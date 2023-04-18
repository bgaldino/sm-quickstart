public with sharing class B2BOrderModel {
    
    @AuraEnabled
    public String orderId {get;set;}
    
    @AuraEnabled
    public String name {get;set;}
    
    @AuraEnabled
    public DateTime createdDate {get;set;}
    
    @AuraEnabled
    public Decimal totalAmount {get;set;}
    
    @AuraEnabled
    public String accountName {get;set;}
    
    @AuraEnabled
    public String status {get;set;}
    
    @AuraEnabled
    public String orderType {get;set;}
    
    @AuraEnabled
    public String shipmentType {get;set;}
    
    @AuraEnabled
    public String paymentMethod {get;set;}
    
    @AuraEnabled
    public String orderNumber {get;set;}
    
    @AuraEnabled
    public String orderedDate {get;set;}
    
    @AuraEnabled
    public String promoCodes {get;set;}
    
    @AuraEnabled
    public String namedPlace {get;set;}

    @AuraEnabled
    public String orderSubtotal {get;set;}
    
    @AuraEnabled
    public String orderEstimatedShipping {get;set;}
    
    @AuraEnabled
    public String orderEstimatedDuty {get;set;}
    
    @AuraEnabled
    public String orderTotal {get;set;}

    @AuraEnabled
    public String promoCodesAdded {get;set;} 
    
    @AuraEnabled
    public String orderDeliveryMethod {get;set;}

}