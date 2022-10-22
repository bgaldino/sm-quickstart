/**
 * @description       : 
 * @author            : Prabhat Kumar
 * @group             : 
 * @last modified on  : 05-20-2022
 * @last modified by  : Prabhat Kumar
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   05-20-2022   Prabhat Kumar  Initial Version
**/

public with sharing class RSM_SubscriptionsWrapper {
    @AuraEnabled
    public String productId { get; set; }

    @AuraEnabled
    public String assetId { get; set; }

    @AuraEnabled 
    public Product2 product { get; set; }
    
    @AuraEnabled 
    public Asset asset { get; set; }

    @AuraEnabled 
    public String imageUrl { get; set; }

    @AuraEnabled 
    public AssetStatePeriod assetperiod { get; set; }
    
    @AuraEnabled 
    public Boolean isOneTime { get; set; }

    @AuraEnabled
    public Boolean isEverGreen { get; set; }

    @AuraEnabled
    public Boolean isTermed { get; set; }

    @AuraEnabled
    public string assetType { get; set; }

    
    @AuraEnabled
    public Boolean isCancelled { get; set; }

}