/**
 * @description       :
 * @author            : Prabhat Kumar
 * @group             :
 * @last modified on  : 05-20-2022
 * @last modified by  : Prabhat Kumar
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   05-20-2022   Prabhat Kumar  Initial Version
 **/
global with sharing class RSM_CancelAsset {
  private static final DCM_Logger logger = DCM_Logger.getInstance(
    B2B_SetupConstants.ASSET_CANCELLATION
  );
  /**
   * Reterive the information about next billing date and display on manage subscription page.
   *
   **/

   @AuraEnabled
  global static map<string, object> getNextBillingDate(id assetId) {
    Map<String, object> resultData = new Map<String, object>();
    try {
      List<Asset> billingSechd = new List<Asset>();

      if (Test.isRunningTest()) {
        billingSechd = [
          SELECT
            id,
            LifecycleStartDate,
            Name,
            Next_Billing_Date__c,
            CurrentQuantity,
            LifecycleEndDate
          FROM Asset
          WHERE Id = :assetId
          LIMIT 1
        ];
      } else {
        //removing WITH SECURITY_ENFORCED  because community user cant query on this object
        billingSechd = [
          SELECT
            id,
            LifecycleStartDate,
            Name,
            Next_Billing_Date__c,
            CurrentQuantity,
            LifecycleEndDate
          FROM Asset
          WHERE Id = :assetId
          LIMIT 1
        ];
      }

      if (billingSechd.size() > 0) {
        resultData.put('nextBillingDate', billingSechd[0].Next_Billing_Date__c);
        if (billingSechd[0].LifecycleEndDate != null) {
          resultData.put(
            'assetEndDate',
            billingSechd[0].LifecycleEndDate.addYears(1).addDays(-1)
          );
        }
        resultData.put('productName', billingSechd[0].Name);
        resultData.put('assetStartDate', billingSechd[0].LifecycleStartDate);
        resultData.put('totalQty', billingSechd[0].CurrentQuantity);
      }
    } catch (Exception e) {
      logger.error(e);
      throw new AuraHandledException(e.getMessage());
    } finally {
      logger.flush();
    }
    return resultData;
  }

/*   @AuraEnabled
  global static map<string, object> getNextBillingDate(id assetId) {
    Map<String, object> resultData = new Map<String, object>();
    try {
      List<BillingScheduleGroup> billingSechd = new List<BillingScheduleGroup>();
      if (Test.isRunningTest()) {
        billingSechd = [
          SELECT
            id,
            StartDate,
            ReferenceEntity.Name,
            EffectiveNextBillingDate,
            EndDate
          FROM BillingScheduleGroup
          WHERE ReferenceEntityId = :assetId
          LIMIT 1
        ];
      } else {
        //removing WITH SECURITY_ENFORCED  because community user cant query on this object
        billingSechd = [
          SELECT
            id,
            StartDate,
            //Total_Quantity__c,
            ReferenceEntity.Name,
            EffectiveNextBillingDate,
            EndDate
          FROM BillingScheduleGroup
          WHERE ReferenceEntityId = :assetId
          LIMIT 1
        ];
      }

      if (billingSechd.size() > 0) {
        resultData.put(
          'nextBillingDate',
          billingSechd[0].EffectiveNextBillingDate
        );
        if (billingSechd[0].EndDate != null) {
          resultData.put(
            'assetEndDate',
            billingSechd[0].EndDate.addYears(1).addDays(-1)
          );
        }

        //get the total quantity of Assets
        ////removing WITH SECURITY_ENFORCED  because community user cant query on this billingSchedulegroupId
        List<AggregateResult> billingShdQty = [
          SELECT sum(quantity) totalQuantity
          FROM BillingSchedule
          WHERE billingSchedulegroupId = :billingSechd[0].id
        ];

        resultData.put('productName', billingSechd[0].ReferenceEntity.Name);
        resultData.put('assetStartDate', billingSechd[0].StartDate);
        //resultData.put('totalQty', billingSechd[0].Total_Quantity__c);
        if (!billingShdQty.isEmpty()) {
          AggregateResult aggregateResult = billingShdQty[0];
          decimal totalQuantity = (decimal) aggregateResult.get(
            'totalQuantity'
          );
          System.debug('Total Quantity: ' + totalQuantity);
          resultData.put('totalQty', totalQuantity);
        } else {
          resultData.put('totalQty', 1);
        }
      }
    } catch (Exception e) {
      logger.error(e);
      throw new AuraHandledException(e.getMessage());
    } finally {
      logger.flush();
    }

    return resultData;
  }
 */
  global static string queryForBillingDate(Id assetId) {
    String cancelDate = '';
    try {
      List<Asset> assetList = new List<Asset>();

      if (Test.isRunningTest()) {
        assetList = [
          SELECT
            id,
            LifecycleStartDate,
            Name,
            Next_Billing_Date__c,
            LifecycleEndDate
          FROM Asset
          WHERE Id = :assetId
          LIMIT 1
        ];
      } else {
        assetList = [
          SELECT
            id,
            LifecycleStartDate,
            Name,
            Next_Billing_Date__c,
            LifecycleEndDate
          FROM Asset
          WHERE Id = :assetId
          LIMIT 1
        ];
      }

      if (assetList.size() > 0) {
        cancelDate =
          string.valueof(assetList[0].Next_Billing_Date__c) + 'T00:00:00-00:00';
      } else {
        cancelDate = string.valueof(system.today()) + 'T00:00:00-00:00';
      }
    } catch (Exception e) {
      logger.error(e);
      throw new AuraHandledException(e.getMessage());
    } finally {
      logger.flush();
    }
    return cancelDate;
  }

  @AuraEnabled
  global static map<string, object> initiateCancellation(string cancelData) {
    Map<String, object> resultData = new Map<String, object>();
    Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(
      cancelData
    );
    String assetId = (String) dataMap.get('assetId');

    try {
      string cancelDate = '';
      cancelDate = queryForBillingDate(assetId);
/*       List<BillingScheduleGroup> billingSechd = new List<BillingScheduleGroup>();
      if (Test.isRunningTest()) {
        billingSechd = [
          SELECT id, EffectiveNextBillingDate, EndDate
          FROM BillingScheduleGroup
          WHERE ReferenceEntityId = :assetId
        ];
      } else {
        billingSechd = [
          SELECT id, EffectiveNextBillingDate, EndDate
          FROM BillingScheduleGroup
          WHERE ReferenceEntityId = :assetId
        ]; //removed WITH SECURITY_ENFORCED from soql
      }
      if (billingSechd.size() > 0) {
        cancelDate =
          string.valueof(billingSechd[0].EffectiveNextBillingDate) +
          'T00:00:00-00:00';
      } else {
        cancelDate = string.valueof(system.today()) + 'T00:00:00-00:00';
      } */

      Http http = new Http();
      HttpRequest request = new HttpRequest();
      if (!test.isRunningTest()) {
        request.setHeader(
          'Authorization',
          'Bearer ' + B2B_CreateUserAccessToken.getAdminAccessToken()
        );
      } else {
        request.setHeader('Authorization', 'Bearer ');
      }
      String baseUrl = String.valueOf(Url.getOrgDomainUrl().toExternalForm());
      String cancelAssets = '/services/data/v58.0/asset-management/assets/collection/actions/initiate-cancellation';
      request.setMethod('POST');
      request.setHeader('Content-Type', 'application/json; charset=UTF-8');
      request.setEndpoint(baseUrl + cancelAssets);
      String requestBody =
        '{' +
        '"assetIds": {' +
        '"assetIdArray": [' +
        '"' +
        assetId +
        '"' +
        ']' +
        '},' +
        '"cancellationDate": "' +
        cancelDate +
        '",' +
        '"cancellationOutputType": "order"' +
        '}';

      request.setBody(requestBody);

      system.debug(requestBody + 'requestBody----');
      HttpResponse response = http.send(request);
      // Parse the JSON response
      resultData.put('response', response.getBody());
      System.debug('response: ' + response.getBody());
      if (response.getStatusCode() != 201) {
        System.debug(
          'The status code returned was not expected: ' +
            response.getStatusCode() +
            ' ' +
            response.getStatus()
        );
      } else {
        System.debug(response.getBody());
      }
    } catch (Exception e) {
      logger.error(e);
      throw new AuraHandledException(e.getMessage());
    } finally {
      logger.flush();
    }

    return resultData;
  }

  /**
   * Initiate cancellation of the asset from Manage Subscription page in the Store Front.
   *
   **/
/*   @AuraEnabled
  global static map<string, object> initiateCancellation(string cancelData) {
    Map<String, object> resultData = new Map<String, object>();
    Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(
      cancelData
    );
    String assetId = (String) dataMap.get('assetId');

    try {
      string cancelDate = '';

      List<BillingScheduleGroup> billingSechd = new List<BillingScheduleGroup>();
      if (Test.isRunningTest()) {
        billingSechd = [
          SELECT id, EffectiveNextBillingDate, EndDate
          FROM BillingScheduleGroup
          WHERE ReferenceEntityId = :assetId
        ];
      } else {
        billingSechd = [
          SELECT id, EffectiveNextBillingDate, EndDate
          FROM BillingScheduleGroup
          WHERE ReferenceEntityId = :assetId
        ]; //removed WITH SECURITY_ENFORCED from soql
      }
      if (billingSechd.size() > 0) {
        cancelDate =
          string.valueof(billingSechd[0].EffectiveNextBillingDate) +
          'T00:00:00-00:00';
      } else {
        cancelDate = string.valueof(system.today()) + 'T00:00:00-00:00';
      }

      Http http = new Http();
      HttpRequest request = new HttpRequest();
      if (!test.isRunningTest()) {
        request.setHeader(
          'Authorization',
          'Bearer ' + B2B_CreateUserAccessToken.getAdminAccessToken()
        );
      } else {
        request.setHeader('Authorization', 'Bearer ');
      }
      String baseUrl = String.valueOf(Url.getOrgDomainUrl().toExternalForm());
      String cancelAssets = '/services/data/v58.0/asset-management/assets/collection/actions/initiate-cancellation';
      request.setMethod('POST');
      request.setHeader('Content-Type', 'application/json; charset=UTF-8');
      request.setEndpoint(baseUrl + cancelAssets);
      String requestBody =
        '{' +
        '"assetIds": {' +
        '"assetIdArray": [' +
        '"' +
        assetId +
        '"' +
        ']' +
        '},' +
        '"cancellationDate": "' +
        cancelDate +
        '",' +
        '"cancellationOutputType": "order"' +
        '}';

      request.setBody(requestBody);

      system.debug(requestBody + 'requestBody----');
      HttpResponse response = http.send(request);
      // Parse the JSON response
      resultData.put('response', response.getBody());
      System.debug('response: ' + response.getBody());
      if (response.getStatusCode() != 201) {
        System.debug(
          'The status code returned was not expected: ' +
            response.getStatusCode() +
            ' ' +
            response.getStatus()
        );
      } else {
        System.debug(response.getBody());
      }
    } catch (Exception e) {
      logger.error(e);
      throw new AuraHandledException(e.getMessage());
    } finally {
      logger.flush();
    }

    return resultData;
  } */

  /**
   * This method is deprecated. When building the manage package, please mark this method as deprecated.
   *
   **/
  @AuraEnabled
  global static map<string, object> cancelAsset(Id assetId) {
    Map<String, object> resultData = new Map<String, object>();

    try {
      string cancelDate = '';

      List<BillingScheduleGroup> billingSechd = new List<BillingScheduleGroup>();
      if (Test.isRunningTest()) {
        billingSechd = [
          SELECT id, EffectiveNextBillingDate, EndDate
          FROM BillingScheduleGroup
          WHERE ReferenceEntityId = :assetId
        ];
      } else {
        billingSechd = [
          SELECT id, EffectiveNextBillingDate, EndDate
          FROM BillingScheduleGroup
          WHERE ReferenceEntityId = :assetId
        ]; //removed WITH SECURITY_ENFORCED from soql
      }
      if (billingSechd.size() > 0) {
        cancelDate =
          string.valueof(billingSechd[0].EffectiveNextBillingDate) +
          'T00:00:00-00:00';
      } else {
        cancelDate = string.valueof(system.today()) + 'T00:00:00-00:00';
      }

      Http http = new Http();
      HttpRequest request = new HttpRequest();
      if (!test.isRunningTest()) {
        request.setHeader(
          'Authorization',
          'Bearer ' + B2B_CreateUserAccessToken.getAdminAccessToken()
        );
      } else {
        request.setHeader('Authorization', 'Bearer ');
      }
      String baseUrl = String.valueOf(Url.getOrgDomainUrl().toExternalForm());
      String cancelAssets = '/services/data/v58.0/asset-management/assets/collection/actions/initiate-cancellation';
      request.setMethod('POST');
      request.setHeader('Content-Type', 'application/json; charset=UTF-8');
      request.setEndpoint(baseUrl + cancelAssets);
      String requestBody =
        '{' +
        '"assetIds": {' +
        '"assetIdArray": [' +
        '"' +
        assetId +
        '"' +
        ']' +
        '},' +
        '"cancellationDate": "' +
        cancelDate +
        '",' +
        '"cancellationOutputType": "order"' +
        '}';

      request.setBody(requestBody);

      system.debug(requestBody + 'requestBody----');
      HttpResponse response = http.send(request);
      // Parse the JSON response
      resultData.put('response', response.getBody());
      System.debug('response: ' + response.getBody());
      if (response.getStatusCode() != 201) {
        System.debug(
          'The status code returned was not expected: ' +
            response.getStatusCode() +
            ' ' +
            response.getStatus()
        );
      } else {
        System.debug(response.getBody());
      }
    } catch (Exception e) {
      logger.error(e);
      throw new AuraHandledException(e.getMessage());
    } finally {
      logger.flush();
    }

    return resultData;
  }

  /**
   * Initiate Amendment of the asset from Manage Subscription page in the Store Front.
   *
   **/

  @AuraEnabled
  global static Map<String, Object> amendAssets(String amendData) {
    Map<String, Object> resultData = new Map<String, Object>();

    Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(
      amendData
    );
    String assetId = (String) dataMap.get('assetId');
    Integer convtToQtyInteger = integer.valueof(dataMap.get('quantityChange'));
    Integer quantityChange = (Integer) convtToQtyInteger;

    logger.debug(assetId + 'quantityChange' + quantityChange);

    try {
      string startDate = '';
      startDate = queryForBillingDate(assetId);
/*       List<BillingScheduleGroup> billingSechd = new List<BillingScheduleGroup>();
      if (Test.isRunningTest()) {
        billingSechd = [
          SELECT id, EffectiveNextBillingDate
          FROM BillingScheduleGroup
          WHERE ReferenceEntityId = :assetId
        ];
      } else {
        billingSechd = [
          SELECT id, EffectiveNextBillingDate
          FROM BillingScheduleGroup
          WHERE ReferenceEntityId = :assetId
        ]; //removed WITH SECURITY_ENFORCED from soql
      }
      if (billingSechd.size() > 0) {
        startDate =
          string.valueof(billingSechd[0].EffectiveNextBillingDate) +
          'T00:00:00-00:00';
      } else {
        startDate = string.valueof(system.today()) + 'T00:00:00-00:00';
      } */

      String baseUrl = String.valueOf(Url.getOrgDomainUrl().toExternalForm());
      String endPointUrl;
      if (String.isNotBlank(baseUrl)) {
        endPointUrl =
          baseUrl +
          '/services/data/v58.0/asset-management/assets/collection/actions/initiate-amend-quantity';
      }

      String accessTokenVal = Test.isRunningTest()
        ? 'accessToken'
        : B2B_CreateUserAccessToken.getAdminAccessToken();

      String reqData =
        '{' +
        '"amendmentOutputType": "order",' +
        '"assetIds": {' +
        '"assetIdArray": [' +
        '"' +
        assetId +
        '"' +
        ']' +
        '},' +
        '"startDate": "' +
        startDate +
        '",' +
        '"quantityChange": ' +
        quantityChange +
        '}';

      String auth = B2B_SetupConstants.BEARER + ' ' + accessTokenVal;
      System.debug('endPointUrl ' + endPointUrl);

      Map<String, String> request1 = new Map<String, String>();
      request1.put(B2B_SetupConstants.AUTHORIZATION, auth);
      request1.put(B2B_SetupConstants.ENDPOINT, endPointUrl);
      request1.put(B2B_SetupConstants.BODY, reqData);
      request1.put(B2B_SetupConstants.METHOD, B2B_SetupConstants.POST);
      request1.put(
        B2B_SetupConstants.CONTENT,
        B2B_SetupConstants.APPLICATION_JSON
      );

      System.debug('endPointUrl ' + request1);

      string response = B2B_RestApiCalls.httpCallOut(request1);
      resultData.put('Call Out Response', response);
      system.debug(resultData + 'Response>>><<<');
    } catch (Exception e) {
      logger.error(e);
      throw new AuraHandledException(e.getMessage());
    } finally {
      logger.flush();
    }

    return resultData;
  }
}
