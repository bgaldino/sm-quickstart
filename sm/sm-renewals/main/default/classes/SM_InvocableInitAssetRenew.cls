public with sharing class SM_InvocableInitAssetRenew {
  @InvocableMethod(
    label='[SM] Renew Asset (Single)'
    description='Renewal of an Asset'
    category='Revenue Cloud'
    callout=true
  )
  public static List<String> renewAsset(List<String> assetIds) {
    List<String> reqIds = new List<String>();
    for (String assetId : assetIds) {
      System.debug(assetId);
      String bodyJson = generateRequestBody(assetId);
      System.debug(bodyJson);

      String endpoint = getCallout('Default');
      System.debug(endpoint);

      HttpRequest httpRequest = new HttpRequest();
      httpRequest.setMethod('POST');
      httpRequest.setHeader('Content-Type', 'application/json;charset=UTF-8');
      httpRequest.setEndpoint(endpoint);

      httpRequest.setBody(bodyJson);
      String response = '';
      try {
        system.debug('Sending Request');
        HttpResponse httpResponse = new Http().send(httpRequest);
        while (httpResponse.getStatusCode() == 302) {
          httpRequest.setEndpoint(httpResponse.getHeader('Location'));
          httpResponse = new Http().send(httpRequest);
        }
        system.debug(httpResponse.getStatus());
        response = httpResponse.getBody();
        system.debug(response);
      } catch (System.Exception e) {
        System.debug('ERROR: ' + e);
      }

      System.debug(JSON.serializePretty(response));
      List<AsyncResponse> resps = new List<AsyncResponse>();
      AsyncResponse resp = (AsyncResponse) JSON.deserialize(
        response,
        AsyncResponse.class
      );
      resps.add(resp);

      for (AsyncResponse asr : resps) {
        reqIds.add(asr.requestIdentifier);
      }
    }
    system.debug(reqIds);
    return reqIds;
  }

  public static String generateRequestBody(Id assetId) {
    String bodyJson = '{"assetIds": {"assetIdArray": ["' + assetId + '"]}}';
    System.debug('bodyJson: ' + bodyJson);
    return bodyJson;
  }

  // 'Default'

  public static string getCallout(String settingName) {
    SM_Renew_Asset_Setting__mdt setting = SM_Renew_Asset_Setting__mdt.getInstance(
      settingName
    );
    // https://{MyDomainName}.my.salesforce.com/services/data/v55.0/asset-management/assets/{assetId}/actions/initiate-renewal
    // this is wrong in the docs
    return 'callout:' + setting.NamedCredential__c + setting.RenewalEndpoint__c;
  }

  public class AsyncResponse {
    @AuraEnabled
    public String requestIdentifier { get; set; }
    @AuraEnabled
    public Boolean success { get; set; }
  }
}
