@isTest
private class B2B_RelatedProductsHelperTest {

    @testSetup static void main(){
        TestDataFactory.createData();
    }
    static testMethod void first(){
        //Map<String, String> Data = B2BTestFactory.initialStorefrontSetup();
        String AccId= [Select id from Account where Name = 'Test Account'].Id;		//Data.get('accountId');
        String WebStoreId = [Select id,Name from WebStore where Name ='Sflabs' limit 1].id;
        String communityId=	WebStoreId;		///'0DM8c000000sxg1';
        String effectiveAccountId = AccId;
        Product2 product1 =[Select id,Name,Description from Product2 where Name='Test Product1' limit 1];
        Product2 product2 =[Select id,Name,Description from Product2 where Name='Test Product2' limit 1];
        Related_Product__c relatedProduct1 =  new Related_Product__c(
            Product__c = product2.Id, 
            Sequence__c = 1, 
            Related_Product__c = product1.Id,
            Related_Product_Relation_Type__c = 'Related', 
            Related_Product_Type__c = 'CrossSell', 
            Enabled__c = true
        );
        insert relatedProduct1;
        
       ElectronicMediaGroup emg = new ElectronicMediaGroup(); 
        emg.Name= 'Name';
        emg.DeveloperName ='DeveloperName'; 
            emg.UsageType = 'Listing';
        insert emg;
        ElectronicMediaGroup emg1 = new ElectronicMediaGroup(); 
        emg1.Name= 'Name_2';
        emg1.DeveloperName ='DeveloperName_2';
        emg1.UsageType ='Listing';
        insert emg1;
        
        ProductMedia pm = new ProductMedia();		//SELECT ElectronicMediaId, ProductId, ElectronicMediaGroupId, Id FROM ProductMedia
            pm.ProductId = product1.Id;
        pm.ElectronicMediaGroupId = emg.Id;
        pm.ElectronicMediaId = '20Y8Z000000sl9lUAA';
        //insert pm;
        ProductMedia pm2 = new ProductMedia();		//SELECT ElectronicMediaId, ProductId, ElectronicMediaGroupId, Id FROM ProductMedia
            pm2.ProductId = product2.Id;
        pm2.ElectronicMediaGroupId = emg1.Id;
        pm2.ElectronicMediaId = '20Y8Z000000sl9lUAA';
        //insert pm2;
            
       List<Related_Product__c> relatedProduct =  [Select id,Sequence__c,Related_Product__c,Related_Product_Relation_Type__c,Related_Product_Type__c,Enabled__c,Product__c, Product__r.Description, Product__r.Name from Related_Product__c where Product__c=:product1.id];
        
        Map<Id,Related_Product__c> maprelated = new Map<Id,Related_Product__c>();
        for(Related_Product__c i: relatedProduct){
            maprelated.put(i.id,i);
        }
        maprelated.put(relatedProduct1.Id, relatedProduct1);
        Map<String,Object> map_result= new Map<String,Object>(); 
        Map<String,Object> map_result2= new Map<String,Object>();
        ConnectApi.PricingInput pricingInput;
       // Set<Id> productIds= new Set<Id>();
        //productIds.
        B2B_RelatedProductsHelper.ProductDetailResponse onbj = new B2B_RelatedProductsHelper.ProductDetailResponse();
        onbj.prodImageUrl = 'prodImageUrl';
        onbj.isPriceAlreadyAvailable = true;
        onbj.isProductCompared = false;
        onbj.pricingInfo = String.valueOf('abs');
        onbj.isRecurring = true;
        Test.startTest();
		map_result = B2B_RelatedProductsHelper.getRelatedProdDetails(maprelated, communityId, effectiveAccountId);
        System.assert(map_result==null);
        Test.stopTest();
    }
}