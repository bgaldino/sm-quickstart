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

global with sharing class RSM_RequestForQuote {
    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.REQUEST_DISCOUNT);
    /**
     * This method is used to create quote for request discount button.
     * @param cartId, CartType, QuoteMesage, Community Id
     * @return Newly created Quote data
    **/
    @AuraEnabled
    global static  Map<String,Object> requestForAQuotes(String cartId,String cartType,String quoteMsg, string communityId){
        Map<String,Object> reqData = new Map<String,Object>();
        Map<String,Object> responseData = new Map<String,Object>();
        reqData.put('cartId', cartId);
        reqData.put('cartType', 'RFQ');
        reqData.put('quoteMsg', quoteMsg);
        System.debug('reqData ____ ' + reqData);
      
        try{

            
            RSM_makeCPQQuoteAPICallout.createQuoteToCart(cartId,cartType,quoteMsg, communityId);
            responseData.put('isSuccess',true);
      
        } catch(Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        return responseData;
    }   
}