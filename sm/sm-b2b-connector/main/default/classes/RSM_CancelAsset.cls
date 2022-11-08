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
global without sharing class RSM_CancelAsset {

  private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.ASSET_CANCELLATION);
  /**
   * Reterive the information about next billing date and display on manage subscription page.
   * 
  **/
  @AuraEnabled
  global static map<string, object> getNextBillingDate(id assetId){

    Map<String,object> resultData = new Map<String,object>();
    try {

      List<BillingScheduleGroup> billingSechd =  [select id, StartDate, ReferenceEntity.Name, EffectiveNextBillingDate, EndDate from BillingScheduleGroup where ReferenceEntityId =: assetId LIMIT 1];

      if(billingSechd.size() > 0){

        resultData.put('nextBillingDate', billingSechd[0].EffectiveNextBillingDate);
        if(billingSechd[0].EndDate != null){

          resultData.put('assetEndDate', billingSechd[0].EndDate.addYears(1).addDays(-1));
        }
       
        resultData.put('productName', billingSechd[0].ReferenceEntity.Name);
        resultData.put('assetStartDate', billingSechd[0].StartDate);


      }
      
    } catch(Exception e) {
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
  @AuraEnabled
  global static map<string, object> cancelAsset(Id assetId){

    Map<String,object> resultData = new Map<String,object>();
  
    try {
   
      

      string cancelDate = '';
     List<BillingScheduleGroup> billingSechd =  [select id, EffectiveNextBillingDate, EndDate from BillingScheduleGroup where ReferenceEntityId =: assetId];
      if(billingSechd.size() > 0){

        cancelDate = string.valueof(billingSechd[0].EffectiveNextBillingDate)+'T00:00:00-00:00';


      }else{

        cancelDate = string.valueof(system.today())+'T00:00:00-00:00';


      }
     

      
      Http http = new Http();
      HttpRequest request = new HttpRequest();
      if(!test.isRunningTest())
        {
          request.setHeader('Authorization', 'Bearer ' + B2B_CreateUserAccessToken.getAdminAccessToken());
        }
        else{
          request.setHeader('Authorization', 'Bearer ');   
        }
      String baseUrl = String.valueOf(Url.getOrgDomainUrl().toExternalForm());
      String cancelAssets = '/services/data/v55.0/asset-management/assets/collection/actions/initiate-cancellation';
      request.setMethod('POST'); 
      request.setHeader('Content-Type', 'application/json; charset=UTF-8');
      request.setEndpoint(baseUrl+cancelAssets);
      String requestBody = '{' +
          '"assetIds": {' +
            '"assetIdArray": [' +
              '"' + assetId + '"' +
            ']' +
          '},' +
          '"cancellationDate": "' + cancelDate + '",' +
          '"cancellationOutputType": "order"' +
        '}';  

      request.setBody(requestBody);
     
      system.debug(requestBody + 'requestBody----');
      HttpResponse response = http.send(request);
      // Parse the JSON response
      resultData.put('response',response.getBody());
      System.debug('response: ' + response.getBody());
      if (response.getStatusCode() != 201) {
          System.debug('The status code returned was not expected: ' +
          response.getStatusCode() + ' ' + response.getStatus());
      } else {
          System.debug(response.getBody());

      }

    } catch(Exception e) {
        logger.error(e);
        throw new AuraHandledException(e.getMessage());
    } finally {
        logger.flush();
    }

   return resultData;

 }

}