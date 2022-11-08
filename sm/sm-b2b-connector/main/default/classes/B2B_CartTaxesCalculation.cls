global without sharing class B2B_CartTaxesCalculation {

    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.TAXES_CALCULATION);

    global class B2B_CartTaxesCalculationRequest {
        @InvocableVariable(required=true)
        public ID checkoutSessionId;
        
        @InvocableVariable(required=true)
        public ID cartId;
    }

    @InvocableMethod(callout=true label='Calculate Cart Taxes')
    public static void calculateTaxes(List<B2B_CartTaxesCalculationRequest> request) {

        Id cartId = request[0].cartId;
        Id checkoutSessionId = request[0].checkoutSessionId;

        List<CartItem> cartItems = [
            SELECT Id, 
            cartId, 
            TotalPrice
            FROM CartItem 
            WHERE cartId = :cartId
            AND Type != 'Charge'
        ];

        if(!cartItems.isEmpty()) {
            Map<String,object> responseData = calculateTaxAmount(cartItems);
            createTaxCartItem(cartId, JSON.serialize(responseData));
        }
    }

    @AuraEnabled
    global static Map<String,object> calculateTaxAmount(List<CartItem> cartItems){
        Map<String,object> responseData = new Map<String,object>();
        
        try {
            String accessTokenVal;

            if(Test.isRunningTest()) {
                accessTokenVal = 'testToken';
            } else {
                accessTokenVal = B2B_CreateUserAccessToken.getAdminAccessToken();
            }

            String baseUrl = String.valueOf(Url.getOrgDomainUrl().toExternalForm());
            String endPointUrl;
            if(String.isNotBlank(baseUrl)){
                endPointUrl = baseUrl + '/services/data/v55.0/commerce/taxes/actions/calculate';
            }
            String auth = B2B_SetupConstants.BEARER + ' ' + accessTokenVal;

            B2B_TaxModel model = new B2B_TaxModel();
            model.taxType = 'Actual';
            //model.taxEngineId = B2BUtils.fetchConfigByValue('TaxEngineId');
            model.taxEngineId =  RSM_Connector_Configuration__mdt.getInstance('Tax_Engine_Id').key__c; 
            model.isCommit = true;
            model.taxTransactionType = 'Debit';
            model.transactionDate = System.now();
            model.currencyIsoCode = 'USD';

            model.lineItems = new List<B2B_TaxModel.CartProductLine>();

            for (CartItem cartItem : cartItems) {
                B2B_TaxModel.CartProductLine prodLine = getAvalaraProductLine(cartItem);
                model.lineItems.add(prodLine);
            }
            Map<String,String> request = new Map<String,String>();

            request.put(B2B_SetupConstants.AUTHORIZATION,auth);
            request.put(B2B_SetupConstants.ENDPOINT,endPointUrl);
            request.put(B2B_SetupConstants.BODY,JSON.serialize(model));
            request.put(B2B_SetupConstants.METHOD,B2B_SetupConstants.POST);
            request.put(B2B_SetupConstants.CONTENT,B2B_SetupConstants.APPLICATION_JSON);

            String response = RSM_RestApiCalls.httpCallOut(request);
            responseData = (Map<String, Object>) JSON.deserializeUntyped(response);
        } catch (Exception ex) {
            logger.error(ex);
        } finally {
            logger.flush();
        }

        return responseData;
        
    }

    @AuraEnabled
    global static void createTaxCartItem(Id cartId, String rawResponse) {
        try {
            List<CartTax> cartTaxListToCreate = new List<CartTax>();
            RSM_TaxModelResponse taxResponse = (RSM_TaxModelResponse) System.JSON.deserialize(
                rawResponse, RSM_TaxModelResponse.class
            );
            
            if (Schema.sObjectType.CartTax.isDeletable()) {
                delete [SELECT Id FROM CartTax WHERE CartItemId IN (SELECT Id FROM CartItem WHERE CartId = :cartId AND Cart.Status != 'Closed')];
            }

            for(RSM_TaxModelResponse.LineItem item : taxResponse.lineItems) {
                CartTax tax = new CartTax( 
                        Amount = item.taxes[0].tax,
                        CartItemId = item.lineNumber,
                        Name = 'Cart Tax',
                        TaxCalculationDate = Date.today(),
                        TaxRate = item.taxes[0].rate,
                        TaxType = 'Estimated'
                    );
                cartTaxListToCreate.add(tax);
            }

            insert cartTaxListToCreate;
        } catch (Exception ex) {
            logger.error(ex);
        } finally {
            logger.flush();
        }
    }

    private static B2B_TaxModel.CartProductLine getAvalaraProductLine(CartItem cartItem) {
        B2B_TaxModel.CartProductLine productLine = new B2B_TaxModel.CartProductLine();
        productLine.lineNumber = cartItem.Id;
        productLine.amount = cartItem.TotalPrice;
        return productLine;
    }
}