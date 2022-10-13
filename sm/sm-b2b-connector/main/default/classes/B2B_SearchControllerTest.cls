@isTest
public with sharing class B2B_SearchControllerTest {
     
    @testSetup  
    static void  testData(){
        TestDataFactory.createData();
        
    }
    @isTest
    static void productSearchTest() 
    {
         String AccId= [select id from account where name='Test Account'].id ;
        String CommunityId='0DM8c000000sxg1';
        String SrcQuery= '{"categoryId":"0ZG8c000000kKM0GAM","refinements":[],"includeQuantityRule":true,"page":0,"pageSize":200,"grouping":{"groupingOption":"VariationParent"},"includePrices":true}';
        
        test.startTest();
        Object response= B2B_SearchController.productSearch(communityId,SrcQuery,AccId);
        system.assertnotEquals(null, response); 
        test.stopTest();
        
    }
    @isTest
    static void productSearchIterableTest() 
    {
         String AccId = [SELECT Id FROM account WHERE name = 'Test Account'].Id ;
        String CommunityId = '0DM8c000000sxg1';
        String SrcQuery = '{"categoryId":"0ZG8c000000kKM0GAM","refinements":[],"includeQuantityRule":true,"page":0,"pageSize":200,"grouping":{"groupingOption":"VariationParent"},"includePrices":true}';
        
        test.startTest();
        Object response= B2B_SearchController.productSearchIterable(communityId, SrcQuery, AccId);
        system.assertnotEquals(null, response); 
        test.stopTest();
        
    }
     @isTest
    static void ExceptionCase_productSearchTest() 
    {
        try{
        test.startTest();
        Object response= B2B_SearchController.productSearch(null,null,null);
        system.assertEquals(null, response); 
        test.stopTest();
        }
        catch(Exception e){
            
        }
    }
    @isTest
    static void getProductPricesTest(){
          String AccId= [select id from account where name='Test Account'].id ;
         String productId= [select id from product2 where StockKeepingUnit = 'TestPrinter1'].id;
          List <String> productIds= new List <String>();
        productIds.add(productId);
         String CommunityId='0DM8c000000sxg1';
         test.startTest();
        Map<String,ConnectApi.PricingResultLineItem> response= B2B_SearchController.getProductPrices(communityId,AccId,productIds);
          system.assertnotEquals(null, response); 
        test.stopTest();
        
    }
     @isTest
    static void ExceptionCase_getProductPricesTest(){
        try{
            
         test.startTest();
        B2B_SearchController.getProductPrices(null,null,null);
        
        test.stopTest();
        }catch(Exception e){
            System.assertEquals('Attempt to de-reference a null object', e.getMessage());
        }
        
    }
    @isTest
    static void getSortRuleTest(){
       
        
        String CommunityId='0DM8c000000sxg1';
        test.startTest();
        map<String, String> response = B2B_SearchController.getSortRule(communityId);
        
         system.assertEquals(null, response);  
        test.stopTest();
        
       
       }
   

}