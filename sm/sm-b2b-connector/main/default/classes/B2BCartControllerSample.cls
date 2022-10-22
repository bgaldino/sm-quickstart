/**
 * @description Demonstrates how to make Apex calls to ConnectApi.CommerceCart class
 * to perform Cart Operations for B2B Commerce on Lightning.
 *
 * @see B2BUtils
 */
public with sharing class B2BCartControllerSample {
  private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.CHECKOUT_FLOW);
  /**
   * @description Demonstrates how to call ConnectApi.CommerceCart.getCartItems
   * @param  communityId The Id of the community from which the call originated
   * @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
   * @param activeCartOrId ID of the cart, active, or current.
   * @param pageParam Specifies the page token to be used to view a page of information.
   * @param sortParam Sort order for items in a cart.
   * @return CartItemCollection A collection of cart items
   */
  @AuraEnabled
  public static ConnectApi.CartItemCollection getCartItems(
    String communityId,
    String effectiveAccountId,
    String activeCartOrId,
    String pageParam,
    String sortParam
  ) {
    try {
      // Lookup the webstore ID associated with the community
      // String webstoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
      String webStoreId;
      if(Test.isRunningTest()) {
      webStoreId = ''; // B2BTestFactory.getwebStoreId();
      WebStore wstore = [SELECT Id FROM WebStore WHERE Name = 'Sflabs' LIMIT 1];
      webStoreId = wstore.Id;
      } else {
        webStoreId = [
          SELECT WebStoreId
          FROM WebStoreNetwork
          WHERE NetworkId = :communityId
          WITH SECURITY_ENFORCED
          LIMIT 1
        ].WebStoreId;
      }
      // Get the ConnectApi.CartItemSortOrder enum value from string.
      // For the list of possible values, see:
      // see https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/connectAPI_enums.htm#cartItemSortOrderEnum
      ConnectApi.CartItemSortOrder resolvedSortParam = B2BUtils.resolveSortParam(
        sortParam
      );

      // For more details, see:
      // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
      return ConnectApi.CommerceCart.getCartItems(
        webstoreId,
        effectiveAccountId,
        activeCartOrId,
        pageParam,
        resolvedSortParam
      );
    } catch (Exception ex) {
      logger.error(ex);
      return null;
    } finally {
      logger.flush();
    }
  }

  @AuraEnabled
  public static List<CartItem> getCartItemsFields(
    String communityId,
    String effectiveAccountId,
    String activeCartOrId,
    String pageParam,
    String sortParam
  ) {
      List<CartItem> cartitems = [SELECT Id, cartId, Product2Id, Product2.Name, Quantity, TotalAdjustmentAmount, TotalAmount, TotalListPrice, TotalPrice, Type, unitAdjustedPrice, unitAdjustmentAmount, AdjustmentAmount, B2B_PriceBookEntry_Id__c, ListPrice, SalesPrice, TotalLineAmount, ProductSellingModel__c FROM CartItem WHERE cartId =: activeCartOrId AND Type != 'Charge'];
      return cartitems;
  }

  /**
   * @description Demonstrates how to call ConnectApi.CommerceCart.updateCartItem
   * @param  communityId The Id of the community from which the call originated
   * @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
   * @param activeCartOrId ID of the cart, active, or current.
   * @param cartItemId ID of the cart item to be updated.
   * @return CartItem The updated cart item
   */
  @AuraEnabled
  public static ConnectApi.CartItem updateCartItem(
    String communityId,
    String effectiveAccountId,
    String activeCartOrId,
    String cartItemId,
  //  String quantity
    ConnectApi.CartItemInput cartItem
  ) {
    try {
      // Lookup the webstore ID associated with the community
      // String webstoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId LIMIT 1].WebStoreId;
      String webStoreId;
      if(Test.isRunningTest()) {
        webStoreId = ''; // B2BTestFactory.getwebStoreId();
        WebStore wstore = [SELECT Id FROM WebStore WHERE Name = 'Sflabs' LIMIT 1];
        webStoreId = wstore.Id;
      } else {
        webStoreId = [
          SELECT WebStoreId
          FROM WebStoreNetwork
          WHERE NetworkId = :communityId
          WITH SECURITY_ENFORCED
          LIMIT 1
        ].WebStoreId;
      }
      // ConnectApi.CartItemInput cartItem = new ConnectApi.CartItemInput();
      // cartItem.quantity = quantity;
      // For more details, see:
      // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
      return ConnectApi.CommerceCart.updateCartItem(
        webstoreId,
        effectiveAccountId,
        activeCartOrId,
        cartItemId,
        cartItem
      );
    } catch (Exception ex) {
      logger.error(ex);
      return null;
    } finally {
      logger.flush();
    }
  }

  /**
   * @description Demonstrates how to call ConnectApi.CommerceCart.deleteCartItem
   * @param  communityId The Id of the community from which the call originated
   * @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
   * @param activeCartOrId ID of the cart, active, or current.
   * @param cartItemId ID of the cart item to be deleted.
   */
  @AuraEnabled
  public static void deleteCartItem(
    String communityId,
    String effectiveAccountId,
    String activeCartOrId,
    String cartItemId
  ) {
    try {
      // Lookup the webstore ID associated with the community
      //  String webstoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
      String webStoreId;
      if(Test.isRunningTest()) {
        webStoreId = ''; // B2BTestFactory.getwebStoreId();
        WebStore wstore = [SELECT Id FROM WebStore WHERE Name = 'Sflabs' LIMIT 1];
        webStoreId = wstore.Id;
      } else {
        webStoreId = [
          SELECT WebStoreId
          FROM WebStoreNetwork
          WHERE NetworkId = :communityId
          WITH SECURITY_ENFORCED
          LIMIT 1
        ].WebStoreId;
      }
      // For more details, see:
      // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
      ConnectApi.CommerceCart.deleteCartItem(
        webstoreId,
        effectiveAccountId,
        activeCartOrId,
        cartItemId
      );
    } catch (Exception ex) {
      logger.error(ex);
    } finally {
      logger.flush();
    }
  }

  /**
   * @description Demonstrates how to call ConnectApi.CommerceCart.getCartSummary
   * @param  communityId The Id of the community from which the call originated
   * @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
   * @param activeCartOrId ID of the cart, active, or current.
   */
  @AuraEnabled
  public static ConnectApi.CartSummary getCartSummary(
    String communityId,
    String effectiveAccountId,
    String activeCartOrId
  ) {
    try {
      // Lookup the webstore ID associated with the community
      //  String webstoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
      String webStoreId;
      if(Test.isRunningTest()){
        webStoreId = '';// B2BTestFactory.getwebStoreId();
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
      // For more details, see:
      // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
      return ConnectApi.CommerceCart.getCartSummary(
        webstoreId,
        effectiveAccountId,
        activeCartOrId
      );
    } catch (Exception ex) {
      logger.error(ex);
      return null;
    } finally {
      logger.flush();
    }
  }

  @AuraEnabled
  public static OrderSummary getOrderSummary(String orderSummaryId) {
      try{
        OrderSummary orderSummary = [SELECT Id, OriginalOrderId, OriginalOrder.OrderNumber, OriginalOrder.smOrder__r.OrderNumber, TotalAmount, TotalAdjustedProductAmount, TotalTaxAmount, GrandTotalAmount, OrderProductLineCount, CurrencyIsoCode, TotalAdjDistAmount FROM OrderSummary WHERE Id = :orderSummaryId LIMIT 1];
        return orderSummary;
      } catch (Exception ex) {
        logger.error(ex);
        return null;
      } finally {
        logger.flush();
      }  
  }

  @AuraEnabled
    public static List<OrderItem> getOrderItemsByOrderSummaryId(String orderSummaryId) {
        try{
          OrderSummary orderSummary = [SELECT Id, OriginalOrderId FROM OrderSummary WHERE Id = :orderSummaryId LIMIT 1];
          List<OrderItem> orderItems = [SELECT Id, TotalPrice, Product2.Name, UnitPrice, Type, TypeCode,ProductSellingModelId, ProductSellingModel.SellingModelType, ProductSellingModel.Name FROM OrderItem WHERE OrderId = :orderSummary.OriginalOrderId AND TypeCode != 'Charge'];
          return orderItems;
        } catch (Exception ex) {
          logger.error(ex);
          return null;
        } finally {
          logger.flush();
        } 
    }

  /**
   * @description Demonstrates how to call ConnectApi.CommerceCart.createCart
   * @param  communityId The Id of the community from which the call originated
   * @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
   */
  @AuraEnabled
  public static ConnectApi.CartSummary createCart(
    String communityId,
    String effectiveAccountId
  ) {
    try {
      // Lookup the webstore ID associated with the community
      //String webstoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
      String webStoreId;
      if(Test.isRunningTest()) {
        webStoreId = '';// B2BTestFactory.getwebStoreId();
        WebStore wstore = [SELECT Id FROM WebStore WHERE Name = 'Sflabs' LIMIT 1];
        webStoreId = wstore.Id;
      } else {
        webStoreId = [
          SELECT WebStoreId
          FROM WebStoreNetwork
          WHERE NetworkId = :communityId
          WITH SECURITY_ENFORCED
          LIMIT 1
        ].WebStoreId;
      }
      ConnectApi.CartInput cartInput = new ConnectApi.CartInput();
      cartInput.effectiveAccountId = effectiveAccountId;
      // For more details, see:
      // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
      return ConnectApi.CommerceCart.createCart(webstoreId, cartInput);
    } catch (Exception ex) {
      logger.error(ex);
      return null;
    } finally {
      logger.flush();
    }
  }

  /**
   * @description Demonstrates how to call ConnectApi.CommerceCart.deleteCart
   * @param  communityId The Id of the community from which the call originated
   * @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
   * @param activeCartOrId ID of the cart, active, or current.
   */
  @AuraEnabled
  public static void deleteCart(
    String communityId,
    String effectiveAccountId,
    String activeCartOrId
  ) {
    try {
      // Lookup the webstore ID associated with the community
      // String webstoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
      String webStoreId;
      if(Test.isRunningTest()) {
        webStoreId = ''; // B2BTestFactory.getwebStoreId();
        WebStore wstore = [SELECT Id FROM WebStore WHERE Name = 'Sflabs' LIMIT 1];
        webStoreId = wstore.Id;
      } else {
        webStoreId = [
          SELECT WebStoreId
          FROM WebStoreNetwork
          WHERE NetworkId = :communityId
          WITH SECURITY_ENFORCED
          LIMIT 1
        ].WebStoreId;
      }
      // For more details, see:
      // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
      ConnectApi.CommerceCart.deleteCart(
        webstoreId,
        effectiveAccountId,
        activeCartOrId
      );
    } catch (Exception ex) {
      logger.error(ex);
    } finally {
      logger.flush();
    }
  }
}