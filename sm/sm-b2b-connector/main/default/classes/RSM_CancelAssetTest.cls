@isTest
public with sharing class RSM_CancelAssetTest 
{
     @testSetup  
    static void  testData(){
        TestDataFactory.createData();
        
    }
    @isTest
    static void getNextBillingDateTest(){
         map<string, object> Result = new  map<string, object>();
      String accId =[select id from Account where name='Test Account'].id ;
       
       String asseId= [select id from Asset where AccountId=:accId].id;
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new RSM_cancelAssetTestMock());  
                   
         map<string, object> getNextBillingDate= RSM_cancelAsset.getNextBillingDate(asseId);
         system.assertEquals(Result,getNextBillingDate);
         Test.stopTest();
        }
    
     @isTest
    static void ExceptionCase_getNextBillingDateTest(){
        Try
        {
             Test.startTest();
           map<string, object> getNextBillingDate= RSM_cancelAsset.getNextBillingDate(null);
              Test.stopTest();
        }
        catch(Exception e)
        { system.assertEquals('Exception',e.getMessage()); }
                   
       
       
        }
    @isTest
    static void cancelAssetTest(){
      String accId =[select id from Account where name='Test Account'].id ;
        User u =[Select id from user where firstname ='ABCD'];
       String asseId= [select id from Asset where AccountId=:accId].id;
         /*StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('CancelAsset');

        // The web service call returns an error code.
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Test.startTest();
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class, mock);
*/       System.runAs(u) {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new RSM_cancelAssetTestMock());  
    map<string, object> cancelAsset= RSM_cancelAsset.cancelAsset(asseId);
    system.assertNotEquals(null,cancelAsset); 
    Test.stopTest();
}}
      @isTest
    static void ExceptionCase_cancelAssetTest(){
        Try
        {
            Test.startTest();
          map<string, object> cancelAsset= RSM_cancelAsset.cancelAsset(null);
             Test.stopTest();
        }
        catch(Exception e)
        { system.assertEquals('Script-thrown exception',e.getMessage()); }
                   
       
        
        }
   
    }