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

public without sharing class CommunityAuthController {
    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.SELF_REGISTRATION);
    /**
     * Allows to login community user using login page.
     * 
    **/
    @AuraEnabled
    public static string doLogin(String username, String password){
        try {
            
            String startUrl = System.Label.Community_Url;
            String redirectUrl = System.Label.Login_URL_Redirect;
            ApexPages.PageReference pageRef = Site.login(username, password, redirectUrl);

                if(pageRef != null) 
                return pageRef.getUrl();

            } catch(Exception e) {
                logger.error(e);
                throw new AuraHandledException(e.getMessage());
            } finally {
                logger.flush();
            }
        return null;
    }

     /**
     * This method validate the email address in the org to check if the particular user is already exist in the system.
     * 
    **/
    @AuraEnabled
    public static boolean isEmailExist(String username){
        List<User> userList = new List<User>();
        try {
            
            
            userList = [Select Id, Name From User Where Username = :username WITH SECURITY_ENFORCED];

           

          


        } catch(Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }

        return !userList.isEmpty();
    }
     /**
     * Register a user using registration page of community.
     * 
    **/
    @AuraEnabled
    public static string registerUser(String firstName, String lastName, String username, String email, String communityNickname, String password){
        try {

            Set<String> communityNicknameSet = new Set<String>();

            for(User usr : [Select Id, CommunityNickname From User Where CommunityNickname != null]){

                communityNicknameSet.add(usr.CommunityNickname);
            }

            String uniqueCommunityNickName;

            if(communityNicknameSet.isEmpty()){

                if(communityNickname.length() > 4){
                    
                    uniqueCommunityNickName = communityNickname.substring(0, 4) + String.valueOf( Integer.valueOf(Math.random() * 10000) );
                
                } else {

                    uniqueCommunityNickName = communityNickname + String.valueOf( Integer.valueOf(Math.random() * 10000) );
                }
            
            } else {

                for(Integer i=1; i <= 9999 ; i++){

                    if(communityNickname.length() > 4){
                        
                        uniqueCommunityNickName = communityNickname.substring(0, 4) + String.valueOf( Integer.valueOf(Math.random() * 10000) );
                    
                    } else {

                        uniqueCommunityNickName = communityNickname + String.valueOf( Integer.valueOf(Math.random() * 10000) );
                    }

                    if(!communityNicknameSet.contains(uniqueCommunityNickName)){

                        break;
                    }
                }
            }
            
            User u = new User();
            u.firstName = firstName;
            u.lastName = lastName;
            u.Username = username;
            u.Email = email;
            u.CommunityNickname = uniqueCommunityNickName;        

            String accountId;

           //Define default account in custom metadada
           B2B_User_Login_Configuration__mdt adminUserConfig = B2B_User_Login_Configuration__mdt.getInstance('System_Admin_Configurations');

           accountId = adminUserConfig.Effective_Account_Id__c;

            String userId ;

            if(!test.isRunningTest()){
              userId = Site.createPortalUser(u, accountId, password, true);  
            }
            else
            {  userId =[select id from user where username=:username ].id ;}
          

            if (userId != null) {
               
                
                if (password != null && password.length() > 1) {
                    ApexPages.PageReference pageRef = Site.login(username, password, null);
                    if(pageRef != null) return pageRef.getUrl();
                }
                else {
                    ApexPages.PageReference page = System.Page.SiteRegisterConfirm; 
                    page.setRedirect(true);
                    return page.getUrl();
                }
            }

        } catch(Exception e) {
            logger.error(e);
            if(!Test.isRunningTest()) throw new AuraHandledException(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        return null;

    }


}