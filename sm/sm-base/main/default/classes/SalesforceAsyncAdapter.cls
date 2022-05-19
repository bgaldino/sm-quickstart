global with sharing virtual class SalesforceAsyncAdapter implements commercepayments.PaymentGatewayAdapter, commercepayments.PaymentGatewayAsyncAdapter {
    private static final commercepayments.SalesforceResultCodeInfo SUCCESS_SALESFORCE_RESULT_CODE_INFO = 
    		new commercepayments.SalesforceResultCodeInfo(commercepayments.SalesforceResultCode.Success);
    private static final commercepayments.SalesforceResultCodeInfo DECLINE_SALESFORCE_RESULT_CODE_INFO = 
    		new commercepayments.SalesforceResultCodeInfo(commercepayments.SalesforceResultCode.Decline);
    
    global SalesforceAsyncAdapter() {
    }

    global commercepayments.GatewayResponse processRequest(commercepayments.paymentGatewayContext gatewayContext) {
        commercepayments.RequestType requestType = gatewayContext.getPaymentRequestType();
        commercepayments.AbstractTransactionResponse response;
        try {
			if (requestType == commercepayments.RequestType.Authorize) {
                response = createAuthResponse((commercepayments.AuthorizationRequest)gatewayContext.getPaymentRequest());
            } else if (requestType == commercepayments.RequestType.Capture) {
                response =  createCaptureResponse((commercepayments.CaptureRequest)gatewayContext.getPaymentRequest()) ;
            } else if (requestType == commercepayments.RequestType.ReferencedRefund) {
            	response = createRefundResponse((commercepayments.ReferencedRefundRequest)gatewayContext.getPaymentRequest());
            }
            return response;
        } catch(SalesforceValidationException e) {
             commercepayments.GatewayErrorResponse error = new commercepayments.GatewayErrorResponse('400', e.getMessage());
             return error;
        }
    }

    public commercepayments.AbstractTransactionResponse createAuthResponse(commercepayments.AuthorizationRequest authRequest) {
        commercepayments.AuthorizationResponse authResponse = new commercepayments.AuthorizationResponse();
        commercepayments.PaymentMethodTokenizationResponse paymentMethodTokenizationResponse = new commercepayments.PaymentMethodTokenizationResponse();
        if(authRequest.amount != null) {
            authResponse.setAmount(authRequest.amount);
        } else {
            throw new SalesforceValidationException('Required Field Missing : Amount');
        }

        authResponse.setGatewayResultCode('00');
        authResponse.setGatewayResultCodeDescription('Transaction Normal');
        authResponse.setGatewayAuthCode('SF' + getRandomNumber(6));
        authResponse.setGatewayReferenceNumber(getRandomNumber(10));
        authResponse.setSalesforceResultCodeInfo(SUCCESS_SALESFORCE_RESULT_CODE_INFO);
        authResponse.setGatewayDate(system.now());
        paymentMethodTokenizationResponse.setGatewayToken(getRandomNumber(8) + getRandomNumber(8));
        authResponse.setPaymentMethodTokenizationResponse(paymentMethodTokenizationResponse);
        return authResponse;
    }
    
    public commercepayments.AbstractTransactionResponse createCaptureResponse(commercepayments.CaptureRequest captureRequest) {
        commercepayments.CaptureResponse captureResponse = new commercepayments.CaptureResponse();
        captureResponse.setGatewayReferenceNumber('SF' + getRandomNumber(6));
        captureResponse.setAsync(true);
        captureResponse.setSalesforceResultCodeInfo(SUCCESS_SALESFORCE_RESULT_CODE_INFO);

        /* Do not change this
        this is being used in ccs.payments.connect.resources.capture.CaptureAsyncSalesforceAdapterTest#testNullOverrides() */
        captureResponse.setGatewayResultCode('TEST_VALUE_OVERRIRDE');

        return captureResponse;
    }

    public commercepayments.AbstractTransactionResponse createRefundResponse(commercepayments.ReferencedRefundRequest refundRequest) {
    	commercepayments.ReferencedRefundResponse refundResponse = new commercepayments.ReferencedRefundResponse();
        refundResponse.setGatewayReferenceNumber('SF' + getRandomNumber(6));
        refundResponse.setSalesforceResultCodeInfo(SUCCESS_SALESFORCE_RESULT_CODE_INFO);
        refundResponse.setAsync(true);

        /* Do not change this
        this is being used in ccs.payments.connect.resources.refund.RefundAsyncSalesforceAdapterTest#testNullOverrides() */
        refundResponse.setGatewayResultCode('TEST_VALUE_OVERRIRDE');

        return refundResponse;
    }  

    private String getRandomNumber(integer stringLength){
        final integer MAX = integer.valueOf(Math.pow(10,stringLength) - 1);
        return String.valueOf(Math.Round(Math.Random() * MAX)).leftPad(stringLength,'0');
    }
    
	public virtual commercepayments.GatewayNotificationResponse processNotification(commercepayments.PaymentGatewayNotificationContext gatewayNotificationContext) {
        commercepayments.PaymentGatewayNotificationRequest notificationRequest = gatewayNotificationContext.getPaymentGatewayNotificationRequest();
        commercepayments.GatewayNotificationResponse gnr = new commercepayments.GatewayNotificationResponse();
        Blob request = notificationRequest.getRequestBody();
        Map<String, Object> jsonReq = null;
        try {
            jsonReq = (Map<String, Object>) JSON.deserializeUntyped(request.toString());
        } catch(Exception e) {
            gnr.setStatusCode(400);
            gnr.setResponseBody(Blob.valueOf('Could not parse given JSON request body '+ request.toString()));
            return gnr;
        }
        String gatewayRefNumber = (String)jsonReq.get('gatewayRefNumber');
        Double amount = (Double)jsonReq.get('amount');
        String status = (String)jsonReq.get('status');
        String type = (String)jsonReq.get('type');
        commercepayments.NotificationStatus notificationStatus = null;
        if ('Failed'.equals(status)) {
            notificationStatus = commercepayments.NotificationStatus.Failed;
        } else if ('Success'.equals(status)) {
            notificationStatus = commercepayments.NotificationStatus.Success;
        }
        commercepayments.BaseNotification notification = null;
        if ('capture'.equals(type)) {
            notification = new commercepayments.CaptureNotification();
        } else if ('refund'.equals(type)) {
            notification = new commercepayments.ReferencedRefundNotification();
        }
        notification.setStatus(notificationStatus);
        notification.setGatewayReferenceNumber(gatewayRefNumber);
        notification.setAmount(amount);
        commercepayments.NotificationSaveResult saveResult = commercepayments.NotificationClient.record(notification);
        
        if (saveResult.isSuccess()) {
            system.debug('Notification accepted by platform');
            gnr.setStatusCode(saveResult.getStatusCode());
            gnr.setResponseBody(Blob.valueOf('[Accepted]'));
        } else {
            system.debug('Errors in the result');
            gnr.setStatusCode(saveResult.getStatusCode());
            gnr.setResponseBody(Blob.valueOf(saveResult.getErrorMessage()));
        }
        return gnr;
    }

}