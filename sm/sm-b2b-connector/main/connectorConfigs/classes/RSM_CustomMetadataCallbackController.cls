/**
 * @description       : 
 * @author            : Devanshu Sood
 * @group             : 
 * @last modified on  : 10-10-2022
 * @last modified by  : Devanshu Sood
**/
public with sharing class RSM_CustomMetadataCallbackController implements Metadata.DeployCallback{
    private static final DCM_Logger LOGGER = DCM_Logger.getInstance(B2B_Constants.Module.APP_CONFIG);
    

    public  void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        String methodName = 'handleResult ';
        String jobSubmittedUserId = result.createdBy;
        String jobSubmittedUserName = result.createdByName;

        try {
            User createByUser;            
            String queryString = 'Select Id, Name, Email from  User where Id =: jobSubmittedUserId  LIMIT 1';
        
            createByUser = Database.query(queryString);
            // String emailFromAddress = configurationSelector.getEmailFromAddress();
            // RSM_Application_Configuration__mdt mc = RSM_Application_Configuration__mdt.getInstance('From_Address_for_System_Emails');

            String emailFromAddress = RSM_Connector_Configuration__mdt.getInstance('From_Address_for_System_Emails').key__c;

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toAddresses = new List<String>(); 
            if(createByUser != null ){
                toAddresses.add(createByUser.email);
                mail.setToAddresses(toAddresses);     
                // Specify the subject line for your email address.
               // mail.setSubject(configurationSelector.getEnvironmentName()+' > '+ System.Label.DR_Configuration_Changes_Mail_Subject_Msg +' > '+System.Label.DR_Deployment_status_msg+' : '+result.status);
               mail.setSubject((RSM_Connector_Configuration__mdt.getInstance('Environment_Name') == null ? '' : RSM_Connector_Configuration__mdt.getInstance('Environment_Name').key__c)+' > '+ System.Label.RSM_Configuration_Changes_Mail_Subject_Msg +' > '+System.Label.RSM_Deployment_status_msg+' : '+result.status);
                if(result.status == Metadata.DeployStatus.Succeeded) {
                    // Send email to User about Successful Status of the Deployment Job
                    // Specify the text content of the email.
                    mail.setPlainTextBody('<br><b>'+System.Label.RSM_Configuration_Changes_Success_Mail_Content+'</b> </br>');
                    mail.setHtmlBody('<br><div style="margin-bottom:20px;"> <b>'+System.Label.RSM_Configuration_Changes_Success_Mail_Content+'</b></div></br>');                    
                }
                else if(result.status == Metadata.DeployStatus.Failed) {
                    // Send email to User about Failed Status of the Deployment Job
                    // Specify the text content of the email.
                    mail.setPlainTextBody('<br><b>'+System.Label.RSM_Configuration_Changes_Error_Mail_Content+'</b></br>'); 
                    mail.setHtmlBody('<br><b>'+System.Label.RSM_Configuration_Changes_Error_Mail_Content+'</b></br>');
                }
                queryString = 'select Id from OrgWideEmailAddress where Address =: emailFromAddress';
                OrgWideEmailAddress[] owea  = Database.query(queryString);
                if ( owea.size() > 0 ) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                // Send the email you have created.
                if(!Test.isRunningTest()){
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
            }
        } catch(Exception e) {
            LOGGER.error(e);
        } finally {
            LOGGER.flush();
        }
    }    
}
