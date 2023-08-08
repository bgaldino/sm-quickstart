global with sharing class B2B_FlowExceptionsHandler {

    private static final DCM_Logger logger = DCM_Logger.getInstance('Flow Exceptions');

    global class B2B_FlowExceptionsHandlerRequest {
        @InvocableVariable(required=true)
        public String errorMessage;
        @InvocableVariable
        public String errorSubject;
    }

    /**
     * @description Maps a cart to an order. Activates it, and closes the cart. Returns the resulting order summary id.
     * @param request The checkout session and cart id.
     * @return The OrderId that resulted from this class.
     */
    @InvocableMethod(label='Error logger' description='Creates a DCM Application Log error record')
    global static void buynowCallout(List<B2B_FlowExceptionsHandlerRequest> request) {
        try{
            if(request[0].errorSubject != Null){
                logger.debug(request[0].errorSubject + ' B2B_FlowExceptionsHandler error logging '+ request[0].errorMessage);
                logger.error(request[0].errorSubject);
                logger.error(request[0].errorMessage);
            }else{
                logger.debug('B2B_FlowExceptionsHandler error logging '+ request[0].errorMessage);
                logger.error(request[0].errorMessage);	}   } catch (Exception ex) {logger.error(ex);
        } finally {
            logger.flush();
        }
    }
}