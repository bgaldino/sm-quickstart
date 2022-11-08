public without sharing class RSM_Utils {
    private static final DCM_Logger logger = DCM_Logger.getImmediateInstance('Utility');
    private static Map<String,SObjectType> globalDescribe = Schema.getGlobalDescribe();
  
  public static String getAllObjectFields(String sObjectName) {
    return getAllObjectFields(sObjectName, null);
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

      String soql = 'SELECT ' + RSM_Utils.getAllObjectFields(String.valueOf(WebCart.getSObjectType())) +
      ' FROM ' + String.valueOf(WebCart.getSObjectType()) +
      ' WHERE Id IN :setCartId';
      cartDetailsLst = Database.query(soql);
      System.debug('cartDetailsLst-----'+cartDetailsLst);
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

      String soql = 'SELECT ' + RSM_Utils.getAllObjectFields(String.valueOf(cartItem.getSObjectType())) +
      ' FROM ' + String.valueOf(cartItem.getSObjectType()) +
      ' WHERE CartId IN :setCartId';
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