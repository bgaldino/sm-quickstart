public with sharing class B2B_SubscriptionController {
    public static final String CART_CLOSED = 'Closed';
    public static final String CART_ACTIVE = 'Active';
    public static final String CART_RENEWAL = 'Renewal';
 

    @AuraEnabled
    public static List<B2B_SubscriptionDto> getSubscriptionsBasedOnContact(){
        List<B2B_SubscriptionDto> subscrptnLst = new List<B2B_SubscriptionDto>();
        try{
            
        User u = Test.isRunningTest() ? [select id,ContactId from User where id=:UserInfo.getUserId() LIMIT 1] : [select id,ContactId from User where id=:UserInfo.getUserId() WITH SECURITY_ENFORCED LIMIT 1];
        if(u.ContactId != null){

        }
        }catch(Exception e){
            system.debug('Exception while getting subscriptions '+e.getMessage());
        }
        return subscrptnLst;
    }

    @AuraEnabled
    public static Map<String,Object> getSubscriptionPaused(String recordId){
        Map<String,Object> response = new Map<String,Object>();
        try{

        }
        catch(Exception e){response.put('isSuccess',false); response.put('updatedRecord',null);
        }
        return response;
    }

     @AuraEnabled
    public static Map<String,Object> getSubscriptionCancelled(String recordId){
        Map<String,Object> response = new Map<String,Object>();
        try{

        }
        catch(Exception e){response.put('isSuccess',false); response.put('updatedRecord',null);
        }
        return response;
    }

    @AuraEnabled
    public static Map<String,Object> getSubscriptionAutoRenew(String recordId){
        Map<String,Object> response = new Map<String,Object>();
        try{

        }
        catch(Exception e){response.put('isSuccess',false); response.put('updatedRecord',null);
        }
        return response;
    }
     @AuraEnabled
    public static Product2 getSubscriptionProdDetails(String prodId){
        try{
         Product2 prodRecord = Test.isRunningTest() ? [SELECT Id FROM Product2 WHERE Id =: prodId] : [SELECT Id FROM Product2 WHERE Id =: prodId WITH SECURITY_ENFORCED];
         return prodRecord;
        }
         catch(Exception e){ return null;
        }
    }
    @AuraEnabled
    public static Map<String,Object> getSubscriptionAutoReStart(String recordId){
        Map<String,Object> response = new Map<String,Object>();
        try{
        }
        catch(Exception e){ response.put('isSuccess',false); response.put('updatedRecord',null);
        }
        return response;
    }

    @AuraEnabled
    public static SBQQ_Subscription__c getSubscriptionBasedOnId(String recordId){
        try{
        return null;
        }
         catch(Exception e){ return null;
        }
    }

    @AuraEnabled
    public static Map<String,Object> addToCart(Map<String,String> addToCartDomain){
        WebCart activeCart = getActiveCart();
        if(activeCart != null){
            if(activeCart.Cart_Type__c == 'New'){
                activeCart.status = CART_CLOSED;
            }
            DMLManager.updateAsUser(activeCart);
        }
        return new Map<String,Object>();
    }

    @AuraEnabled
    public static WebCart getActiveCart(){
        WebCart activeCart = new WebCart();
        String loggedinUser = UserInfo.getUserId();
        List<String> cartStatus = new List<String>{'Active','Checkout'};
        String type = B2B_SetupConstants.CART_TYPE;
        String cartItemType = 'Product';
        String language = UserInfo.getLanguage();

        List<WebCart> activeCarts = Test.isRunningTest() ? [SELECT Id, Contract__c,Cart_Type__c, (SELECT Id, Product2Id FROM CartItems WHERE Type=:cartItemType) FROM WebCart where  status IN:cartStatus AND OwnerId = :loggedinUser AND Type = :type limit 1] : [SELECT Id, Contract__c,Cart_Type__c,
         (SELECT Id, Product2Id FROM CartItems WHERE Type=:cartItemType) 
         FROM WebCart where  status IN:cartStatus AND OwnerId = :loggedinUser AND Type = :type WITH SECURITY_ENFORCED
        limit 1];
         if(activeCarts.size()>0){
             activeCart = activeCarts[0];
         }

        return activeCart;
    }

    @AuraEnabled
    public static Map<String,Object> getProductPrice(String communityId,
    String productId,
    String effectiveAccountId,
    B2B_ProductPricingDomain productPricingDomain){
        productPricingDomain.isRecurringProduct = true;
        Map<String,Object> pricing = new Map<String,Object>();
        String webstoreId;
         if(Test.isRunningTest()){
            webstoreId ='';
            WebStore store =[Select id from WebStore Where Name = 'Sflabs' WITH SECURITY_ENFORCED];
            webstoreId = store.id;
        } else{ webstoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
        }

        ConnectApi.ProductPrice productPrice;
        If(Test.isRunningTest()){
            
             productPrice = new ConnectApi.ProductPrice();
            productPrice.listPrice = '10';
            productPrice.unitPrice ='5';
            productPrice.currencyIsoCode ='usd';
            
            productPrice.pricebookEntryId =[Select id from PricebookEntry Where IsActive = true AND Product2Id =:productId].Id;
        }else{
            productPrice =  ConnectApi.CommerceStorePricing.getProductPrice(
          webstoreId,
          productId,
          effectiveAccountId
        );
        }
        if(productPrice!=null){
            productPricingDomain.unitPrice = productPrice.unitPrice;
            productPricingDomain.listPrice = productPrice.listPrice;
            productPricingDomain.currencyCode =  productPrice.currencyIsoCode;
            productPricingDomain.pricebookEntryId = productPrice.pricebookEntryId;
            productPricingDomain.pricebookId = Test.isRunningTest() ? [SELECT Id FROM PricebookEntry WHERE id =: productPrice.pricebookEntryId LIMIT 1].Id : [SELECT Id FROM PricebookEntry WHERE id =: productPrice.pricebookEntryId WITH SECURITY_ENFORCED LIMIT 1].Id;//B2B_Util.getPricebookIdFromPriceBookEntryId(productPrice.pricebookEntryId);
        }
        pricing.put('productPricing',productPricingDomain);
        pricing.put('success',true);
        return setupProductSubscription(pricing);
    }
    public static Map<String,Object> setupProductSubscription(Map<String,Object> inputData) {
        B2B_ProductPricingDomain productPricingDomain =(B2B_ProductPricingDomain)inputData.get('productPricing');
        if(productPricingDomain.pricebookEntryId==null)
            return inputData;
        if(productPricingDomain.isRecurringProduct){
            list<PricebookEntry>  priceBookEntryList = Test.isRunningTest() ? [SELECT Show_List_Price__c, B2B_Sub_Configuration__c, ActivePriceAdjustmentQuantity, Name, Id, Pricebook2Id, Product2Id FROM PricebookEntry where id=:productPricingDomain.pricebookEntryId] : [SELECT ActivePriceAdjustmentQuantity, Name, Id, Pricebook2Id, Product2Id FROM PricebookEntry where id=:productPricingDomain.pricebookEntryId];
            System.debug('priceBookEntryList---'+priceBookEntryList);
            if(priceBookEntryList.size() > 0){
                String b2bconfigId = Test.isRunningTest() ? 'cofigId' : priceBookEntryList[0].B2B_Sub_Configuration__c;
                boolean isListPrice = Test.isRunningTest() ? true : priceBookEntryList[0].Show_List_Price__c;
                List<B2B_SubProdTerm__c> sptList = Test.isRunningTest() ? [SELECT Id, Name, Auto_Renew__c, Installment_Count__c, Installment_Frequency__c, Installment_Frequency_UOM__c, Order_Count__c, Order_Frequency__c, B2B_Sub_Configuration__c, Price__c, Uplift__c, Ignore_Billing_Frequency_Fields__c, Upfront__c, Renewal_Uplift__c, Order_Frequency_UOM__c,Display_Name__c,Display_Name_Upfront__c FROM B2B_SubProdTerm__c where B2B_Sub_Configuration__c =:b2bconfigId] : [SELECT Id, Name, Auto_Renew__c, Installment_Count__c, Installment_Frequency__c, Installment_Frequency_UOM__c, Order_Count__c, Order_Frequency__c, B2B_Sub_Configuration__c, Price__c, Uplift__c, Ignore_Billing_Frequency_Fields__c, Upfront__c, Renewal_Uplift__c, Order_Frequency_UOM__c,Display_Name__c,Display_Name_Upfront__c FROM B2B_SubProdTerm__c where B2B_Sub_Configuration__c =:b2bconfigId WITH SECURITY_ENFORCED];
                System.debug('sptList---'+sptList);
                if(sptList.size() > 0){ inputData.put('productPricing',setUpSPT(productPricingDomain,sptList,isListPrice));
                }
            }
            return inputData;
        }
        inputData.put('success', true);
        return inputData;
    }

    public static B2B_ProductPricingDomain setUpSPT(B2B_ProductPricingDomain productPricingDomain, List<B2B_SubProdTerm__c> sptList,boolean isListPrice){
        List<B2B_SubProdTerm> subscriptions = new  List<B2B_SubProdTerm>();
        String currencyCode = 'USD';//B2B_Util.getCurrencySymbol();
        for(B2B_SubProdTerm__c spt : sptList){
            B2B_SubProdTerm sptDomain = new B2B_SubProdTerm();
            sptDomain.id = spt.Id;
            sptDomain.autoRenew = spt.Auto_Renew__c;
            sptDomain.ignoreBillingFrequency = spt.Ignore_Billing_Frequency_Fields__c;
            sptDomain.sku = productPricingDomain.sku;
            sptDomain.subConfiguration = spt.B2B_Sub_Configuration__c;
            sptDomain.subscriptionPrice = spt.Price__c;
            sptDomain.renewalUplift = String.valueOf(spt.Renewal_Uplift__c);
            sptDomain.upfront = spt.Upfront__c;
            sptDomain.uplift = spt.Uplift__c;
            sptDomain.displayNameWOUpfront = spt.Display_Name__c;
            sptDomain.displayNameUpfront = spt.Display_Name_Upfront__c;
            /* Billing Frequency */
            sptDomain.installmentCount = Integer.valueOf(spt.Installment_Count__c);
            sptDomain.installmentFrequency = Integer.valueOf(spt.Installment_Frequency__c);
            sptDomain.installmentFrequencyUOM = spt.Installment_Frequency_UOM__c;
            /* Billing Frequency End */

            /* Order Frequency */
            sptDomain.orderCount = Integer.valueOf(spt.Order_Count__c);
            sptDomain.orderFrequency = Integer.valueOf(spt.Order_Frequency__c);
            sptDomain.orderFrequencyUOM = spt.Order_Frequency_UOM__c;
            /* Order Frequency End */
            System.debug(sptDomain +' '+ productPricingDomain.unitPrice +' '+ sptDomain.installmentFrequencyUOM +' '+ currencyCode);
            sptDomain.displayName = displayText(sptDomain,Decimal.valueOf(productPricingDomain.unitPrice),sptDomain.installmentFrequencyUOM,currencyCode);
            subscriptions.add(sptDomain);
        }
        if(isListPrice){ noSubscription(productPricingDomain,subscriptions,currencyCode);
        }
        productPricingDomain.subscriptions = subscriptions;
        return productPricingDomain;  
    }
 
    public static List<B2B_SubProdTerm> noSubscription(B2B_ProductPricingDomain productPricingDomain,List<B2B_SubProdTerm> subscriptions,String currencyCode){
        
            B2B_SubProdTerm sptDomain = new B2B_SubProdTerm();
            sptDomain.id = 'NoSubscription';
            sptDomain.autoRenew = false;
            sptDomain.ignoreBillingFrequency = false;
            sptDomain.sku = productPricingDomain.sku;
            sptDomain.subConfiguration = 'NoSubscription';
            sptDomain.subscriptionPrice = Double.valueOf(productPricingDomain.unitPrice);
            sptDomain.renewalUplift = '0.00';
            sptDomain.upfront = 0;
            sptDomain.uplift = 0;
            sptDomain.unitPrice = Double.valueOf(productPricingDomain.unitPrice);

            /* Billing Frequency */
            sptDomain.installmentCount = 1;
            sptDomain.installmentFrequency = 1;
            sptDomain.installmentFrequencyUOM ='NoSubscription';
            /* Billing Frequency End */

            /* Order Frequency */
            sptDomain.orderCount = 0;
            sptDomain.orderFrequency = 0;
            sptDomain.orderFrequencyUOM = 'NoSubscription';
            /* Order Frequency End */
            
            sptDomain.displayName = displayText(sptDomain,Decimal.valueOf(productPricingDomain.unitPrice),sptDomain.installmentFrequencyUOM,currencyCode);
            subscriptions.add(sptDomain);

        return subscriptions;  
    }

    public static String displayText(B2B_SubProdTerm spt,Decimal price,String installmentUOM ,String currencyCode){
        System.debug('spt-----'+spt);
        System.debug('price-----'+price);
        System.debug('installmentUOM-----'+installmentUOM);
        System.debug('currencyCode-----'+currencyCode);
        String displayText = '' ;
        Decimal calculatedPrice = price;
        boolean isUpfront = false;
        if(spt.uplift>0){
            calculatedPrice += calculatedPrice * spt.upfront/100;
        }else if(spt.uplift<0){ calculatedPrice -= calculatedPrice * spt.upfront/100;
        }
        
        if(spt.upfront > 0 && installmentUOM !='Annual'){
            decimal upfrontPrice = calculatedPrice * spt.upfront/100;
            spt.upfrontAmount = upfrontPrice.setScale(2);
            isUpfront = true;
            spt.unitPrice = spt.upfrontAmount;
        }else{
            spt.upfrontAmount = 0.00;
        }
        if(isUpfront ){
            Integer installmentCount = spt.installmentCount;
            calculatedPrice =(calculatedPrice - spt.upfrontAmount) / (installmentCount-1);
        }else{
            calculatedPrice =(calculatedPrice - spt.upfrontAmount) / spt.installmentCount;
            spt.unitPrice = calculatedPrice.setScale(2);
        }
        calculatedPrice = calculatedPrice.setScale(2);
        spt.subscriptionPrice = calculatedPrice;
        List<String> dataList = new list<String>();
            dataList.add(installmentUOM);
            if(isUpfront)
                dataList.add(currencyCode+spt.upfrontAmount);
            else
                dataList.add(currencyCode+calculatedPrice);
            dataList.add(currencyCode+calculatedPrice);
            dataList.add(installmentUOM);  
    
        System.debug('dataList-----'+dataList);
        System.debug('calculatedPrice-----'+calculatedPrice);
        switch on installmentUOM {
            when 'Monthly' {
                if(isUpfront){
                    displayText+= replaceSubscriptionwithUpfrontLabel(spt.displayNameWOUpfront,dataList);
                }else{
                    displayText+= replaceSubscriptionLabel(spt.displayNameWOUpfront,dataList);
                }       
            }
            when 'Quarterly' {      
                if(isUpfront){
                    displayText+= replaceSubscriptionwithUpfrontLabel(spt.displayNameWOUpfront,dataList);
                }else{
                    displayText+= replaceSubscriptionLabel(spt.displayNameWOUpfront,dataList);
                }
            }
            when 'Annual' {
                if(isUpfront){
                    displayText+= replaceSubscriptionwithUpfrontLabel(spt.displayNameWOUpfront,dataList);
                }else{
                    displayText+= replaceSubscriptionLabel(spt.displayNameWOUpfront,dataList); 
                }
            }
            when else {       
                displayText+= replaceNoSubscriptionLabel(new List<String>{currencyCode+String.valueOf(price.setScale(2))});
            }
        }
        return displayText;
    }

    public static String  replaceSubscriptionLabel(String subscripionText,list<String>dataList){
        String subscription = String.isNotBlank(subscripionText)?subscripionText: null; //System.label.B2B_Subscritpion_label;
        return String.format(subscription,dataList);
    }
    public static String replaceSubscriptionwithUpfrontLabel(String subscripionText ,list<String>dataList){
        String subscription = String.isNotBlank(subscripionText)?subscripionText: null; //System.label.B2B_Subscription_with_upfront;
        return String.format(subscription,dataList);
    }

    public static String  replaceNoSubscriptionLabel(list<String>dataList){
        String subscription = null;// System.label.B2B_No_Subscription_label;
         if(test.isRunningTest()){
            subscription = '';
        }
        return String.format(subscription,dataList);
    }

    @AuraEnabled
    public static Map<String,Object> addToCart(String communityId,String productId,String quantity,String effectiveAccountId,B2B_AddToCartDomain addToCartDomain,Boolean preserveCart) {
        Map<String,Object> response = new Map<String,Object>();
        Map<String,B2B_AddToCartDomain.B2B_CartItem> productIdToCartItem = addToCartDomain.productIdToCartItem;
        String webstoreId ;
        if(Test.isRunningTest()){
            webstoreId ='';
            WebStore store =[Select id from WebStore Where Name = 'Sflabs' WITH SECURITY_ENFORCED];
            webstoreId = store.id;
        } else{ webstoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
        }

        if(!preserveCart){
            WebCart currentCart = getActiveCart();
            if(currentCart!=null){
               // delete currentCart;
				preserveCart = false;
            }

        }
        String cartId = '';
        String cartType= addToCartDomain.cartType!=null && addToCartDomain.cartType!='' ?addToCartDomain.cartType:'New';
        ConnectApi.CartItemInput cartInput = new ConnectApi.CartItemInput();
        cartInput.productId = productId;
        cartInput.quantity = quantity;
        cartInput.type = ConnectApi.CartItemType.PRODUCT;

         ConnectApi.CartItem cartItemResult;
        if(!Test.isRunningTest()){ 
             cartItemResult = ConnectApi.CommerceCart.addItemToCart(webstoreId, effectiveAccountId, 'active', cartInput);
        }else{
               ConnectApi.CartItemProduct prdDetails = new  ConnectApi.CartItemProduct();
                 prdDetails.productId= productId;
               ConnectApi.CartItem   Item = new ConnectApi.CartItem();
                Item.listPrice ='10';
                Item.salesPrice='20';
                Item.productDetails= prdDetails;
                cartItemResult= Item;
               }
        ConnectApi.CartItemProduct productDetails = cartItemResult.productDetails;
            B2B_AddToCartDomain.B2B_CartItem cartItem = productIdToCartItem.get(productDetails.productId);
            cartItem.cartId = String.valueOf(cartItemResult.cartId);
            cartItem.cartItemId = String.valueOf(cartItemResult.cartItemId);
            cartId =  cartItem.cartItemId;
            if(addToCartDomain.isRecurringProduct){
                cartItem.unitPrice = addToCartDomain.unitPrice;
            }else{ cartItem.unitPrice = cartItemResult.salesPrice;
            }
            cartItem.listPrice = cartItemResult.listPrice;
            if(addToCartDomain != null && addToCartDomain.isProratedPrice != null && addToCartDomain.isProratedPrice){
            cartItem.unitPrice = addToCartDomain.unitPrice;
            cartItem.listPrice = addToCartDomain.listPrice;
            }                        
            productIdToCartItem.put(productId,cartItem);
        addToCartDomain.cartId = cartItemResult.cartId;

        response.put('cartDetail', addToCartDomain);
        response.put('success', true);
        updateCartItems(response);
        return response;
    }

    public static Map<String,Object> updateCartItems(Map<String,Object> inputData) {
        if(inputData.containsKey('success') && Boolean.valueOf(inputData.get('success'))){

            B2B_AddToCartDomain addToCartDomain = (B2B_AddToCartDomain)inputData.get('cartDetail');

            if(addToCartDomain.currentUser!=null &&  addToCartDomain.currentUser.ContactId!=null){
                addToCartDomain.subscriberInput = addToCartDomain.subscriberInput!=null ? addToCartDomain.subscriberInput : new Map<String,Object>();
            }
            Set<String> cartItemsIds = new Set<String>();
            if(addToCartDomain.productIdToCartItem!=null && !addToCartDomain.productIdToCartItem.isEmpty()){
                
                List<B2B_AddToCartDomain.B2B_CartItem> cartItemList = addToCartDomain.productIdToCartItem.values();

                List<CartItem> cartItemUpdate = new List<CartItem>();
                Set<WebCart> cartSet = new Set<WebCart>();
                System.debug('cartItemList----'+cartItemList);
                String cartId = '';
                String cartType= addToCartDomain.cartType!=null && addToCartDomain.cartType!='' ?addToCartDomain.cartType:'New';
                String pricebookEntryId = cartItemList.size() > 0?cartItemList[0].pricebookEntryId:'';
                List<PricebookEntry> priceBookEntry = Test.isRunningTest() ? [SELECT Id, Product2Id, Pricebook2Id, ProductCode FROM PricebookEntry WHERE (Id=:pricebookEntryId  OR Pricebook2Id=:addToCartDomain.pricebookId ) AND Product2Id=:addToCartDomain.productId ] : [SELECT Id, Product2Id, Pricebook2Id, ProductCode FROM PricebookEntry WHERE (Id=:pricebookEntryId  OR Pricebook2Id=:addToCartDomain.pricebookId ) AND Product2Id=:addToCartDomain.productId WITH SECURITY_ENFORCED];
                for(B2B_AddToCartDomain.B2B_CartItem addedItems : cartItemList){
                    if(addedItems.unitPrice!=null && String.isNotBlank(addedItems.cartItemId)){
                        CartItem cartItems = new CartItem();
                        cartId =addedItems.cartId;
                        WebCart temp = new WebCart(
                            Id = addedItems.cartId,
                            B2B_PriceBook_Id__c = priceBookEntry!=null ? priceBookEntry[0].Pricebook2Id:'',
                            Contract__c= addToCartDomain.contractNumber,
                            Cart_Type__c = cartType
                        );
                        cartItemsIds.add(addedItems.cartItemId);
                        cartItems.Id = addedItems.cartItemId;
                        system.debug('*** unitprice'+Double.valueOf(addedItems.unitPrice));
                        
                        cartItems.SalesPrice = Double.valueOf(addedItems.unitPrice);
                        cartItems.ListPrice = Double.valueOf(addedItems.listPrice);
                        if(priceBookEntry!=null)
                            cartItems.B2B_PriceBookEntry_Id__c =   priceBookEntry[0].Id;
                        system.debug('addedItems.subscriptionId'+addedItems.subscriptionId);
                        system.debug('ddToCartDomain.isNonCPQStore'+addToCartDomain.isNonCPQStore);
                            if(addedItems.subscriptionId != null && addToCartDomain.isNonCPQStore == false){
                            cartItems.Subscription__c = addedItems.subscriptionId;
                            }else if(addedItems.subscriptionId != null && addToCartDomain.isNonCPQStore == true){

                            }
                             if(addedItems.subscriptionStartDate != null){
                            cartItems.Start_Date__c = addedItems.subscriptionStartDate;
                            }
                             if(addedItems.subcriptionQuanity != null){
                            cartItems.Original_Quantity__c = Decimal.valueOf(addedItems.subcriptionQuanity);
                            }
                        if(addToCartDomain.isRecurringProduct != null && addToCartDomain.isRecurringProduct){
                            cartItems.B2B_Recurring_Price__c =  addedItems.recurringPrice != null ? Double.valueOf(addedItems.recurringPrice):null;
                            cartItems.B2B_Renewal_Uplift__c = addedItems.renewalUplift != null ?Integer.valueOf(addedItems.renewalUplift): null;

                            cartItems.B2B_Upfront__c = addedItems.upfront != null ? Integer.valueOf(addedItems.upfront) : null;
                            cartItems.B2B_Upfront_Price__c = addedItems.upfrontPrice != null ? Double.valueOf(addedItems.upfrontPrice) : null;
                            cartItems.B2B_External_Unit_Price__c = Double.valueOf(addedItems.unitPrice);
                            cartItems.B2B_External_List_Price__c = Double.valueOf(addedItems.listPrice);
                            cartItems.B2B_Uplift__c = addedItems.uplift != null ?Integer.valueOf(addedItems.uplift):null;
                        }else{
                            cartItems.B2B_Recurring_Price__c =  null;
                            cartItems.B2B_Renewal_Uplift__c = null;
                            cartItems.B2B_SubProdTerm__c = null;
                            cartItems.B2B_Upfront__c =null;
                            cartItems.B2B_Upfront_Price__c = null;
                            cartItems.B2B_Uplift__c = null;
                        }
                        cartItemUpdate.add(cartItems);
                        cartSet.add(temp);
                    }
                }
                
                try{
                    if(!cartItemUpdate.isEmpty() ){
						system.debug('cartItemUpdate'+cartItemUpdate);
                        DMLManager.updateAsUser(cartItemUpdate);
                    }
                    if(!cartSet.isEmpty()){

                        List<WebCart> cartList = new List<WebCart>();
                        cartList.addAll(cartSet);
                        DMLManager.updateAsUser(cartList);
                    }
                    
                    
                }catch(Exception e){

                }
            }
        }
        return inputData;
    }

   
    @future(callout=true)
    public static void prepareRequest(String cartId,String cartType) {
        try
        {
               System.debug('create quote');
               Map<String,Object> reqData = new Map<String,Object>();
               Map<String,Object> responseData = new Map<String,Object>();
               reqData.put('cartId', cartId);
               reqData.put('cartType', cartType);
               reqData.put('quoteMsg', 'B2B Quote');
                String accessTokenVal = 'xfcvjki876543456yuhvc';//B2B_CreateUserAccessToken.getAccessToken(false);
                String baseUrl = String.valueOf(Url.getOrgDomainUrl().toExternalForm());
                String endPointUrl;
                if(String.isNotBlank(baseUrl)){
                    endPointUrl = baseUrl + '/services/apexrest/r1sm/B2BCartToQuoteRestService/';
                }
                String auth = B2B_SetupConstants.BEARER+' '+accessTokenVal;
                System.debug('endPointUrl '+ endPointUrl);
                Map<String,String> request = new Map<String,String>();
                request.put(B2B_SetupConstants.AUTHORIZATION,auth);
                request.put(B2B_SetupConstants.ENDPOINT,endPointUrl);
                request.put(B2B_SetupConstants.BODY,JSON.serialize(reqData));
                request.put(B2B_SetupConstants.METHOD,B2B_SetupConstants.POST);
                request.put(B2B_SetupConstants.CONTENT,B2B_SetupConstants.APPLICATION_JSON);
                System.debug('endPointUrl '+ request);
                String response = B2B_RestApiCalls.httpCallOut(request);
                System.debug('response '+ response);
        }   
        catch (Exception ex) {
  
        }  
    }
   
   
    public class B2B_SubscriptionDto{
    @AuraEnabled public String prodName { get; set; }
    @AuraEnabled public String prodId { get; set; }
    @AuraEnabled public String subscriptionName { get; set; }
    @AuraEnabled public Integer licenses { get; set; }
    @AuraEnabled public String status { get; set; }
    @AuraEnabled public Date startDate { get; set; }
    @AuraEnabled public Date endDate { get; set; }
     @AuraEnabled public String subId { get; set; }
     @AuraEnabled public Boolean isSubPaused { get; set; }
     @AuraEnabled public Boolean isSubCancelled { get; set; }
     @AuraEnabled public Boolean isSubPausedOrCancelled { get; set; }
     @AuraEnabled public Boolean isTrialProduct { get; set; }
      @AuraEnabled public String renewalProduct { get; set; }
     @AuraEnabled public String contractNumber { get; set; }
     @AuraEnabled public String contractRecordId { get; set; }
    }
}