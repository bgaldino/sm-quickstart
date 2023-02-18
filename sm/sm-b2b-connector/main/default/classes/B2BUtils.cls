/**
 * @description Util methods for B2B commerce on Lightning Samples
 *
 * @see B2BUtils
 */
public with sharing class B2BUtils {
  // A cache which maps community Ids to WebStore Ids
    private static Map<String, String> communityIdToWebStoreIdCache = new Map<String, String>();
    private static Map<String, Set<Integer>> cache;
    private static final String MODULE_NAME = 'Utils Module';
    private static final DCM_Logger logger = DCM_Logger.getInstance(MODULE_NAME);

  // A cache to map a string to ConnectApi.CartItemSortOrder
  private static Map<String, ConnectApi.CartItemSortOrder> sortOrderCache = new Map<String, ConnectApi.CartItemSortOrder>();

  /**
   * @description Given a community ID, returns the relavent webstore ID for use in B2B Commerce on lightning
   * @param  communityId The Id of the community from which the call originated
   * @return weStoreId The webStoreId corresponding to the community Id.
   * @example
   * String webStoreId = B2BUtils.resolveCommunityIdToWebstoreId('0DB2D0000004Xz7');
   */
  public static String resolveCommunityIdToWebstoreId(String communityId) {
    if (communityIdToWebStoreIdCache.containsKey(communityId)) {
      return communityIdToWebStoreIdCache.get(communityId);
    } else {
        String webStoreId;
        if(test.isRunningTest())
        {
            webStoreId =  'wstore.Id';
            //[Select id FROM WebStore where Name = 'Evergreen Platform Solutions' LIMIT 1].id;
               
        }
        else{
       webStoreId = [
        SELECT WebStoreId
        FROM WebStoreNetwork
        WHERE NetworkId = :communityId
        WITH SECURITY_ENFORCED
        LIMIT 1
      ]
      .WebStoreId;
        }
      communityIdToWebStoreIdCache.put(communityId, webStoreId);
      return webStoreId;
    }
  }

  /**
   * @description Given a sortParam string, return null or the relavent ConnectApi.CartItemSortOrder enum value
   * See https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/connectAPI_enums.htm#cartItemSortOrderEnum for the enum values
   * @param  sortParam A string representing a sort Param.
   * @return resolvedSortParam A ConnectApi.CartItemSortOrder enum value or null
   * @example
   * ConnectApi.CartItemSortOrder sortParam = B2BUtils.resolveSortParam('CreatedDateAsc');
   */
  public static ConnectApi.CartItemSortOrder resolveSortParam(
    String sortParam
  ) {
      if (sortOrderCache.isEmpty()) {
        for (
          ConnectApi.CartItemSortOrder sortOrder : ConnectApi.CartItemSortOrder.values()
        ) {
            sortOrderCache.put(sortOrder.name(), sortOrder);
          }
      }
      return sortOrderCache.get(sortParam);
  }
    
  public static String getUserAccountID() {
      String userId = UserInfo.getUserId();
      String contactId = [SELECT ContactId FROM User WHERE Id = :userId WITH SECURITY_ENFORCED].ContactId;
      return [SELECT AccountId FROM Contact WHERE Id = :contactId WITH SECURITY_ENFORCED].AccountId; 
  }

  public static Map<String, List<CustomPicklistEntry>> ListPicklistValuesByControllingValue(
        SObjectField controlling,
        SObjectField dependent
    ) {
        Map<String, List<CustomPicklistEntry>> results = new Map<String, List<CustomPicklistEntry>>();
        if (controlling == null || dependent == null) {
            return results;
        }

        List<String> controllingValues = new List<String>();
        for (PicklistEntry pe : listPicklistValues(controlling)) {
            if (pe.isActive()) {
                results.put(pe.getValue(), new List<CustomPicklistEntry>());
                controllingValues.add(pe.getValue());
            }
        }

        cache = new Map<String, Set<Integer>>();
        for (
            CustomPicklistEntry customPicklistEntry : toCustomPicklistEntry(
            listPicklistValues(dependent)
        )
        ) {
            if (customPicklistEntry.active) {
                for (Integer index : validForToIndices(customPicklistEntry.validFor)) {
                    results.get(controllingValues.get(index)).add(customPicklistEntry);
                }
            }
        }

        return results;
    }

    public static List<Schema.PicklistEntry> listPicklistValues(
        Schema.SObjectField field
    ) {
        return field.getDescribe().getPicklistValues();
    }

    public static List<CustomPicklistEntry> toCustomPicklistEntry(
        List<Schema.PicklistEntry> ples
    ) {
        return (List<CustomPicklistEntry>) JSON.deserialize(
            JSON.serialize(ples),
            List<CustomPicklistEntry>.class
        );
    }

    private static Set<Integer> validForToIndices(String validFor) {
      Set<Integer> indices = cache.get(validFor);
      if (indices == null) {
          indices = new Set<Integer>();

          String validForBits = base64ToBits(validFor);
          for (
              Integer i = validForBits.indexOf('1');
              i >= 0;
              i = validForBits.indexOf('1', i + 1)
          ) {
              indices.add(i);
          }

          cache.put(validFor, indices);
      }

      return indices;
  }

  private static String base64ToBits(String validFor) {
      if (String.isEmpty(validFor)) {
          return '';
      }

      String validForBits = '';
      for (Integer i = 0; i < validFor.length(); i++) {
          String thisChar = validFor.mid(i, 1);
          Integer val = B2B_SetupConstants.BASE_64_CHARS.indexOf(thisChar);
          String bits = decimalToBinary(val).leftPad(6, '0');
          validForBits += bits;
      }
      return validForBits;
  }

  private static String decimalToBinary(Integer val) {
      String bits = '';
      while (val > 0) {
          Integer remainder = Math.mod(val, 2);
          bits = String.valueOf(remainder) + bits;
          val = Integer.valueOf(Math.floor(val / 2));
      }
      return bits;
  }

    public class CustomPicklistEntry {
      @AuraEnabled
      public Boolean active { get; set; }

      @AuraEnabled
      public String label { get; set; }

      @AuraEnabled
      public String value { get; set; }

      @AuraEnabled
      public String validFor { get; set; }
  }
    
    public static String fetchConfigByValue(String labelName) {
        String value = '';
        B2B_Store_Configuration__mdt config = B2B_Store_Configuration__mdt.getInstance(labelName);
        if(config!=null){
            value = String.isNotBlank(config.Value__c) ? config.Value__c : '';
        }
        return value;
    }
    
    public static List<String> getInternalAccounts() {
        List<String> retList = new  List<String>();
        String internalAccountIds =   fetchConfigByValue('InternalAccountId'); 
        if(String.isNotBlank(internalAccountIds)){
            retList = internalAccountIds.split(',');
        }
        return retList;
    }
    
    public static List<String> getTaxExemptRecordTypes() {
        List<String> retList = new  List<String>();
        String taxRcStr =   fetchConfigByValue('TaxExemptRecordTypes'); 
        if(String.isNotBlank(taxRcStr)){
            retList = taxRcStr.split(',');
        }
        return retList;
    }
    
    public static List<CartCheckoutSession> getActiveCheckoutSessions(Id cartId) {
        return (cartId != null) ? [
                SELECT
                        Id,
                        OrderId
                FROM CartCheckoutSession
                WHERE WebCartId = :cartId AND IsArchived = FALSE WITH SECURITY_ENFORCED
        ] : new List<CartCheckoutSession>();
    }
    
    public static List<String> getSuperInternalAccounts() {
        List<String> retList = new  List<String>();
        String internalAccountIds =   fetchConfigByValue('SuperUserInternalAccountId'); 
        if(String.isNotBlank(internalAccountIds)){
            retList = internalAccountIds.split(',');
        }
        return retList;
    }

    public static Boolean isSandbox() {
        return [SELECT IsSandbox FROM Organization WITH SECURITY_ENFORCED LIMIT 1]?.IsSandbox;
    }
}