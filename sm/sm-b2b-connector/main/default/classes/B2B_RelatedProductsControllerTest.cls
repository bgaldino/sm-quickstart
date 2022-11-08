@IsTest
private class B2B_RelatedProductsControllerTest {
  
    @TestSetup
    static void makeData(){
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            TestDataFactory.createData();
        }
    }

    @IsTest
    static void testGetRelatedProductsByProductId() {
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            Product2 product1 = [SELECT id, Name FROM Product2 WHERE Name = 'Test Product1' LIMIT 1];
            Product2 product2 = [SELECT id, Name FROM Product2 WHERE Name = 'Test Product2' LIMIT 1];
            Product2 product3 = [SELECT id, Name FROM Product2 WHERE Name = 'Test Product Add on' LIMIT 1];
            Related_Product__c relatedProduct = [SELECT id, Product__c, Product__r.Name, Product__r.Description, Sequence__c, Related_Product_Type__c, Related_Product_Relation_Type__c, Related_Product__r.Name, Related_Product__r.Description
                                                    FROM Related_Product__c WHERE Related_Product_Type__c = 'CrossSell' AND Product__c =: product1.Id LIMIT 1];
            Related_Product__c addOnProduct = [SELECT id, Product__c, Product__r.Name, Product__r.Description, Sequence__c, Related_Product_Type__c, Related_Product_Relation_Type__c, Related_Product__r.Name, Related_Product__r.Description
                                                    FROM Related_Product__c WHERE Related_Product_Type__c = 'Accessories' AND Product__c =: product1.Id LIMIT 1];
            Test.startTest();
            List<ID> checkList = new List<Id>();
            try{
                checkList = B2B_RelatedProductsController.getRelatedProductsByProductId(product1.Id);
            }catch(Exception ex){
                ex.getMessage();
            }
            System.assertEquals(null, checkList);
            test.stopTest();
        }
    }
    
    @IsTest
    static void testGetRelatedProductsWithCategoriesByProductId() {
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            Product2 product1 = [SELECT id, Name FROM Product2 WHERE Name = 'Test Product1' LIMIT 1];
            Product2 product2 = [SELECT id, Name FROM Product2 WHERE Name = 'Test Product2' LIMIT 1];
            Product2 product3 = [SELECT id, Name FROM Product2 WHERE Name = 'Test Product Add on' LIMIT 1];
            Related_Product__c relatedProduct = [SELECT id, Product__c, Product__r.Name, Product__r.Description, Sequence__c, Related_Product_Type__c, Related_Product_Relation_Type__c, Related_Product__r.Name, Related_Product__r.Description
                                                    FROM Related_Product__c WHERE Related_Product_Type__c = 'CrossSell' AND Product__c =: product1.Id LIMIT 1];
            Related_Product__c addOnProduct = [SELECT id, Product__c, Product__r.Name, Product__r.Description, Sequence__c, Related_Product_Type__c, Related_Product_Relation_Type__c, Related_Product__r.Name, Related_Product__r.Description
                                                    FROM Related_Product__c WHERE Related_Product_Type__c = 'Accessories' AND Product__c =: product1.Id LIMIT 1];
            Test.startTest();
            Map<Id, Id> checkList = new Map<Id, Id>();
            try{
                checkList = B2B_RelatedProductsController.getRelatedProductsWithCategoriesByProductId(product1.Id);
            }catch(Exception ex){
                ex.getMessage();
            }
            System.assertEquals(null, checkList);
            test.stopTest();
        }
    }

    @IsTest
    static void testgetAddOnProductsByProductId() {
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            Product2 product1 = [SELECT id, Name FROM Product2 WHERE Name = 'Test Product1' LIMIT 1];
            Product2 product2 = [SELECT id, Name FROM Product2 WHERE Name = 'Test Product2' LIMIT 1];
            Product2 product3 = [SELECT id, Name FROM Product2 WHERE Name = 'Test Product Add on' LIMIT 1];
            Related_Product__c relatedProduct = [SELECT id, Product__c, Product__r.Name, Product__r.Description, Sequence__c, Related_Product_Type__c, Related_Product_Relation_Type__c, Related_Product__r.Name, Related_Product__r.Description
                                                    FROM Related_Product__c WHERE Related_Product_Type__c = 'CrossSell' AND Product__c =: product1.Id LIMIT 1];
            Related_Product__c addOnProduct = [SELECT id, Product__c, Product__r.Name, Product__r.Description, Sequence__c, Related_Product_Type__c, Related_Product_Relation_Type__c, Related_Product__r.Name, Related_Product__r.Description
                                                    FROM Related_Product__c WHERE Related_Product_Type__c = 'Accessories' AND Product__c =: product1.Id LIMIT 1];
            Test.startTest();
            List<ID> checkList = new List<Id>();
            try{
                checkList = B2B_RelatedProductsController.getAddOnProductsByProductId(product1.Id);
            }catch(Exception ex){
                ex.getMessage();
            }
            System.assertEquals(null, checkList);
            test.stopTest();
        }
    }
    
    @IsTest
    static void testGetAddOnProductsCategoryIdsByProductId() {
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            Product2 product1 = [SELECT id, Name FROM Product2 WHERE Name = 'Test Product1' LIMIT 1];
            Product2 product2 = [SELECT id, Name FROM Product2 WHERE Name = 'Test Product2' LIMIT 1];
            Product2 product3 = [SELECT id, Name FROM Product2 WHERE Name = 'Test Product Add on' LIMIT 1];
            Related_Product__c relatedProduct = [SELECT id, Product__c, Product__r.Name, Product__r.Description, Sequence__c, Related_Product_Type__c, Related_Product_Relation_Type__c, Related_Product__r.Name, Related_Product__r.Description
                                                    FROM Related_Product__c WHERE Related_Product_Type__c = 'CrossSell' AND Product__c =: product1.Id LIMIT 1];
            Related_Product__c addOnProduct = [SELECT id, Product__c, Product__r.Name, Product__r.Description, Sequence__c, Related_Product_Type__c, Related_Product_Relation_Type__c, Related_Product__r.Name, Related_Product__r.Description
                                                    FROM Related_Product__c WHERE Related_Product_Type__c = 'Accessories' AND Product__c =: product1.Id LIMIT 1];
            Test.startTest();
            Map<Id, Id> checkList = new Map<Id, Id>();
            try{
                checkList = B2B_RelatedProductsController.getAddOnProductsCategoryIdsByProductId(product1.Id);
            }catch(Exception ex){
                ex.getMessage();
            }
            System.assertEquals(null, checkList);
            test.stopTest();
        }
    }
    
    @IsTest
    static void testGetAddOnProductsByProductList() {
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            Product2 product1 = [SELECT id, Name FROM Product2 WHERE Name = 'Test Product1' LIMIT 1];
            Product2 product2 = [SELECT id, Name FROM Product2 WHERE Name = 'Test Product2' LIMIT 1];
            Product2 product3 = [SELECT id, Name FROM Product2 WHERE Name = 'Test Product Add on' LIMIT 1];
            List<String> productIds = new List<String> {product1.Id, product2.Id, product3.Id};
            Related_Product__c relatedProduct = [SELECT id, Product__c, Product__r.Name, Product__r.Description, Sequence__c, Related_Product_Type__c, Related_Product_Relation_Type__c, Related_Product__r.Name, Related_Product__r.Description
                                                    FROM Related_Product__c WHERE Related_Product_Type__c = 'CrossSell' AND Product__c =: product1.Id LIMIT 1];
            Related_Product__c addOnProduct = [SELECT id, Product__c, Product__r.Name, Product__r.Description, Sequence__c, Related_Product_Type__c, Related_Product_Relation_Type__c, Related_Product__r.Name, Related_Product__r.Description
                                                    FROM Related_Product__c WHERE Related_Product_Type__c = 'Accessories' AND Product__c =: product1.Id LIMIT 1];
            Test.startTest();
            List<ID> checkList = new List<Id>();
            try{
                checkList = B2B_RelatedProductsController.getAddOnProductsByProductList(productIds);
            }catch(Exception ex){
                ex.getMessage();
            }
            System.assertEquals(null, checkList);
            test.stopTest();
        }
    }
    
    @IsTest
    static void testGetAddOnProductsWithCategoriesByProductList() {
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            Product2 product1 = [SELECT id, Name FROM Product2 WHERE Name = 'Test Product1' LIMIT 1];
            Product2 product2 = [SELECT id, Name FROM Product2 WHERE Name = 'Test Product2' LIMIT 1];
            Product2 product3 = [SELECT id, Name FROM Product2 WHERE Name = 'Test Product Add on' LIMIT 1];
            List<String> productIds = new List<String> {product1.Id, product2.Id, product3.Id};
            Related_Product__c relatedProduct = [SELECT id, Product__c, Product__r.Name, Product__r.Description, Sequence__c, Related_Product_Type__c, Related_Product_Relation_Type__c, Related_Product__r.Name, Related_Product__r.Description
                                                    FROM Related_Product__c WHERE Related_Product_Type__c = 'CrossSell' AND Product__c =: product1.Id LIMIT 1];
            Related_Product__c addOnProduct = [SELECT id, Product__c, Product__r.Name, Product__r.Description, Sequence__c, Related_Product_Type__c, Related_Product_Relation_Type__c, Related_Product__r.Name, Related_Product__r.Description
                                                    FROM Related_Product__c WHERE Related_Product_Type__c = 'Accessories' AND Product__c =: product1.Id LIMIT 1];
            Test.startTest();
            Map<Id, Id> checkList = new Map<Id, Id>();
            try{
                checkList = B2B_RelatedProductsController.getAddOnProductsWithCategoriesByProductList(productIds);
            }catch(Exception ex){
                ex.getMessage();
            }
            System.assertEquals(null, checkList);
            test.stopTest();
        }
    }

    @IsTest
    static void failGetRelatedProductsByProductId() {
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            Account accountTest = [SELECT id, Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Product2 product2 = [SELECT id, Name FROM Product2 WHERE Name = 'Test Product2' LIMIT 1];
            Test.startTest();
            List<ID> checkList = new List<Id>();
            try{
                checkList = B2B_RelatedProductsController.getRelatedProductsByProductId(accountTest.Id);
                checkList = B2B_RelatedProductsController.getAddOnProductsByProductId(accountTest.Id);
            }catch(Exception ex){
                ex.getMessage();       
            }
            System.assertEquals(null, checkList);
            test.stopTest();
        }
    }

    @IsTest
    static void testGetRelatedPrice() {
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            Product2 product1 = [SELECT id, Name FROM Product2 WHERE Name = 'Test Product1' LIMIT 1];
            List<String> productIds = new List<String> {product1.Id};
            PricebookEntry product1Entry = [SELECT id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id =: product1.Id LIMIT 1];
            Test.startTest();
            Map<Id, Decimal> checkList = new Map<Id, Decimal>();
            try{
                checkList = B2B_RelatedProductsController.getProductPrices(productIds);
            }catch(Exception ex){
                ex.getMessage();            
            }
            System.assertEquals(checkList.size(), 1);
            test.stopTest();
        }
    }

    @IsTest
    static void failGetRelatedPrice() {
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            Product2 product1 = [SELECT id, Name FROM Product2 WHERE Name = 'Test Product1' LIMIT 1];
            Account accountTest = [SELECT id, Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            List<String> productIds = new List<String> {accountTest.Id};
            //PricebookEntry product1Entry = [SELECT id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id =: product1.Id LIMIT 1];
            Test.startTest();
            Map<Id, Decimal> checkList = new Map<Id, Decimal>();
            try{
                checkList = B2B_RelatedProductsController.getProductPrices(productIds);
            }catch(Exception ex){
                ex.getMessage();            
            }
            System.assertEquals(checkList.size(), 0);
            test.stopTest();
        }
    }
}