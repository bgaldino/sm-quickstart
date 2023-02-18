public with sharing class B2B_RelatedProductsController {
    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.CHECKOUT_FLOW);

    public static List<String> relatedType = new List<String>{'CrossSell', 'UpSell'};
    public static String addOnType = 'Accessories';

    @AuraEnabled
    public static List<Id> getRelatedProductsByProductId(Id productId){
        try{
            List<Related_Product__c> relatedProductsMap = [SELECT id, Product__c, Product__r.Name, Product__r.Description, Sequence__c, Related_Product_Type__c, Related_Product_Relation_Type__c, Related_Product__r.Name, Related_Product__r.Description
                                                                     FROM Related_Product__c WHERE Related_Product_Type__c in: relatedType AND Product__c =: productId WITH SECURITY_ENFORCED];
            List<Id> ids = new List<Id>();
            for(Related_Product__c relatedProduct : relatedProductsMap){
                ids.add(relatedProduct.Related_Product__c);
            }
            return ids; 
        } catch (Exception ex) {
            logger.error(ex);
            return null;
        } finally {
            logger.flush();
        }

    }
    @AuraEnabled
    public static Map<Id, Id> getRelatedProductsWithCategoriesByProductId(Id productId){
        try{
            List<Related_Product__c> relatedProductsMap = [SELECT id, Product__c, Product__r.Name, Product__r.Description, Sequence__c, Related_Product_Type__c, Related_Product_Relation_Type__c, Related_Product__r.Name, Related_Product__r.Description
                                                                     FROM Related_Product__c WHERE Related_Product_Type__c in: relatedType AND Product__c =: productId WITH SECURITY_ENFORCED];
            List<Id> ids = new List<Id>();
            for(Related_Product__c relatedProduct : relatedProductsMap){
                ids.add(relatedProduct.Related_Product__c);
            }

            Map<Id, Id> result = new Map<Id, Id>();
            for(ProductCategoryProduct category : [SELECT ProductCategoryId, ProductId FROM ProductCategoryProduct WHERE ProductId IN :ids WITH SECURITY_ENFORCED]) {
                result.put(category.ProductId, category.ProductCategoryId);
            }
            
            return result;
        } catch (Exception ex) {
            logger.error(ex);
            return null;
        } finally {
            logger.flush();
        }

    }
    @AuraEnabled
    public static List<Id> getAddOnProductsByProductId(Id productId){
        try{
            List<Related_Product__c> relatedProductsMap = [SELECT id, Product__c, Product__r.Name, Product__r.Description, Sequence__c, Related_Product_Type__c, Related_Product_Relation_Type__c, Related_Product__r.Name, Related_Product__r.Description
                                                                     FROM Related_Product__c WHERE Related_Product_Type__c =: addOnType AND Product__c =: productId WITH SECURITY_ENFORCED];
            List<Id> ids = new List<Id>();
            for(Related_Product__c relatedProduct : relatedProductsMap){
                ids.add(relatedProduct.Related_Product__c);
            }
            return ids; 
        } catch (Exception ex) {
            logger.error(ex);
            return null;
        } finally {
            logger.flush();
        }
    }

    @AuraEnabled
    public static Map<Id, Id> getAddOnProductsCategoryIdsByProductId(Id productId){
        try{
            List<Related_Product__c> relatedProductsMap = [SELECT id, Product__c, Product__r.Name, Product__r.Description, Sequence__c, Related_Product_Type__c, Related_Product_Relation_Type__c, Related_Product__r.Name, Related_Product__r.Description
                                                                     FROM Related_Product__c WHERE Related_Product_Type__c =: addOnType AND Product__c =: productId WITH SECURITY_ENFORCED];
            List<Id> ids = new List<Id>();
            for(Related_Product__c relatedProduct : relatedProductsMap){
                ids.add(relatedProduct.Related_Product__c);
            }

            Map<Id, Id> result = new Map<Id, Id>();
            for(ProductCategoryProduct category : [SELECT ProductCategoryId, ProductId FROM ProductCategoryProduct WHERE ProductId IN :ids WITH SECURITY_ENFORCED]) {
                result.put(category.ProductId, category.ProductCategoryId);
            }
            
            return result;
        } catch (Exception ex) {
            logger.error(ex);
            return null;
        } finally {
            logger.flush();
        }
    }

    @AuraEnabled
    public static List<Id> getAddOnProductsByProductList(List<String> productIds){
        try{
            List<Related_Product__c> relatedProductsMap = [SELECT id, Product__c, Product__r.Name, Product__r.Description, Sequence__c, Related_Product_Type__c, Related_Product_Relation_Type__c, Related_Product__r.Name, Related_Product__r.Description
                                                                     FROM Related_Product__c WHERE Related_Product_Type__c =: addOnType AND Product__c in: productIds WITH SECURITY_ENFORCED];
            List<Id> ids = new List<Id>();
            for(Related_Product__c relatedProduct : relatedProductsMap){
                ids.add(relatedProduct.Related_Product__c);
            }
            return ids; 
        } catch (Exception ex) {
            logger.error(ex);
            return null;
        } finally {
            logger.flush();
        }
    }
    @AuraEnabled
    public static Map<Id, Id> getAddOnProductsWithCategoriesByProductList(List<String> productIds){
        try{
            List<Related_Product__c> relatedProductsMap = [SELECT id, Product__c, Product__r.Name, Product__r.Description, Sequence__c, Related_Product_Type__c, Related_Product_Relation_Type__c, Related_Product__r.Name, Related_Product__r.Description
                                                                     FROM Related_Product__c WHERE Related_Product_Type__c =: addOnType AND Product__c in: productIds WITH SECURITY_ENFORCED];
            List<Id> ids = new List<Id>();
            for(Related_Product__c relatedProduct : relatedProductsMap){
                ids.add(relatedProduct.Related_Product__c);
            }

            Map<Id, Id> result = new Map<Id, Id>();
            for(ProductCategoryProduct category : [SELECT ProductCategoryId, ProductId FROM ProductCategoryProduct WHERE ProductId IN :ids WITH SECURITY_ENFORCED]) {
                result.put(category.ProductId, category.ProductCategoryId);
            }
            
            return result;
        } catch (Exception ex) {
            logger.error(ex);
            return null;
        } finally {
            logger.flush();
        }
    }

    @AuraEnabled
    public static Map<Id, Decimal> getProductPrices(List<String> productId) {
        try{
            Map<Id, Decimal> productPrice = new  Map<Id, Decimal>();
            List<PricebookEntry> prices = [SELECT id, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id in: productId WITH SECURITY_ENFORCED];
            for(PricebookEntry entry: prices){
                productPrice.put(entry.Product2Id, entry.UnitPrice);
            }
            return productPrice;
        } catch (Exception ex) {
            logger.error(ex);
            return null;
        } finally {
            logger.flush();
        }
    }
}