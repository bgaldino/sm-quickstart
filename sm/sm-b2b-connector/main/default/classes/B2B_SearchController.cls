global without sharing class B2B_SearchController {
    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.CHECKOUT_FLOW);

    private static Decimal apiVersionApexClass = [SELECT ApiVersion FROM ApexClass WHERE Name = 'B2B_SearchController' LIMIT 1].ApiVersion;

    @AuraEnabled
    global static Object productSearch(
        String communityId,
        String searchQuery,
        String effectiveAccountId
    ) {
        String webstoreId ;
        if(!Test.isRunningTest()){
            webStoreId = [SELECT WebStoreId FROM WebStoreNetwork 
                          WHERE NetworkId = :communityId
                          WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
        }else{
            webStoreId = [Select id from webStore where Name = 'Sflabs' limit 1].Id;
        }
        ConnectApi.ProductSearchResults searchProducts;
        Object response;
        try {
            ConnectApi.ProductSearchInput searchInput = new ConnectApi.ProductSearchInput();
            Map<String,Object> searchQueryMap = (Map<String,Object>)JSON.deserializeUntyped(searchQuery);
            String categoryId = B2BUtils.fetchConfigByValue('CategoryId');
            searchQueryMap.put('categoryId', categoryId);
            String JSONSearch = JSON.serialize(searchQueryMap);
            JSONParser parser = JSON.createParser(JSONSearch);
            while(parser.nextToken() != null){
                if(parser.getCurrentToken() == JSONToken.START_OBJECT){
                    searchInput = (ConnectApi.ProductSearchInput) parser.readValueAs(ConnectApi.ProductSearchInput.class);
                }    
            }
            if(!Test.isRunningTest()){
                response =  ConnectApi.CommerceSearch.searchProducts( webstoreId, effectiveAccountId, searchInput);
            }else{
                ConnectApi.ProductSearchResults  psr = new ConnectApi.ProductSearchResults();
                psr.correlationId = 'correlationId';
                psr.locale = 'locale';
                response = psr;
            }
        } catch (Exception ex) {
            logger.error(ex);
        } finally {
            logger.flush();
        }

        return response;
    }

    @AuraEnabled
    global static Object productSearchIterable(
        String communityId,
        String searchQuery,
        String effectiveAccountId
    ) {
        String webstoreId ;
        if(!Test.isRunningTest()){
            webStoreId = [SELECT WebStoreId FROM WebStoreNetwork 
                          WHERE NetworkId = :communityId
                          WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
        }else{
            webStoreId = [Select id from webStore where Name = 'Sflabs' limit 1].Id;
        }
        ConnectApi.ProductSearchResults searchProducts;
        Object response;
        try {
            ConnectApi.ProductSearchInput searchInput = new ConnectApi.ProductSearchInput();
            Map<String,Object> searchQueryMap = (Map<String,Object>)JSON.deserializeUntyped(searchQuery);

            String JSONSearch = JSON.serialize(searchQueryMap);
            JSONParser parser = JSON.createParser(JSONSearch);
            while(parser.nextToken() != null){
                if(parser.getCurrentToken() == JSONToken.START_OBJECT){
                    searchInput = (ConnectApi.ProductSearchInput) parser.readValueAs(ConnectApi.ProductSearchInput.class);
                }    
            }
            if(!Test.isRunningTest()){
                response =  ConnectApi.CommerceSearch.searchProducts( webstoreId, effectiveAccountId, searchInput);
            }else{
                ConnectApi.ProductSearchResults  psr = new ConnectApi.ProductSearchResults();
                psr.correlationId = 'correlationId';
                psr.locale = 'locale';
                response = psr;
            }
        } catch (Exception ex) {
            logger.error(ex);
        } finally {
            logger.flush();
        }

        return response;
    }

    @AuraEnabled 
    global static Map<String,ConnectApi.PricingResultLineItem> getProductPrices(
        String communityId,
        String effectiveAccountId,
        List<String> productIds
    ) {
        Map<String,ConnectApi.PricingResultLineItem> productToPriceMap = new Map<String,ConnectApi.PricingResultLineItem>();
        try{
            String webstoreId ;
            if(!Test.isRunningTest()){
                webstoreId = [SELECT WebStoreId FROM WebStoreNetwork 
                              WHERE NetworkId = :communityId 
                              WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
            }else{
                webStoreId = [Select id from webStore where Name = 'Sflabs' limit 1].Id;
            }
            ConnectApi.PricingInput pricingInput = new  ConnectApi.PricingInput();
            List<ConnectApi.PricingLineItemInput> inputs = new List<ConnectApi.PricingLineItemInput>();
            for(String id : productIds){
                ConnectApi.PricingLineItemInput input = new ConnectApi.PricingLineItemInput();
                input.productId = id;
                inputs.add(input);
            }
            pricingInput.pricingLineItems = inputs;
            ConnectApi.PricingResult pricing;
            List<ConnectApi.PricingResultLineItem> prLine= new List<ConnectApi.PricingResultLineItem>();
            if(!test.isRunningTest()){
                pricing = ConnectApi.CommerceStorePricing.getProductPrices(
                    webstoreId,
                    effectiveAccountId,
                    pricingInput
                );
            }else{
                ConnectApi.PricingResultLineItem prli = new ConnectApi.PricingResultLineItem();
                prli.listPrice = '100';
                prli.pricebookEntryId ='pricebookEntryId';
                prli.productId = productIds[0];
                prLine.add(prli);
                ConnectApi.PricingResult dummyPr = new ConnectApi.PricingResult();
                dummyPr.currencyIsoCode = 'USD';
                dummyPr.pricingLineItemResults  = prLine;
                pricing = dummyPr;
            }
            for(ConnectApi.PricingResultLineItem priceLineItem : pricing.pricingLineItemResults){
                System.debug('priceLineItem--'+priceLineItem);
                Id product18Id = priceLineItem.productId; 
                productToPriceMap.put(product18Id, priceLineItem);
            }
            System.debug('productToPriceMap--'+productToPriceMap);

            return productToPriceMap; 
        } catch (Exception ex) {
            logger.error(ex);
            return null;
        } finally {
            logger.flush();
        }
    }

    @AuraEnabled (Cacheable = true)
    global static map<String, String> getSortRule(Id communityId){
        try {
            String webstoreId ;
            List<ConnectApi.SortRule> sortRule = new List<ConnectApi.SortRule>();
            if(!Test.isRunningTest()){
                webStoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
            }
            else{
                webStoreId = [Select id from webStore where Name = 'Sflabs' limit 1].Id;
            }
            ConnectApi.SortRulesCollection mapObj;
            if(!Test.isRunningTest()){
                mapObj = ConnectApi.CommerceSearch.getSortRules(webstoreId);
                sortRule = mapObj.sortRules;
            }
            else{ 
                ConnectApi.SortRule Sortrules = new ConnectApi.SortRule();
                Sortrules.label='Sortrules';
                List<ConnectApi.SortRule> SortRulesList = new List<ConnectApi.SortRule>();
                SortRulesList.add(Sortrules);
                mapObj.sortRules= SortRulesList;
            }
            map<String,String> mapOfSortRule = new Map<String,String>();
            for(ConnectApi.SortRule obj : sortRule){
                mapOfSortRule.put(String.valueOf(obj.label), String.valueOf(obj.sortruleId));
            }
            return mapOfSortRule;
        } catch (Exception ex) {
            logger.error(ex);
            return null;
        } finally {
            logger.flush();
        }
    }
}