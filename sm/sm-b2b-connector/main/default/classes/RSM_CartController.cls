/**
 * @description Demonstrates how to make Apex calls to ConnectApi.CommerceCart class
 * to perform Cart Operations for B2B Commerce on Lightning.
 *
 * @see B2BUtils
 */
public with sharing class RSM_CartController {
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
  public static List<CartItemWrapper> getCartItemsFields(
    String communityId,
    String effectiveAccountId,
    String activeCartOrId,
    String pageParam,
    String sortParam
  ) {
      List<CartItem> cartitems = [
        SELECT 
        Id, 
        cartId, 
        Product2Id, 
        Product2.Name, 
        Quantity, 
        TotalAdjustmentAmount, 
        TotalAmount, 
        TotalListPrice, 
        TotalPrice, 
        Type, 
        unitAdjustedPrice, 
        unitAdjustmentAmount, 
        AdjustmentAmount, 
        B2B_PriceBookEntry_Id__c, 
        ListPrice, 
        SalesPrice, 
        TotalLineAmount, 
        ProductSellingModel__c 
        FROM CartItem 
        WHERE cartId = :activeCartOrId
        AND Type != 'Charge'
        WITH SECURITY_ENFORCED
      ];

      List<CartItemWrapper> result = new List<CartItemWrapper>();
      for(CartItem item : cartItems) {
        CartItemWrapper resultItem = new CartItemWrapper();

        resultItem.id = item.Id;
        resultItem.cartId = item.cartId;
        resultItem.product2Id = item.Product2Id;
        resultItem.product2Name = item.Product2.Name;
        resultItem.quantity = item.Quantity;
        resultItem.totalAdjustmentAmount = item.TotalAdjustmentAmount;
        resultItem.totalAmount = item.TotalAmount;
        resultItem.TotalListPrice = item.TotalListPrice;
        resultItem.TotalPrice = item.TotalPrice;
        resultItem.type = item.Type;
        resultItem.unitAdjustedPrice = item.unitAdjustedPrice;
        resultItem.unitAdjustmentAmount = item.unitAdjustmentAmount;
        resultItem.adjustmentAmount = item.AdjustmentAmount;
        resultItem.priceBookEntryId = item.B2B_PriceBookEntry_Id__c;
        resultItem.listPrice = item.ListPrice;
        resultItem.salesPrice = item.SalesPrice;
        resultItem.totalLineAmount = item.TotalLineAmount;
        resultItem.productSellingModel = item.ProductSellingModel__c;

        result.add(resultItem);
      }

      return result;
      //return cartitems;
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
  public static OrderSummaryWrapper getOrderSummary(String orderSummaryId) {
    OrderSummaryWrapper result = new OrderSummaryWrapper();
      try{
        OrderSummary orderSummary = [
          SELECT Id, 
          // OriginalOrderId, 
          OriginalOrder.OrderNumber, 
          OriginalOrder.smOrder__r.OrderNumber, 
          OriginalOrder.smOrder__r.TotalTaxAmount, 
          // TotalAmount,
          TotalAdjustedProductAmount, 
          TotalTaxAmount, 
          GrandTotalAmount,
          TotalAdjustedDeliveryAmount,
          // OrderProductLineCount, 
          CurrencyIsoCode
          // TotalAdjDistAmount 
          FROM OrderSummary 
          WHERE Id = :orderSummaryId
          WITH SECURITY_ENFORCED 
          LIMIT 1
        ];

        result.Id = orderSummary.Id;
        //result.TotalTaxAmount = orderSummary.OriginalOrder.smOrder__r.TotalTaxAmount;
        result.TotalTaxAmount = orderSummary.TotalTaxAmount;
        result.TotalAdjustedProductAmount = orderSummary.TotalAdjustedProductAmount;
        result.GrandTotalAmount = orderSummary.GrandTotalAmount;
        result.CurrencyIsoCode = orderSummary.CurrencyIsoCode;
        result.ShippingCost = orderSummary.TotalAdjustedDeliveryAmount;
        //result.OrderNumber = orderSummary.OriginalOrder.smOrder__r.OrderNumber;
        result.OrderNumber = orderSummary.OriginalOrder.OrderNumber;
        // return orderSummary;
      } catch (Exception ex) {
        logger.error(ex);
        throw new AuraHandledException(ex.getMessage());
        // return null;
      } finally {
        logger.flush();
      }

      return result;
  }

  @AuraEnabled
    public static List<OrderItem> getOrderItemsByOrderSummaryId(String orderSummaryId) {
        try{
          OrderSummary orderSummary = [
            SELECT OriginalOrderId 
            FROM OrderSummary 
            WHERE Id = :orderSummaryId 
            WITH SECURITY_ENFORCED
            LIMIT 1
          ];

          List<OrderItem> orderItems = [
            SELECT Id, 
            TotalPrice, 
            TotalTaxAmount, 
            Product2.Name, RoundedLineAmount,
            UnitPrice, ListPrice, NetUnitPrice,
            Type, 
            TypeCode,
            ProductSellingModelId, 
            ProductSellingModel.SellingModelType, 
            ProductSellingModel.Name 
            FROM OrderItem 
            WHERE OrderId = :orderSummary.OriginalOrderId 
            AND TypeCode != 'Charge'
            WITH SECURITY_ENFORCED
          ];

          return orderItems;
        } catch (Exception ex) {
          logger.error(ex);
          throw new AuraHandledException(ex.getMessage());
          // return null;
        } finally {
          logger.flush();
        } 
    }

  @AuraEnabled
  public static Decimal getOrderTaxAmount(String cartId){
    List<Order> orderList;
    try {
      orderList = [
        SELECT TotalTaxAmount
        FROM Order
        WHERE Cart__c = :cartId
        AND Order_Type__c = 'SM Order'
        WITH SECURITY_ENFORCED
        LIMIT 1
      ];      
    } catch (Exception ex) {
      logger.error(ex);
      throw new AuraHandledException(ex.getMessage());
    } finally {
      logger.flush();
    }

    return orderList.isEmpty() ? null : orderList[0].TotalTaxAmount;
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

  @AuraEnabled
  public static void deleteOrderByCartId(String cartId){
    try {
      List<Order> orderList = [SELECT Id FROM Order WHERE Cart__c = :cartId WITH SECURITY_ENFORCED LIMIT 1];
      if(!orderList.isEmpty()) {
        List<OrderItem> orderItemList = [SELECT Id FROM OrderItem WHERE OrderId = :orderList[0].Id WITH SECURITY_ENFORCED];
        List<Id> orderItemIdList = new List<Id>();
        for(OrderItem orderItem : orderItemList) {
          orderItemIdList.add(orderItem.Id);
        }
        List<OrderItemTaxLineItem> orderTaxList = [SELECT Id FROM OrderItemTaxLineItem WHERE OrderItemId IN :orderItemIdList WITH SECURITY_ENFORCED];
        DMLManager.deleteAsUSer(orderTaxList);
      }
      //List<Order> orderList = [SELECT Id FROM Order WHERE Cart__c = :cartId WITH SECURITY_ENFORCED];
      //DMLManager.deleteAsUSer(orderList);
    } catch (Exception ex) {
      logger.error(ex);
      throw new AuraHandledException(ex.getStackTraceString());
    } finally {
      logger.flush();
    }
  }

  public class CartItemWrapper {
    @AuraEnabled
    public String id {get;set;}
    @AuraEnabled
    public String cartId {get;set;}
    @AuraEnabled
    public String product2Id {get;set;}
    @AuraEnabled
    public String product2Name {get;set;}
    @AuraEnabled
    public Decimal quantity {get;set;}
    @AuraEnabled
    public Decimal totalAdjustmentAmount {get;set;}
    @AuraEnabled
    public Decimal totalAmount {get;set;}
    @AuraEnabled
    public Decimal TotalListPrice {get;set;}
    @AuraEnabled
    public Decimal TotalPrice {get;set;}
    @AuraEnabled
    public String type {get;set;}
    @AuraEnabled
    public Decimal unitAdjustedPrice {get;set;}
    @AuraEnabled
    public Decimal unitAdjustmentAmount {get;set;}
    @AuraEnabled
    public Decimal adjustmentAmount {get;set;}
    @AuraEnabled
    public String priceBookEntryId {get;set;}
    @AuraEnabled
    public Decimal listPrice {get;set;}
    @AuraEnabled
    public Decimal salesPrice {get;set;}
    @AuraEnabled
    public Decimal totalLineAmount {get;set;}
    @AuraEnabled
    public String productSellingModel {get;set;}
  }

  public class OrderSummaryWrapper {
    @AuraEnabled
    public String Id {get;set;}
    @AuraEnabled
    public Decimal TotalTaxAmount {get;set;}
    @AuraEnabled
    public Decimal ShippingCost {get;set;}
    @AuraEnabled
    public Decimal TotalAdjustedProductAmount {get;set;}
    @AuraEnabled
    public Decimal GrandTotalAmount {get;set;}
    @AuraEnabled
    public String CurrencyIsoCode {get;set;}
    @AuraEnabled
    public String OrderNumber {get;set;}
  }
}