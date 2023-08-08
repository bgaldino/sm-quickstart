global with sharing class SM_CalculateTaxOrderItem {
  
    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.TAXES_CALCULATION);

    global class B2B_OrderTaxesCalculationRequest {
        // @InvocableVariable(required=true)
        // public ID checkoutSessionId;
        
        @InvocableVariable(required=true)
        public ID orderId;
    }

    @InvocableMethod(callout=true label='Calculate Order Taxes')
    public static void calculateTaxes(List<B2B_OrderTaxesCalculationRequest> request) {

        Id orderId = request[0].orderId;
        //Id checkoutSessionId = request[0].checkoutSessionId;
        
         calculateTaxAmount(orderId);

        //Deactivate the order
     
    }

    
    global static void calculateTaxAmount(id orderid){

        List<OrderItem> OrderItems = [
            SELECT Id, 
            OrderId, TotalPrice
            FROM OrderItem 
            WHERE orderId = :orderId
            WITH SECURITY_ENFORCED
        ];
        
       
        
        Order ord = [SELECT ID, CurrencyIsoCode, STATUS, TotalAmount FROM ORDER WHERE ID =: orderId WITH SECURITY_ENFORCED];

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

            B2B_TaxModelOrder model = new B2B_TaxModelOrder();
            model.taxType = 'Actual';
            //model.taxEngineId = B2BUtils.fetchConfigByValue('TaxEngineId');
            model.taxEngineId =  RSM_Connector_Configuration__mdt.getInstance('Tax_Engine_Id').key__c; 
            model.isCommit = true;
            model.taxTransactionType = 'Debit';
            model.transactionDate = System.now();
            model.currencyIsoCode = ord.CurrencyIsoCode;
            model.lineItems = new List<B2B_TaxModelOrder.OrderProductLine>();

            for (OrderItem ordItem : OrderItems) {
                B2B_TaxModelOrder.OrderProductLine prodLine = getAvalaraProductLine(ordItem);
                model.lineItems.add(prodLine);
            }
            system.debug('model---- '+model);
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
          if(orderId != null){
         
          if(ord.TotalAmount > 0){
            ord.STATUS = 'Draft';
            DMLManager.updateAsUser(ord);
            //update ord;
          }
        }

        createTaxOrderItem(orderId, JSON.serialize(responseData));
        
    }

    @AuraEnabled
    global static void createTaxOrderItem(Id orderId, String rawResponse) {
        try {
            List<OrderItemTaxLineItem> orderProductTaxLineItem = new List<OrderItemTaxLineItem>();
            RSM_TaxModelResponse taxResponse = (RSM_TaxModelResponse) System.JSON.deserialize(
                rawResponse, RSM_TaxModelResponse.class
            );
            
    
            for(RSM_TaxModelResponse.LineItem item : taxResponse.lineItems) {
                system.debug(item.taxes[0].tax);
                OrderItemTaxLineItem tax = new OrderItemTaxLineItem( 
                        Amount = item.taxes[0].tax,
                        orderItemId = item.lineNumber,
                        Name = 'Order Product Line Item Tax',
                        TaxEffectiveDate = Date.today(),
                        Rate = item.taxes[0].rate,
                        Type = 'Estimated'
                    );
                    orderProductTaxLineItem.add(tax);
            }

            DMLManager.insertAsUser(orderProductTaxLineItem);

           //Activate the order to create billing schedule
           //Deactivate the order
        if(orderId != null){
            Order ord = [SELECT ID, STATUS FROM ORDER WHERE ID =: orderId WITH SECURITY_ENFORCED];
            ord.STATUS = 'Activated';
            //update ord;
            DMLManager.updateAsUser(ord);
  
          }

        } catch (Exception ex) {
            logger.error(ex);
        } finally {
            logger.flush();
        }
    }

    private static B2B_TaxModelOrder.OrderProductLine getAvalaraProductLine(OrderItem ordItem) {
        B2B_TaxModelOrder.OrderProductLine productLine = new B2B_TaxModelOrder.OrderProductLine();
        productLine.lineNumber = ordItem.Id;
        //productLine.amount = cartItem.TotalPrice;
        productLine.amount = ordItem.TotalPrice != null ? ordItem.TotalPrice : ordItem.TotalPrice; //added to for sm api to calculate tax based on unitPrice.
        return productLine;
    }


}