public with sharing class RSM_Utils {
  private static final DCM_Logger logger = DCM_Logger.getImmediateInstance('Utility');
  private static Map<String,SObjectType> globalDescribe = Schema.getGlobalDescribe();
  
  public static String getAllObjectFields(String sObjectName) {
    return getAllObjectFields(sObjectName, null);
  }

  public static string getNameSpace() {
    return B2B_Constants.class.getName().substringBefore('B2B_Constants').removeEnd('.');
  }

  public static string getNameSpacePrefix() {
      return getNameSpace() + '__';
  }

  public static String getAllObjectFields(String sObjectName, Set<String> excludeFields) {
      Schema.SObjectType targetType = globalDescribe.get(sObjectName);
      Set<String> fieldList = targetType.getDescribe().fields.getMap().keySet();
      if (excludeFields != null) fieldList.removeAll(excludeFields);
      String allFields = String.join(new List<String>(fieldList), ', ');
      system.debug('---allFields---'+allFields);
      return allFields;
  }
/**
    * Method used to get Cart Details By Cart Id
    * @param Id cartId
    */
    public Static WebCart getCartDetails(Id cartId){
      Set<Id> setCartId = new Set<Id>();
      setCartId.add(cartId);

      List<WebCart> cartDetailsLst = new List<WebCart>();

      //String soql = 'SELECT ' + RSM_Utils.getAllObjectFields(String.valueOf(WebCart.getSObjectType())) +
      String soql = 'SELECT id, ownerid, isdeleted, name, currencyisocode, createddate, createdbyid, lastmodifieddate, lastmodifiedbyid, systemmodstamp, webstoreid, accountid, status, type, issecondary, isrepricingneeded, lastrepricingdate, ponumber, billingstreet, billingcity, billingstate, billingpostalcode, billingcountry, billingstatecode, billingcountrycode, billinglatitude, billinglongitude, billinggeocodeaccuracy, billingaddress, totallistamount, totalproductamount, totalproducttaxamount, totalchargeamount, totalchargetaxamount, totalpromoadjustmentamount, totalpromoadjustmenttaxamount, totaladjustmentamount, totalamount, totaltaxamount, totalamountafteralladjustments, grandtotalamount, totalproductcount, uniqueproductcount, totallineitemswitherrors, guestphonenumber, guestemailaddress, guestfirstname, guestlastname, guestsecondname, b2b_pricebook_id__c, cart_type__c, contract__c, jobid__c, total_discount__c'+
      ' FROM ' + String.valueOf(WebCart.getSObjectType()) +
      ' WHERE Id IN :setCartId';
      if(!Test.isRunningTest()) {
        soql += ' WITH SECURITY_ENFORCED';
      }
      cartDetailsLst = Database.query(soql);
      System.debug('cartDetailsLst 123-----'+cartDetailsLst);
      System.debug('setCartId-----'+setCartId);
      return cartDetailsLst != null ? cartDetailsLst[0]:null;
  }
  
 

   /**
   * Method used to get Cart Items Details By Cart Id
   * @param  Id cartId
   */
  public Static List<cartItem> getCartItemsByCartId(Id cartId){
      Set<Id> setCartId = new Set<Id>();
      setCartId.add(cartId);

      List<cartItem> lstCartItems = new List<cartItem>();

      //String soql = 'SELECT ' + RSM_Utils.getAllObjectFields(String.valueOf(cartItem.getSObjectType())) +
      String soql = 'SELECT id, isdeleted, name, currencyisocode, createddate, createdbyid, lastmodifieddate, lastmodifiedbyid, systemmodstamp, cartid, cartdeliverygroupid, product2id, type, sku, quantity, listprice, salesprice, unitadjustmentamount, unitadjustedprice, totallistprice, totallineamount, totallinetaxamount, adjustmentamount, adjustmenttaxamount, totalprice, itemizedadjustmentamount, itemizedadjustmenttaxamount, distributedadjustmentamount, distributedadjustmenttaxamount, totalpromoadjustmentamount, totalpromoadjustmenttaxamount, totaladjustmentamount, totalpriceafteralladjustments, totaltaxamount, totalamount, b2b_amend_product_quantity__c, b2b_external_list_price__c, b2b_external_unit_price__c, b2b_pricebookentry_id__c, b2b_recurring_price__c, b2b_renewal_uplift__c, b2b_upfront_price__c, b2b_upfront__c, b2b_uplift__c, billingfrequency2__c, discount__c, enddate__c, original_quantity__c, productsellingmodel__c, start_date__c, subscription__c'+
      ' FROM ' + String.valueOf(cartItem.getSObjectType()) +
      ' WHERE CartId IN :setCartId';
      if(!Test.isRunningTest()) {
        soql += ' WITH SECURITY_ENFORCED';
      }
      lstCartItems = Database.query(soql);

      return lstCartItems;
  }

  public static void callFlow(String flowName, Map <String, Object> inputMap) {
    logger.info('Calling flow: ' + flowName);
    Flow.Interview dynamicInterview = Flow.Interview.createInterview(flowName, inputMap);
    dynamicInterview.start();
    logger.info('Flow: ' + flowName + ' started');
  }

}