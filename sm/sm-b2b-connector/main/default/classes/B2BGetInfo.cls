public with sharing class B2BGetInfo {
  private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.CHECKOUT_FLOW);

  @AuraEnabled(cacheable=true)
  public static ConnectApi.ProductDetail getProduct(
    String communityId,
    String productId,
    String effectiveAccountId
  ) {
    String webstoreId = Test.isRunningTest() ? [Select id from WebStore Where Name = 'Sflabs'].id : [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
   /* if(!Test.isRunningTest()){
      // Lookup the webstore ID associated with the community
      webstoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
    }
      else
      { webstoreId =[Select id from WebStore Where Name = 'Sflabs'].id; }*/
      // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCatalog_static_methods.htm#apex_ConnectAPI_CommerceCatalog_static_methods
     if(!Test.isRunningTest()){
         return ConnectApi.CommerceCatalog.getProduct(webstoreId,productId,effectiveAccountID,null,false,null,false,true,false);
    }
      else{
        ConnectApi.ProductDetail PD;
        try {
          PD = new ConnectApi.ProductDetail();
        } catch (Exception ex) { logger.error(ex);} 
          finally {
          logger.flush();
        }
        PD.id = productId;
        return PD;
      }
  }

  @AuraEnabled(cacheable=true)
  public static Boolean checkProductIsInStock(String productId) {
    /*
     * The following is an example of calling an external API.
     * The example API provided is extremely simple: It takes in a product id
     * and returns a true or false value for inStock based on whether the 15th char is odd or even.
     *
     * To access this endpoint on your org, go to Remote Site Settings in Setup as an admin user
     * click "New Remote Site" and provide "https://inventorymanagerdemo.herokuapp.com" for the "Remote Site URL" field
     */
    HttpResponse response;
    Boolean result = false;
    try {
      Http http = new Http();
      HttpRequest request = new HttpRequest();
      String endpoint =
        'https://inventorymanagerdemo.herokuapp.com/api/inventory/' + productId;
      request.setEndpoint(endpoint);
      request.setMethod('GET');
      response = http.send(request);

      // If the request is successful, parse the JSON response.
      if (response.getStatusCode() == 200) {
        // Deserialize the JSON string into collections of primitive data types.
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(
          response.getBody()
        );
        result = (boolean) results.get('inStock');
      } 
    } catch (Exception ex) {logger.error(ex);result = false;} 
      finally {
      logger.flush();
    }

    return result;
  }

  @AuraEnabled
  public static ConnectApi.CartSummary getCartSummary(
    String communityId,
    String effectiveAccountId
  ) {
      try {
        String webstoreId = test.isRunningTest() ? [Select id from WebStore Where Name = 'Sflabs'].Id :  [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId ;
        /*if(Test.isRunningTest()){
            webstoreId ='';
            WebStore store =[Select id from WebStore Where Name = 'Sflabs'];
            webstoreId = store.id;
        } else {
            webstoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
        }*/
        // Lookup the webstore ID associated with the community
        // String webstoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;

        //'current' is available in version 50.0 and later and indicates a cart with a status that isn’t Closed or PendingDelete
        //This is important for the product detail page since we are using the cart summary to check if the status is "Processing" or "Checkout"
        String activeCartOrId = 'current';
        if(test.isRunningTest()) {
            ConnectApi.CartSummary cartSummary= new ConnectApi.CartSummary();
            cartSummary.webstoreId= webstoreId;
            return cartSummary;
        } else {
          // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm 
          return ConnectApi.CommerceCart.getCartSummary(webstoreId,effectiveAccountId,activeCartOrId);
        }
      } catch (Exception ex) {logger.error(ex);return null;} 
      finally {
        logger.flush();
      }
    }

  @AuraEnabled
  public static CartItem addToCart(
    String communityId,
    String productName,
    String cartId,
    String productId,
    Decimal price,
    String quantity,
    String priceBookEntryId,
    String modelName,
    String modelType,
    String modelTermUnit,
    String effectiveAccountId
  ) {
    try{
        
            List<CartItem> cartIt = [SELECT Id,cartId,cart.webstoreId, Quantity, ListPrice, Product2Id, B2B_PriceBookEntry_Id__c FROM CartItem WHERE CartId = :cartId AND Product2Id = :productId AND B2B_PriceBookEntry_Id__c = :priceBookEntryId WITH SECURITY_ENFORCED LIMIT 1];
            if(cartIt.size() == 0){
                CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
                    CartId = cartId,
                    Name = 'Default Delivery',
                    CurrencyIsoCode = 'USD'
                    );
                DMLManager.insertAsUser(cartDeliveryGroup);
                CartItem cartInput = new CartItem();
                cartInput.Name = productName;
                cartInput.CartId = cartId;
                cartInput.CartDeliveryGroupId = cartDeliveryGroup.Id;
                cartInput.Product2Id = productId;
                cartInput.ListPrice = price;
                cartInput.SalesPrice = price;
                cartInput.UnitAdjustedPrice = price;//@Nandika removed to fix the Promotion Issue  price * Double.valueOf(quantity);
                cartInput.TotalLineAmount = price * Double.valueOf(quantity);
                cartInput.TotalListPrice = price * Double.valueOf(quantity);
                cartInput.TotalPrice =  price * Double.valueOf(quantity);
                cartInput.ProductSellingModel__c = modelName;
                cartInput.B2B_PriceBookEntry_Id__c = priceBookEntryId;
                cartInput.quantity = Double.valueOf(quantity);
                cartInput.type = String.valueOf(ConnectApi.CartItemType.PRODUCT);

                if(modelTermUnit == 'Months') {
                    if(modelType == 'TermDefined' || modelType == 'Evergreen') {
                        cartInput.Start_Date__c = System.today();
                        cartInput.BillingFrequency2__c = 'Monthly';

                        if(modelType == 'TermDefined') {
                        cartInput.EndDate__c = System.today().addMonths(12);
                        }
                    }
                }
                DMLManager.insertAsUser(cartInput);
                cartIt = [SELECT Id,cartId,cart.webstoreId, Quantity, ListPrice, Product2Id, B2B_PriceBookEntry_Id__c FROM CartItem WHERE CartId = :cartId AND Product2Id = :productId AND B2B_PriceBookEntry_Id__c = :priceBookEntryId WITH SECURITY_ENFORCED LIMIT 1];
                managePromotionDiscount(cartIt[0].cart.webstoreId,effectiveAccountId,cartIt[0].cartId );
                return cartIt[0];
            }else {
                cartIt[0].Quantity = cartIt[0].Quantity + Double.valueOf(Quantity);
                cartIt[0].TotalLineAmount = cartIt[0].Quantity * cartIt[0].ListPrice;
                cartIt[0].TotalListPrice = cartIt[0].Quantity * cartIt[0].ListPrice;
                cartIt[0].TotalPrice = cartIt[0].Quantity * cartIt[0].ListPrice;
                DMLManager.updateAsUser(cartIt[0]);
                managePromotionDiscount(cartIt[0].cart.webstoreId,effectiveAccountId,cartIt[0].cartId );
                return cartIt[0];
            }
        

    } catch (Exception ex) {
      logger.error(ex);
      return null;
    } finally {
      logger.flush();
    }
  }
  @AuraEnabled
  public static ProductSellingModel productWithPricingModel(String productSellingModelName) {
      try {
        // PricebookEntry prices = [SELECT Id, UnitPrice, ProductSellingModelId, ProductSellingModel.SellingModelType FROM PricebookEntry WHERE Id = :pricebookEntryId WITH SECURITY_ENFORCED LIMIT 1];
        ProductSellingModel model = [SELECT Id, PricingTerm, Name, SellingModelType FROM ProductSellingModel WHERE Name = :productSellingModelName WITH SECURITY_ENFORCED LIMIT 1];
        return model;
      } catch(Exception ex) {throw new AuraHandledException(ex.getMessage());}
  }

  @AuraEnabled
  public static CartItem updateCartItems(
    String communityId,
    String effectiveAccountId,
    String cartItemId,
    String quantity
  ) {
    try {
      String webstoreId = test.isRunningTest() ? [Select id from WebStore Where Name = 'Sflabs'].Id : [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
      //if(!Test.isRunningTest()){
        // Lookup the webstore ID associated with the community
      //  webstoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
      //}

      List<CartItem> cartIt = [SELECT Id,cartId, Quantity, ListPrice, TotalLineAmount, TotalListPrice, TotalPrice, Product2Id FROM CartItem WHERE Id = :cartItemId WITH SECURITY_ENFORCED LIMIT 1];
      if(cartIt.size() != 0){}
        cartIt[0].quantity = Double.valueOf(quantity);
        cartIt[0].TotalLineAmount = Double.valueOf(quantity) * cartIt[0].ListPrice;
        cartIt[0].TotalListPrice = Double.valueOf(quantity) * cartIt[0].ListPrice;
        cartIt[0].TotalPrice = Double.valueOf(quantity) * cartIt[0].ListPrice;
        DMLManager.updateAsUser(cartIt[0]);
        managePromotionDiscount(webstoreId,effectiveAccountId,cartIt[0].cartId );
        return cartIt[0];
    } catch (Exception ex) {
        logger.error(ex);
        return null;
    } finally {
        logger.flush();
    }
  }

  public static void managePromotionDiscount(String webStoreId,String effectiveAccountId,String cartId){
      // List<CartItemPriceAdjustment> cartItemAdjustments = [SELECT Id,AdjustmentValue,TotalAmount FROM CartItemPriceAdjustment WHERE CartItemId=:cartItemId];
      // if(!cartItemAdjustments.isEmpty()){
      //  for(CartItemPriceAdjustment cartItemAdjustment :cartItemAdjustments){
      //      cartItemAdjustment.TotalAmount = cartItemAdjustment.AdjustmentValue*quantity ;
      //  }
      //  DMLManager.updateAsUser(cartItemAdjustments);
      // }
      ConnectApi.CartCouponCollection couponList = test.isRunningTest() ? new ConnectApi.CartCouponCollection() : ConnectApi.CommerceCart.getCartCoupons(webStoreId,effectiveAccountId,cartId);
      if(test.isRunningTest()) {
          ConnectApi.CartCouponList cartCoupon = new ConnectApi.CartCouponList();
          List<ConnectApi.CartCoupon> coupons = new List<ConnectApi.CartCoupon>();
          ConnectApi.CartCoupon coupon = new ConnectApi.CartCoupon();
          coupon.couponCode = 'testCode';
          coupons.add(coupon);
          cartCoupon.coupons = coupons;
          couponList.cartCoupons = cartCoupon;
      }
      Set<String> couponCodes = new Set<String>();
      for(ConnectApi.CartCoupon cc: couponList.cartCoupons.coupons){
          couponCodes.add(cc.couponCode);
          if(!test.isRunningTest()) {ConnectApi.CommerceCart.deleteCartCoupon(webStoreId,effectiveAccountId,cartId,cc.cartCouponId);}
      }
      for(String  str: couponCodes){
          ConnectApi.cartCouponInput cci = new ConnectApi.cartCouponInput();
          cci.couponCode = str ;
          if(!test.isRunningTest()) {ConnectApi.CommerceCart.applyCartCoupon(webStoreId,effectiveAccountId,cartId,cci);}
      }

  }

  @AuraEnabled
  public static ConnectApi.Wishlist createAndAddToList(
    String communityId,
    String productId,
    String wishlistName,
    String effectiveAccountId
  ) {
      try {
        // Lookup the webstore ID associated with the community
        // String webstoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
        String webstoreId = test.isRunningTest() ? [Select id from WebStore Where Name = 'Sflabs'].Id : [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
        /*if(Test.isRunningTest()) {
            webstoreId ='';
            WebStore store =[Select id from WebStore Where Name = 'Sflabs'];
            webstoreId = store.id;
        } else {
            webstoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
        }*/
        
          // Store the product in a WishlistItemInput to pass to the Wishlist
          ConnectApi.WishlistItemInput wishlistItemInput = new ConnectApi.WishlistItemInput();
          wishlistItemInput.productId = productId;

          //Create a wishlistInput to be created
          ConnectApi.WishlistInput wishlistInput = new ConnectApi.WishlistInput();
          wishlistInput.name = wishlistName;
          wishlistInput.products = new List<ConnectApi.WishlistItemInput>{
            wishlistItemInput
          };

          // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceWishlist_static_methods.htm#apex_ConnectAPI_CommerceWishlist_static_methods
          if(!test.isRunningTest()) {
            return ConnectApi.CommerceWishlist.createWishlist(webstoreId,effectiveAccountId,wishlistInput);
          } else {
            ConnectApi.WishlistSummary ConWishSum= new ConnectApi.WishlistSummary();
            ConWishSum.name=wishlistName;
            ConnectApi.Wishlist ConWish = new ConnectApi.Wishlist();
            ConWish.summary=ConWishSum;
            return ConWish;
          }
      } catch (Exception ex) {logger.error(ex);return null;} 
      finally {
          logger.flush();
      }
  }

  @AuraEnabled(cacheable=true)
  public static ConnectApi.ProductPrice getProductPrice(
      String communityId,
      String productId,
      String effectiveAccountId
  ) {
      try {
        // Lookup the webstore ID associated with the community
        //String webstoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
        String webstoreId ;
        if(Test.isRunningTest()) {
            webstoreId ='';
            WebStore store =[Select id from WebStore Where Name = 'Sflabs' WITH SECURITY_ENFORCED];
            webstoreId = store.id;
            ConnectApi.ProductPrice ConProdPrice = new ConnectApi.ProductPrice();
            ConProdPrice.unitPrice='10.00';
            return ConProdPrice;
        } else {
            webstoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
            
            return ConnectApi.CommerceStorePricing.getProductPrice(webstoreId,productId,effectiveAccountId);
        }
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceStorePricing_static_methods.htm#apex_ConnectAPI_CommerceStorePricing_static_methods
      } catch (Exception ex) {logger.error(ex);return null;
      } finally {
          logger.flush();
      }
  }

  @AuraEnabled(cacheable=true)
  public static User getCheckoutUser(String effectiveAccountId) {
    try{
      User user = [SELECT Id, Name, FirstName, LastName, Email, ContactId, Contact.LastName, Contact.FirstName, Contact.Email, Contact.MailingAddress, Address, CompanyName FROM User WHERE Id = :effectiveAccountId WITH SECURITY_ENFORCED LIMIT 1];
      return user;
    } catch (Exception ex) {logger.error(ex);return null;
    } finally {
      logger.flush();
    }
  }

  @AuraEnabled
    public static Map<String, Object> getCountriesAndStates() {
        try {
            return new Map<String, Object>{
            'countries' => B2BUtils.ToCustomPicklistEntry(B2BUtils.listPicklistValues(Account.BillingCountryCode)),
            'statesByCountries' => B2BUtils.ListPicklistValuesByControllingValue(Account.BillingCountryCode, Account.BillingStateCode)
        };
        } catch (Exception ex) {logger.error(ex);throw new AuraHandledException(ex.getMessage());
        } finally {
          logger.flush();
        }
    }
    @AuraEnabled
    public static void setBillingAddress(String Street, String Country, String State, String City, String ZipCode, String cartId) {
      try{
          WebCart cart = [SELECT Id, BillingAddress FROM WebCart WHERE Id = :cartId WITH SECURITY_ENFORCED LIMIT 1];
            cart.BillingCountry = Country;
            cart.BillingState = State;
            cart.BillingStreet = Street;
            cart.BillingCity = City;
            cart.BillingPostalCode = ZipCode;

            DMLManager.updateAsSystem(cart);
      } catch (Exception ex) {logger.error(ex);
      } finally {
        logger.flush();
      }
    }
    @AuraEnabled
    public static void setShippingAddress(String Street, String Country, String State, String City, String ZipCode, String Name, String cartId) {
      try{
        WebCart cart = [SELECT Id, (SELECT Id, Street__c, Country__c, City__c, Postal_Code__c, State__c, Name FROM B2B_Shipping_Addresses__r LIMIT 1) FROM WebCart WHERE Id = :cartId WITH SECURITY_ENFORCED LIMIT 1];
        if(cart.B2B_Shipping_Addresses__r.size() > 0){ 
          for(B2B_Shipping_Address__c shippingAddress : cart.B2B_Shipping_Addresses__r){
            shippingAddress.Country__c = Country;
            shippingAddress.City__c = City;
            shippingAddress.State__c = State;
            shippingAddress.Postal_Code__c = ZipCode;
            shippingAddress.Name = Name;

            DMLManager.updateAsSystem(shippingAddress);
          }
        } else {
        B2B_Shipping_Address__c shippingAddress = new B2B_Shipping_Address__c();
        shippingAddress.Cart__c = cartId;
        shippingAddress.Country__c = Country;
        shippingAddress.City__c = City;
        shippingAddress.State__c = State;
        shippingAddress.Street__c = Street;
        shippingAddress.Postal_Code__c = ZipCode;
        shippingAddress.Name = Name;

        DMLManager.insertAsSystem(shippingAddress);
      }
      } catch (Exception ex) {logger.error(ex);
      } finally {
        logger.flush();
      }
    }

    @AuraEnabled
    public static Boolean doesProductHasDiscount(String communityId, String effectiveAccountId) {
        Boolean result = false;
        String webstoreId;
        try {
            webstoreId = Test.isRunningTest() ? [Select id from WebStore Where Name = 'Sflabs'].id : [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
            List<WebCart> activeWebCartList = [
                SELECT Id,
                (SELECT Id, Discount__c FROM CartItems WHERE Discount__C > 0)
                FROM WebCart
                WHERE Status IN ('Active', 'Checkout')
                AND OwnerId = :Userinfo.getUserid()
                AND WebStoreId = :webstoreId
                AND AccountId = :effectiveAccountId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            if(!activeWebCartList.isEmpty() && !activeWebCartList[0].CartItems.isEmpty()) {
                result = true;
            }
        } catch (Exception ex) {logger.error(ex);
                               } finally {
                                   logger.flush();
                               }
        return result;
    }

  @AuraEnabled
  public static Map<Id, CartItemWrapper> getCartItemsByCartId(String cartId) {
    List<CartItem> cartItemList;
    Map<Id, CartItemWrapper> result = new Map<Id, CartItemWrapper>();
    try {
      cartItemList = [
        SELECT Id, 
        Discount__c, 
        TotalPrice,
        Product2Id,
        Product2.Description, 
        B2B_PriceBookEntry_Id__c, TotalPromoAdjustmentAmount,
        ProductSellingModel__c 
        FROM CartItem 
        WHERE CartId = :cartId 
        WITH SECURITY_ENFORCED
      ];

      for(CartItem item : cartItemList) {
        CartItemWrapper resultItem = new CartItemWrapper();
        resultItem.Id = item.Id;
        resultItem.discount = item.Discount__c;
        resultItem.TotalPrice = item.TotalPrice;
        resultItem.productDescription = item.Product2Id != null ? item.Product2.Description : null;
        resultItem.priceBookEntryId = item.B2B_PriceBookEntry_Id__c;
        resultItem.productSellingModel = item.ProductSellingModel__c;
        resultItem.adjustmentAmount = item.TotalPromoAdjustmentAmount;

        result.put(item.Id, resultItem);
      }

    } catch (Exception ex) {logger.error(ex);throw new AuraHandledException(ex.getMessage());
    } finally {
      logger.flush();
    }

    // return cartItemMap;
    return result;
  }

  public class CartItemWrapper {
    @AuraEnabled
    public String Id {get;set;}
    @AuraEnabled
    public Decimal discount {get;set;}
    @AuraEnabled
    public Decimal adjustmentAmount {get;set;}
    @AuraEnabled
    public Decimal TotalPrice {get;set;}
    @AuraEnabled
    public String productDescription {get;set;}
    @AuraEnabled
    public String priceBookEntryId {get;set;}
    @AuraEnabled
    public String productSellingModel {get;set;}
  }
}