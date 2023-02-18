/**
 * @description       :
 * @author            : Abhishek Walia
 * @group             : Docmation LLC
 * @last modified on  : 02-23-2022
 * @last modified by  : Abhishek Walia
 **/
public with sharing class B2BCartSelector {
  public static final String OBJECT_API_NAME = 'B2B_Store_Configuration__mdt';

  public static Set<String> getDefaultFields() {
    return new Set<String>{
      'Id',
      'Name',
      'WebStoreId',
      'OwnerId,Owner.FirstName,Owner.LastName,Owner.Email',
      'AccountId,Account.Name',
      'CurrencyIsoCode',
      'GrandTotalAmount',
      'TotalPromoAdjustmentAmount',
      'Status',
      'TotalTaxAmount','TotalAmount','TotalProductAmount',
      'PoNumber',
      '(SELECT Id,CurrencyIsoCode,Sku,Quantity,SalesPrice,ListPrice,TotalPrice,Product2Id,Product2.Name,Product2.ProductCode,Product2.DisplayUrl,Product2.isActive, AdjustmentAmount,  AdjustmentTaxAmount, CartDeliveryGroupId,  Name, TotalLineAmount, TotalListPrice, Type, UnitAdjustedPrice, UnitAdjustmentAmount, CartId FROM CartItems)'
    };
  }

  public static String getQueryFieldString() {
    List<String> queryFieldsList = new List<String>(getDefaultFields());
    System.debug('QueryFieldsList -> ' + queryFieldsList);
    return String.join(queryFieldsList, ',');
  }

  public static WebCart getCurrentActiveCart(String cartId) {
    List<String> statusList = new List<String>{
      B2BConstants.CART_ACTIVE,
      B2BConstants.CART_CHECKOUT,
      B2BConstants.CART_PROCESSING
    };
    String query;

        if(!Test.isRunningTest()) {
          query =
          ' SELECT ' +
          getQueryFieldString() +
          ' FROM WebCart WHERE Id=:cartId AND Status IN :statusList WITH SECURITY_ENFORCED LIMIT 1 ';
        } else {
          query =
          ' SELECT ' +
          getQueryFieldString() +
          ' FROM WebCart WHERE Id=:cartId AND Status IN :statusList LIMIT 1 ';
        }
    List<WebCart> webCartList = Database.query(query);

    if (!webCartList.isEmpty()) {
      return webCartList.get(0);
    } else {
      return null;
    }
  }

  public static WebCart getClosedCart(String cartId) {
    // Adding checkout status here based on the change done on 01/27/2022 by sathiya to bring the checkout status cart as well
    List<String> statusList = new List<String>{ B2BConstants.CART_CLOSED, B2BConstants.CART_CHECKOUT};
    String query =
      ' SELECT ' +
      getQueryFieldString() +
      ' FROM WebCart WHERE Id=:cartId AND Status IN :statusList LIMIT 1';
    List<WebCart> webCartList = Database.query(query);
    if (!webCartList.isEmpty()) {
      return webCartList.get(0);
    } else {
      return null;
    }
  }

  public static String getQueryWhereMetaData(Map<String, Object> mapParam) {
    String whereClause = '';

    if (
      mapParam.containsKey('ModuleName') &&
      String.IsNotBlank((String) mapParam.get('ModuleName'))
    ) {
      String key =
        '\'%' +
        String.escapeSingleQuotes((String) mapParam.get('ModuleName')) +
        '%\'';
      whereClause +=
        ' WHERE Module_Name__c = \'' +
        (String) mapParam.get('ModuleName') +
        '\'';
    }

    return whereClause;
  }

  public static List<B2B_Store_Configuration__mdt> getProductCategorie(
    Map<String, Object> mapParam
  ) {
    String query =
      ' SELECT Value__c FROM ' +
      OBJECT_API_NAME +
      ' ' +
      getQueryWhereMetaData(mapParam) +
      ' ORDER BY Module_Name__c, MasterLabel';
    system.debug('query ' + query);
    return Database.query(query);
  }
}