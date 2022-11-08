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
  public static List<ProductWrapper> getFeaturedProducts() {
    List<ProductWrapper> result = new List<ProductWrapper>();
    try {
      List<Product2> products = [
        SELECT
          Id,
          Feature1__c,
          Feature3__c,
          Feature4__c,
          Feature5__c,
          Feature2__c,
          Name,
          Description,
          (
            SELECT
              Id,
              Name,
              UnitPrice,
              ProductSellingModel.Name
            FROM PricebookEntries
            WHERE IsActive = TRUE
            LIMIT 1
          )
        FROM Product2
        WHERE IsActive = TRUE AND Is_Featured_Product__c = TRUE
        ORDER BY StockKeepingUnit
      ];

      for(Product2 product : products) {
        ProductWrapper resultItem = new ProductWrapper();
        resultItem.Id = product.Id;
        resultItem.name = product.Name;
        resultItem.price = product.PricebookEntries.isEmpty() ? null : product.PricebookEntries[0].UnitPrice;
        resultItem.feature1 = product.Feature1__c;
        resultItem.feature2 = product.Feature2__c;
        resultItem.feature3 = product.Feature3__c;
        resultItem.feature4 = product.Feature4__c;
        resultItem.feature5 = product.Feature5__c;
        resultItem.sellingModalName = product.PricebookEntries.isEmpty() ? null : product.PricebookEntries[0].ProductSellingModel.Name;

        result.add(resultItem);
      }

    } catch(Exception e) {
        logger.error(e);
        throw new AuraHandledException(e.getMessage());
    } finally {
        logger.flush();
    }

    return result;
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

    public class ProductWrapper {
      @AuraEnabled
      public String Id {get;set;}
      @AuraEnabled
      public String name {get;set;}
      @AuraEnabled
      public Decimal price {get;set;}
      @AuraEnabled
      public String feature1 {get;set;}
      @AuraEnabled
      public String feature2 {get;set;}
      @AuraEnabled
      public String feature3 {get;set;}
      @AuraEnabled
      public String feature4 {get;set;}
      @AuraEnabled
      public String feature5 {get;set;}
      @AuraEnabled
      public String description {get;set;}
      @AuraEnabled
      public String sellingModalName {get;set;}
    }
}