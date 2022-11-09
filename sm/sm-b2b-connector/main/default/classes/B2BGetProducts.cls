/**
 * @description       : 
 * @author            : Raja Patnaik
 * @group             : 
 * @last modified on  : 03-03-2022
 * @last modified by  : Raja Patnaik st
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   03-03-2023   Raja Patnaik  Initial Version
**/
public without sharing class B2BGetProducts {

    public static final String baseUrl = 'https://sflabsdev-dev-ed.lightning.force.com/services/data/v53.0/';
    public static final String calculatePrice = '/commerce/pricing/salestransaction/actions/calculate-price';
    public static String AUTHORIZATIONTITLE = 'Authorization';
    public static String AUTHORIZATION = 'authorization';
    public static String ENDPOINT = 'endPoint';
    public static String METHOD = 'method';
    public static String CONTENTTYPE = 'Content-type';
    public static String CONTENT = 'contentType';
    public static String BODY = 'requestBody';
    public static String POST = 'POST';
    public static String PUT = 'PUT';
    public static String HTTPDELETE = 'DELETE';
    public static String APPLICATION_JSON = 'application/json';
    public static String BEARER = 'Bearer';
    private static final Integer NUM_OF_MEDIA_IDS_PER_REQUEST = 150;
    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.CHECKOUT_FLOW);

    @AuraEnabled(cacheable=true)
    public static ProductDetail getProduct(String productId) {
        List<ProductDetail> response = new List<ProductDetail>();

        try {
            Set<Id> productIds = new Set<Id>();
            // String storeId = B2BUtils.fetchConfigByValue('WebStoreId');
            String storeId = RSM_Connector_Configuration__mdt.getInstance('WebStoreID').key__c;            
            // WebStorePricebook webstorePricebooks;
            List<WebStorePricebook> webstorePricebooks = new List<WebStorePricebook>();
            if(!test.isRunningTest()) {
         	    webstorePricebooks = [SELECT Id, Name, WebStoreId, Pricebook2Id, IsActive FROM WebStorePricebook WHERE WebStoreId = :storeId LIMIT 1];   
            } else {
                webstorePricebooks = [SELECT Id, Name, WebStoreId, Pricebook2Id, IsActive FROM WebStorePricebook WHERE WebStore.Name = 'Sflabs' LIMIT 1];   
            }

            String priceBookId = '';
            if(webstorePricebooks.size() > 0) {
                priceBookId = webstorePricebooks[0].Pricebook2Id;
                List<Product2> products =  [Select Id, Name, ProductCode, CurrencyIsoCode, StockKeepingUnit, Family,Description, (SELECT Id, Name,UnitPrice, Pricebook2Id, ProductSellingModelId, ProductSellingModel.Name, ProductSellingModel.PricingTerm, ProductSellingModel.PricingTermUnit, ProductSellingModel.SellingModelType FROM PricebookEntries WHERE IsActive=true AND Pricebook2Id=:priceBookId ) FROM Product2 WHERE IsActive = true AND Id=:productId];
                for(Product2 product :products ) {
                    productIds.add(product.Id);
                }
                Map<String, String> productImageUrlsByProductIds = getProdImages(productIds, null);
                for(Product2 product :products ) {
                    ProductDetail pd = new ProductDetail();
                    pd.id = product.Id;
                    pd.imageUrl =  productImageUrlsByProductIds.containsKey(pd.id) ? productImageUrlsByProductIds.get(pd.id) : '';
                    pd.product = product;
                    response.add(pd);
                }
            }
        } catch (Exception ex) {
            logger.error(ex);
        } finally {
            logger.flush();
        }

        return response.size() > 0?response[0]:null;
    }

    public static void fetchExternalManagedAccount(){

        ///services/data/v54.0/commerce/webstores/0ZE1K000000CaRR/external-managed-accounts
        System.debug('____' + [Select id from DelegatedAccount]);
        if(!test.isRunningTest()){
            ConnectApi.ExternalManagedAccountCollectionOutput externalAccounts = 
                ConnectApi.ExternalManagedAccount.getExternalManagedAccounts('0ZE5c000000CdMn',true);
            System.debug('externalAccounts:' + externalAccounts);   
        }
        
        String siteBase = 'https://subsmgmt-developer-edition.na160.force.com/eps';
        
         //B2B_User_Login_Configuration__mdt adminUserConfig = B2B_User_Login_Configuration__mdt.getInstance('System_Admin_Configurations');
        RSM_ConnectorConfigrationSelector configSelector = new RSM_ConnectorConfigrationSelector();
        Map<String,String> adminUserConfig = configSelector.getAllConfigByType('Admin Configuration');
 
        Auth.JWT jwt = new Auth.JWT();
        jwt.setSub(UserInfo.getUserName());
        jwt.setIss(adminUserConfig.get('Consumer_Key'));
        jwt.setAud(siteBase);
        Auth.JWS jws = new Auth.JWS(jwt,adminUserConfig.get('Certificate_Name'));
        Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(siteBase+'/services/oauth2/token', jws);
        String accessToken;
        if(test.isRunningTest()){
            accessToken = 'accessToken';
        }else{
            accessToken = bearer.getAccessToken();
        }
        
        Http http = new Http();
        
        HttpRequest request = new HttpRequest();
          
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        String baseUrl = 'https://subsmgmt-developer-edition.na160.force.com/eps/services/data/v54.0/';
        String managedAcocunts = 'commerce/webstores/0ZE5c000000CdMn/external-managed-accounts';
        request.setMethod('GET'); 
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(baseUrl+managedAcocunts);
        // Set the body as a JSON object
        HttpResponse response = http.send(request);
        // Parse the JSON response
        System.debug('response'+response.getBody());

    }

    @AuraEnabled
    public static Map<String,object> calculatePrice(String requestBody) {
        Map<String,object> resultData = new Map<String,object>();

        try {
            String siteBase = System.Label.Site_Base_Url;
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            if(test.isRunningTest()) {
         	    request.setHeader('Authorization', 'Bearer ');   
            } else {
                request.setHeader('Authorization', 'Bearer ' + B2B_CreateUserAccessToken.getAdminAccessToken());
            }
            String baseUrl = String.valueOf(Url.getOrgDomainUrl().toExternalForm());
            String calculatePrice = '/services/data/v54.0/commerce/pricing/salestransaction/actions/calculate-price';
            request.setMethod('POST'); 
            request.setHeader('Content-Type', 'application/json');
            request.setEndpoint(baseUrl+calculatePrice);
            // Set the body as a JSON object
            request.setBody(requestBody);
            HttpResponse response = http.send(request);
            // Parse the JSON response
            resultData.put('response',response.getBody());
            if (response.getStatusCode() != 201) {
                System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
            }
        } catch (Exception ex) {
            logger.error(ex);
        } finally {
            logger.flush();
        }
        
        return resultData;
    }


    @AuraEnabled
    public static Map<String,object> calculatePriceApi(String listPricebookId, list<String>candidatePricebookIds,String productId, Integer quantity,String ProductSellingModelId) {
      
        Map<String,object> resultData = new Map<String,object>();
        try {
            String siteBase = System.Label.Site_Base_Url;
            Http http = new Http();
            RSM_SubscriptionWrapper pricingEngine = new RSM_SubscriptionWrapper(listPricebookId,candidatePricebookIds); 
            String requestBody = pricingEngine.getTermPriceProduct(pricingEngine,productId,quantity,ProductSellingModelId,'USD');

            HttpRequest request = new HttpRequest();
            if(test.isRunningTest()) {
         	    request.setHeader('Authorization', 'Bearer ');   
            } else {
                request.setHeader('Authorization', 'Bearer ' + B2B_CreateUserAccessToken.getAdminAccessToken());
            }
            String baseUrl = String.valueOf(Url.getOrgDomainUrl().toExternalForm());
            String calculatePrice = '/services/data/v55.0/commerce/pricing/salestransaction/actions/calculate-price';
            request.setMethod('POST'); 
            request.setHeader('Content-Type', 'application/json');
            request.setEndpoint(baseUrl+calculatePrice);
            // Set the body as a JSON object
            request.setBody(requestBody);
            HttpResponse response = http.send(request);
            // Parse the JSON response
            resultData.put('response',response.getBody());
            if (response.getStatusCode() != 201) {
                System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
            }
        } catch (Exception ex) {
            logger.error(ex);
        } finally {
            logger.flush();
        }
        
        return resultData;
    }

    
    @AuraEnabled
    public static Map<String,object> calculatePriceforCSR(String requestBody) {
        Map<String,object> resultData = new Map<String,object>();
        System.debug('The status code returned was not expected: '+requestBody);
         String siteBase = 'https://docmation-sm236-dev-org-dev-ed.my.salesforce.com';

        Http http = new Http();
        
        HttpRequest request = new HttpRequest();
        
       
       
        Auth.JWT jwt = new Auth.JWT();
        jwt.setSub(Userinfo.getUserName());
        jwt.setIss('3MVG9uOrYDwSZBEa5oWIwdPIubK5tC9yOXlsmlLhKy0q2x7vhw55MMFULjgsMkhfq1md1ATxkgiEfI7mBAJJe');
        jwt.setAud('https://login.salesforce.com');
        Auth.JWS jws = new Auth.JWS(jwt,'B2BPrivateKey');
        Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(siteBase+'/services/oauth2/token', jws);
        String accessToken;
        if(test.isRunningTest()){
            accessToken = 'accessToken';
        }else{
            accessToken = bearer.getAccessToken();
        }
        
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        String baseUrl = 'https://docmation-sm236-dev-org-dev-ed.my.salesforce.com/services/data/v53.0/';
        String calculatePrice = 'commerce/pricing/salestransaction/actions/calculate-price';

        request.setMethod('POST'); 
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(baseUrl+calculatePrice);
        // Set the body as a JSON object
        request.setBody(requestBody);
        HttpResponse response = http.send(request);
        // Parse the JSON response
        resultData.put('response',response.getBody());
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
            response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
        }
        
      return resultData;
    }

    @AuraEnabled
    public static Map<String,object> createNewOrder(String requestBody) {
        Map<String,object> resultData = new Map<String,object>();
        String siteBase = 'https://docmation-sm236-dev-org-dev-ed.my.salesforce.com';
        //B2B_User_Login_Configuration__mdt adminUserConfig = B2B_User_Login_Configuration__mdt.getInstance('System_Admin_Configurations');
        Auth.JWT jwt = new Auth.JWT();
        jwt.setSub(Userinfo.getUserName());
        jwt.setIss('3MVG9uOrYDwSZBEa5oWIwdPIubK5tC9yOXlsmlLhKy0q2x7vhw55MMFULjgsMkhfq1md1ATxkgiEfI7mBAJJe');
        jwt.setAud('https://login.salesforce.com');
        Auth.JWS jws = new Auth.JWS(jwt,'B2BPrivateKey');
        Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(siteBase+'/services/oauth2/token', jws);
        String accessToken;
        if(test.isRunningTest()){
            accessToken = 'accessToken';
        }else{
            accessToken = bearer.getAccessToken();
        }

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        String baseUrl = 'https://docmation-sm236-dev-org-dev-ed.my.salesforce.com/services/data/v54.0/';
        String orderRequest = 'actions/custom/flow/SM_Buy_Now_Assets';
        request.setMethod('POST'); 
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(baseUrl+orderRequest);
        // Set the body as a JSON object
        request.setBody(requestBody);
        HttpResponse response = http.send(request);
        // Parse the JSON response
        resultData.put('response',response.getBody());
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
            response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
        }
        
      return resultData;
    }

    public static Map<String, String> getProdImages(Set<Id> productIds, string commId){
        Map<String, String> productImageUrlsByProductIds = new Map<String, String>();
        try{

        
        id communityId =   [SELECT id, name FROM Network where id =: commId LIMIT 1].id;

        List<ProductMedia> prodMedia =
                [
                    SELECT ElectronicMediaId,
                    ProductId
                    FROM ProductMedia
                    WHERE ProductId IN :productIds
                    ORDER BY SortOrder
                ];
            
            Map<String, String> electronicMediaIds = new Map<String, String>();
            if (prodMedia != null && prodMedia.size() > 0) {
                for (ProductMedia p : prodMedia) {
                    electronicMediaIds.put(p.ElectronicMediaId, p.ProductId);
                }
            } 
            Map<String, String> electronicMediaIdsCopy = electronicMediaIds.clone();
            while (true) {
                List<String> loopElMediaIds = getSubSetAndRemoveFromOriginal(electronicMediaIdsCopy.keySet(), NUM_OF_MEDIA_IDS_PER_REQUEST);
                if (loopElMediaIds.isEmpty()) {
                    break;
                }
                if (! loopElMediaIds.isEmpty()) {
                    ConnectApi.ManagedContentVersionCollection contentVersionCollection = ConnectApi.ManagedContent.getManagedContentByIds(
                        communityId,
                        loopElMediaIds,
                        null,
                        NUM_OF_MEDIA_IDS_PER_REQUEST,
                        null,
                        null
                    );
                    
                    List<ConnectApi.ManagedContentVersion> contentVersions = (List<ConnectApi.ManagedContentVersion>) contentVersionCollection.items;
                    if (contentVersions != null && contentVersions.size() > 0) {
                        for (ConnectApi.ManagedContentVersion managedContentVersion : contentVersions) {
                            system.debug(JSON.serialize(managedContentVersion));
                            if (managedContentVersion.title != null && managedContentVersion.contentNodes != null) {
                                Map<String, ConnectApi.ManagedContentNodeValue> contentNodes = (Map<String, ConnectApi.ManagedContentNodeValue>) managedContentVersion.contentNodes;
                                ConnectApi.ManagedContentMediaSourceNodeValue mediaSourceNodeValue = (ConnectApi.ManagedContentMediaSourceNodeValue) contentNodes.get('source');
                                if(mediaSourceNodeValue.url != null){
                                    String electronicMediaId = String.valueOf(managedContentVersion.managedContentId);
                                    productImageUrlsByProductIds.put(electronicMediaIds.get(electronicMediaId),mediaSourceNodeValue.url);
                                }
                            }
                        }
                    }
                }
            }
            system.debug('*** productImageUrlsByProductIds'+productImageUrlsByProductIds);
        }catch(Exception e){
            system.debug('Exception while getting product images'+e.getMessage());
        }
        return productImageUrlsByProductIds;
    }
    private static List<String> getSubSetAndRemoveFromOriginal(Set<String> original, Integer size){
        List<String> subSet = new List<String>();
        
        for (String str : original) {
            subSet.add(str);
            if (subSet.size() >= size) {
                break;
            }
            
        }
        original.removeAll(subSet);
        return subSet;
    }

    public class ProductDetail{
        @AuraEnabled 
        public Product2 product { get; set; }
        @AuraEnabled 
        public String id { get; set; }
        @AuraEnabled 
        public String imageUrl { get; set; }
    }
}