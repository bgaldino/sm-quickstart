/**
 * @description       : 
 * @author            : Raja Patnaik
 * @group             : 
 * @last modified on  : 01-26-2021
 * @last modified by  : Raja Patnaik
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   08-28-2020   Raja Patnaik   Initial Version
 * 
 /* Raja Patnaik  05-18-2021 */

public with sharing class B2B_CreateUserAccessToken {

    
    @AuraEnabled
    public static String getAccessToken(){
        RSM_ConnectorConfigrationSelector configSelector = new RSM_ConnectorConfigrationSelector();

        //String siteBase = Site.getBaseUrl();//String.valueOf(Url.getOrgDomainUrl().toExternalForm());//System.label.B2B_Storefront_Url;
        //B2B_User_Login_Configuration__mdt adminUserConfig = B2B_User_Login_Configuration__mdt.getInstance('System_Admin_Configurations');
        Map<String,String>adminUserConfig = configSelector.getAllConfigByType('Admin Configuration');
        //String siteBase = 'https://ssmdev-dev-ed.my.salesforce.com';
       //String siteBase = adminUserConfig.Salesforce_Base_URL__c;
       //String siteBase = B2BUtils.isSandbox() ? 'https://test.salesforce.com' : 'https://login.salesforce.com' ;
       String siteBase = adminUserConfig.get('Salesforce_Base_URL'); //System.Label.Org_Base_Url;
        Auth.JWT jwt = new Auth.JWT();
        jwt.setSub(Userinfo.getUserName());
        jwt.setIss(adminUserConfig.get('Consumer_Key'));
        //jwt.setAud('https://login.salesforce.com');
        jwt.setAud(siteBase);
        Auth.JWS jws = new Auth.JWS(jwt,adminUserConfig.get('Certificate_Name'));
        Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(siteBase+'/services/oauth2/token', jws);
         String accessToken;
        if(!Test.isRunningTest()){
            accessToken = bearer.getAccessToken();
        }else{
            accessToken = 'accessToken';
        }
        return accessToken;
    }

    @AuraEnabled
    public static String getAdminAccessToken() {
        RSM_ConnectorConfigrationSelector configSelector = new RSM_ConnectorConfigrationSelector();

      //'https://ssmdev-dev-ed.my.salesforce.com';
      //B2B_User_Login_Configuration__mdt adminUserConfig = B2B_User_Login_Configuration__mdt.getInstance('System_Admin_Configurations');
      Map<String,String>adminUserConfig = configSelector.getAllConfigByType('Admin Configuration');
      String siteBase = adminUserConfig.get('Salesforce_Base_URL'); //System.Label.Org_Base_Url;
      Auth.JWT jwt = new Auth.JWT();
      jwt.setSub(adminUserConfig.get('Username'));
      //jwt.setIss(adminUserConfig.get('Consumer_Key'));
      jwt.setIss(configSelector.getConfigByDeveloperName('Consumer_Key'));
      jwt.setAud(siteBase);
     
      Auth.JWS jws = new Auth.JWS(jwt,adminUserConfig.get('Certificate_Name'));
      Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(siteBase+'/services/oauth2/token', jws);
      String accessToken;
        if(!Test.isRunningTest()){
            accessToken = bearer.getAccessToken();
        }else{
            accessToken = 'accessToken';
        }
      return accessToken;
  }
  /*
    public static String getAdminAccessToken() {
        
         String siteBase = 'https://docmation-sm236-dev-org-dev-ed.my.salesforce.com';
        
         B2B_User_Login_Configuration__mdt adminUserConfig = B2B_User_Login_Configuration__mdt.getInstance('System_Admin_Configurations');
 
        Auth.JWT jwt = new Auth.JWT();
        jwt.setSub(adminUserConfig.Username__c);
        jwt.setIss('3MVG9LrF7FAOtzIoe3IorGRnJ7oolnJToiHmAlAhaDsVub_MevpO6XwTKKWVyRduXDF09JUBkYsyqe_1fUHmf');
        jwt.setAud('https://login.salesforce.com');
        Auth.JWS jws = new Auth.JWS(jwt,'SSM');
        Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(siteBase+'/services/oauth2/token', jws);
        String accessToken = bearer.getAccessToken();
        
       
        
      return accessToken;
    }
    */

}