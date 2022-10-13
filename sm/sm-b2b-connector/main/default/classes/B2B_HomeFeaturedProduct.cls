/**
 * @description       : Feature Products are shown on the home page. User can mark a Product as feature Product to show on the home page.
 * @author            : Prabhat Kumar
 * @group             : 
 * @last modified on  : 05-20-2022
 * @last modified by  : Prabhat Kumar
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   05-20-2022   Prabhat Kumar  Initial Version
**/
global without sharing class B2B_HomeFeaturedProduct {

  private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.FEATURE_PRODUCTS);

/**
 * Retrieve the Featured Product and display on the home page.
 * 
**/  
  @AuraEnabled
  global static List<Product2> getFeaturedProducts() {
    List<Product2> products = new List<Product2>();
    try {
      Set<Id> productIds = new Set<Id>();
      products = [
        SELECT
          Id,
          Feature1__c,
          Feature3__c,
          Feature4__c,
          Feature5__c,
          Feature2__c,
          Name,
          ProductCode,
          CurrencyIsoCode,
          StockKeepingUnit,
          Family,
          Description,
          (
            SELECT
              Id,
              Name,
              UnitPrice,
              Pricebook2Id,
              ProductSellingModelId,
              ProductSellingModel.Name,
              ProductSellingModel.PricingTerm,
              ProductSellingModel.PricingTermUnit,
              ProductSellingModel.SellingModelType
            FROM PricebookEntries
            WHERE IsActive = TRUE
          )
        FROM Product2
        WHERE IsActive = TRUE AND Is_Featured_Product__c = TRUE
        ORDER BY StockKeepingUnit
      ];

    } catch(Exception e) {
        logger.error(e);
        throw new AuraHandledException(e.getMessage());
    } finally {
        logger.flush();
    }

    return products;
  }

  /**
 * Retrieve the Product Price.
 * 
**/  
  @AuraEnabled
  global static Decimal getProductPrice(String productId) {
    PricebookEntry prices = new PricebookEntry();
    try{
     prices = [
      SELECT id, UnitPrice
      FROM PricebookEntry
      WHERE Product2Id = :productId
      LIMIT 1
    ];
    } catch(Exception e) {
        logger.error(e);
        throw new AuraHandledException(e.getMessage());
    } finally {
        logger.flush();
    }
    return prices.UnitPrice;
  }
    
    public class ProductDetailResponse{
        @AuraEnabled
        public String prodName{get;set;}
        @AuraEnabled
        public String prodId{get;set;}
        @AuraEnabled
        public String prodDescription{get;set;}
        @AuraEnabled
        public String prodImageUrl{get;set;}
        @AuraEnabled
        public Boolean isPriceAlreadyAvailable{get;set;}
        @AuraEnabled
        public Boolean isProductCompared{get;set;}
        @AuraEnabled
        public Object pricingInfo{get;set;}
        @AuraEnabled
        public Boolean isRecurring{get;set;}
        @AuraEnabled
        public String pricebookEntryId{get;set;}
        @AuraEnabled
        public String unitPrice{get;set;}
        @AuraEnabled
        public String listPrice{get;set;}
        
    }
}