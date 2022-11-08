public without sharing class B2B_RelatedProductsHelper {
    
    public static Map<String, Object> getRelatedProdDetails(Map<Id,Related_Product__c> relatedProductsMap,String communityId,String effectiveAccountId){
        Map<String, Object> response = new Map<String, Object>();
        try{
         String webStoreId;
        if(Test.isRunningTest()){
            webStoreId = '';
            WebStore wstore = [SELECT Id FROM WebStore WHERE Name ='Sflabs' LIMIT 1];
            webStoreId = wstore.Id;
        }else{
            webStoreId = [
                SELECT WebStoreId
                FROM WebStoreNetwork
                WHERE NetworkId = :communityId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ].WebStoreId;
        }
            ConnectApi.PricingInput pricingInput = new  ConnectApi.PricingInput();
            List<ConnectApi.PricingLineItemInput> inputs = new List<ConnectApi.PricingLineItemInput>();
            Map<String,ConnectApi.PricingResultLineItem> productToPriceMap = new Map<String,ConnectApi.PricingResultLineItem>();
             for(ID id : relatedProductsMap.keySet()){
                 Related_Product__c prod = relatedProductsMap.get(id);
                 ConnectApi.PricingLineItemInput input = new ConnectApi.PricingLineItemInput();
                 input.productId= (String)prod.Related_Product__c;
                inputs.add(input);
            }
            pricingInput.pricingLineItems = inputs;
            ConnectApi.PricingResult pricing;
            List<ConnectApi.PricingResultLineItem> prLine= new List<ConnectApi.PricingResultLineItem>();

            if(!Test.isRunningTest()){
             pricing  = ConnectApi.CommerceStorePricing.getProductPrices( 
                webstoreId,
                effectiveAccountId, 
                pricingInput
            );
            }
           
            else{
                Product2 demo = [Select id, Name, Description from Product2 where Name='Test Product1' limit 1];
                ConnectApi.PricingResultLineItem prli = new ConnectApi.PricingResultLineItem();
                prli.listPrice = '100';
                prli.pricebookEntryId ='pricebookEntryId';
                prli.productId = demo.id;
                prLine.add(prli);
                Product2 demo2 = [Select id, Name, Description from Product2 where Name='Test Product2' limit 1];
                ConnectApi.PricingResultLineItem prli2 = new ConnectApi.PricingResultLineItem();
                prli2.listPrice = '100';
                prli2.pricebookEntryId ='pricebookEntryId2';
                prli2.productId = demo2.id;
                prLine.add(prli2);
                
                ConnectApi.PricingResult dummyPr = new ConnectApi.PricingResult();
                dummyPr.currencyIsoCode = 'USD';
                dummyPr.pricingLineItemResults	= prLine;
                pricing = dummyPr;
                
            }

             for(ConnectApi.PricingResultLineItem priceLineItem :pricing.pricingLineItemResults){
                 System.debug('priceLineItem--'+priceLineItem);
                 Id product18Id =priceLineItem.productId; 
                 productToPriceMap.put(product18Id,priceLineItem);
             }
             System.debug('productToPriceMap--'+productToPriceMap);
            response.put('webstoreId',webstoreId);
            response.put('effectiveAccountId',effectiveAccountId);

            B2B_Related_Product_Type__mdt[] relatedProdTxt = [select id,MasterLabel,QualifiedApiName,Related_Product_Type__c,UI_Text__c from B2B_Related_Product_Type__mdt];
            Map<String,List<ProductDetailResponse>> prodMap = new Map<String,List<ProductDetailResponse>>();
            Set<Id> prodIdSet = new Set<Id>();
            if(relatedProductsMap != null && !relatedProductsMap.isEmpty()){
                for(Id prodId: relatedProductsMap.keySet()){
                    Related_Product__c prod = relatedProductsMap.get(prodId);
                    prodIdSet.add(prod.Product__c);
                    if(relatedProdTxt != null && relatedProdTxt.size()>0){
                        for(B2B_Related_Product_Type__mdt uiTxt: relatedProdTxt){
                            if(uiTxt.Related_Product_Type__c == prod.Related_Product_Type__c){
                                prod.Related_Product_Type__c = uiTxt.UI_Text__c;
                            }
                            
                        }
                    }
                    
                }
                Map<String, String> productImages = getProdImages(prodIdSet);
                
                for(Id prodId: relatedProductsMap.keySet()){
                    system.debug('*** prodId' + JSON.serialize(prodId) );
                    Related_Product__c prod = relatedProductsMap.get(prodId);

                    if(prodMap != null || !prodMap.isEmpty()){
                        for(String prodRelationType : prodMap.keySet()){
                            
                            ProductDetailResponse res = new ProductDetailResponse();

                            if(productToPriceMap.containsKey(prod.Product__c)){
                                System.debug('productToPriceMap--'+productToPriceMap);
                                ConnectApi.PricingResultLineItem productPrice =  productToPriceMap.get(prod.Product__c);
                                system.debug('test123 productPrice' + productPrice);
                                res.pricebookEntryId = productPrice.pricebookEntryId;
                                res.unitPrice = productPrice.unitPrice ;
                                res.listPrice = productPrice.listPrice;
                            }
                            System.debug('res--' + res);
                            if(prodMap.containsKey(prod.Related_Product_Type__c) && prod.Related_Product_Type__c == prodRelationType){
                                List<ProductDetailResponse> prodLstVal = prodMap.get(prod.Related_Product_Type__c);

                                System.debug('** &&' + prod.Product__r.Name);
                                res.prodName = prod.Product__r.Name;
                                res.prodDescription = prod.Product__r.Description;
                                res.prodId = prod.Product__c;
                                System.debug('** productImages.get(prod.Product__c)' + String.valueOf(Url.getOrgDomainUrl().toExternalForm()) + '/' + productImages.get(prod.Product__c)); 
                                res.prodImageUrl = productImages.get(prod.Product__c).indexOf('https') ==-1? String.valueOf(Url.getOrgDomainUrl().toExternalForm()) + '/' + productImages.get(prod.Product__c) : productImages.get(prod.Product__c);
                            
                                prodLstVal.add(res);
                                prodMap.put(prod.Related_Product_Type__c,prodLstVal);
                            }
                            if(!prodMap.containsKey(prod.Related_Product_Type__c)){
                                List<ProductDetailResponse> relProd = new List<ProductDetailResponse>();
                                System.debug('** name' + prod.Product__r.Name);
                                System.debug('** decsr' + prod.Product__r.Description);
                                res.prodName = prod.Product__r.Name;
                                res.prodDescription = prod.Product__r.Description;
                                res.prodId = prod.Product__c;
                                res.prodImageUrl = productImages.get(prod.Product__c).indexOf('https') ==-1? String.valueOf(Url.getOrgDomainUrl().toExternalForm()) + '/' + productImages.get(prod.Product__c) : productImages.get(prod.Product__c);
                                res.isRecurring = true;
                                relProd.add(res);
                                System.debug('** relProd' + relProd);
                                prodMap.put(prod.Related_Product_Type__c,relProd);
                            } 
                        }
                    } 
                    if(prodMap == null ||  prodMap.isEmpty()){
                        List<ProductDetailResponse> relProd = new List<ProductDetailResponse>();
                        ProductDetailResponse res = new ProductDetailResponse();
                        if(productToPriceMap.containsKey(prod.Product__c)){
                            System.debug('*** productToPriceMap--'+ productToPriceMap);
                            ConnectApi.PricingResultLineItem productPrice =  productToPriceMap.get(prod.Product__c);
                            system.debug('<<teset' + productPrice);
                            res.pricebookEntryId = productPrice.pricebookEntryId;
                            res.unitPrice = productPrice.unitPrice ;
                            res.listPrice = productPrice.listPrice;
                        }
                        System.debug('prod----- '+prod);
                        res.prodName = prod.Product__r.Name;
                        res.prodDescription = prod.Product__r.Description;
                        res.prodId = prod.Product__c;
                        system.debug('test>><<' + productImages);
                        if(productImages.containsKey(prod.Product__c)){

                             res.prodImageUrl =  productImages.get(prod.Product__c).indexOf('https') ==-1? String.valueOf(Url.getOrgDomainUrl().toExternalForm()) + '/'/*cms/spaces/0Zu8c000000oacnCAA/content/'*/+ productImages.get(prod.Product__c) : productImages.get(prod.Product__c);
                        }
                      
                        relProd.add(res);
                        prodMap.put(prod.Related_Product_Type__c,relProd);
                        system.debug('test>>11 prodMap ' + prodMap);
                    }
                }
            }
            List<ProductDetailResponse> prodLstVal =  new List<ProductDetailResponse>();
            if(prodMap != null || !prodMap.isEmpty()){
                for(List<ProductDetailResponse> productLst:prodMap.values()){
                    prodLstVal.addAll(productLst);
                }
            }
            response.put('productLst',prodLstVal);
            response.put('totalCount',prodMap.values().size());
            response.put('productsByRelationType',prodMap);
            
            return response; 
        }
        catch(Exception e){
            system.debug('Exception While getting related product details in helper'+e.getMessage());
            return null;
        }
        
    }

    public static Map<String, String> getProdImages(Set<Id> productIds){
        Map<String, String> productImageUrlsByProductIds = new Map<String, String>();
        try{
        List<ProductMedia> prodMedia =
                [
                    SELECT Id, ElectronicMediaId,
                    ProductId
                    FROM ProductMedia
                    WHERE ProductId IN :productIds
                    ORDER BY SortOrder
                ];

            if (prodMedia != null && prodMedia.size() > 0) {
                for (ProductMedia p : prodMedia) {
                    productImageUrlsByProductIds.put(p.ProductId, p.ElectronicMediaId);
                }
            } 
          
            system.debug('*** productImageUrlsByProductIds' + productImageUrlsByProductIds);
        }catch(Exception e){
            system.debug('Exception while getting product images'+e.getMessage());
        }
        return productImageUrlsByProductIds;
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