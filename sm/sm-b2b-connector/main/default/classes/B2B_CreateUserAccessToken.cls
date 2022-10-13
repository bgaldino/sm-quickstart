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

public without sharing class B2B_CreateUserAccessToken {

    
    @AuraEnabled
    public static String getAccessToken(){
        //String siteBase = Site.getBaseUrl();//String.valueOf(Url.getOrgDomainUrl().toExternalForm());//System.label.B2B_Storefront_Url;
        B2B_User_Login_Configuration__mdt adminUserConfig = B2B_User_Login_Configuration__mdt.getInstance('System_Admin_Configurations');
        //String siteBase = 'https://ssmdev-dev-ed.my.salesforce.com';
       String siteBase = adminUserConfig.Salesforce_Base_URL__c;
        Auth.JWT jwt = new Auth.JWT();
        jwt.setSub(Userinfo.getUserName());
        jwt.setIss(adminUserConfig.Consumer_Key__c);
        //jwt.setAud('https://login.salesforce.com');
        jwt.setAud(siteBase);
        Auth.JWS jws = new Auth.JWS(jwt,adminUserConfig.Certificate_Name__c);
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
      //'https://ssmdev-dev-ed.my.salesforce.com';
      B2B_User_Login_Configuration__mdt adminUserConfig = B2B_User_Login_Configuration__mdt.getInstance('System_Admin_Configurations');
      String siteBase = adminUserConfig.Salesforce_Base_URL__c; //'https://test.salesforce.com';
      Auth.JWT jwt = new Auth.JWT();
      jwt.setSub(adminUserConfig.Username__c);
      jwt.setIss(adminUserConfig.Consumer_Key__c);
      jwt.setAud(siteBase);
     
      Auth.JWS jws = new Auth.JWS(jwt,adminUserConfig.Certificate_Name__c);
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