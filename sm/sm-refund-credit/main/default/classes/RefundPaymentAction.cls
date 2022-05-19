public class RefundPaymentAction {
    public static final String REFUND_PAYMENT_ENDPOINT = '/services/data/v54.0/commerce/payments/payments/{{paymentId}}/refunds';
    public static final String APPLY_REFUND_ENDPOINT = '/services/data/v54.0/commerce/billing/refunds/{{refundId}}/actions/apply';

    @InvocableMethod(label = 'Refund Payment and Apply' callout = true)
    public static List<RefundPaymentResponse> refundPaymentAndApply (List<RefundPaymentRequest> refundPaymentRequestList) {
        List<RefundPaymentResponse> refundPaymentResponseList = new List<RefundPaymentResponse>();
        for(RefundPaymentRequest refundPaymentRequest: refundPaymentRequestList) {

            // Refund Payment
            String body = json.serialize(refundPaymentRequest);
            String endpoint = 'callout:MySalesforce' + REFUND_PAYMENT_ENDPOINT.replace('{{paymentId}}', refundPaymentRequest.paymentId);
            HttpResponse response = RefundPaymentAction.post(endpoint, body);
            RefundPaymentResponse refundPaymentResponse = RefundPaymentAction.parseResponse(response.getBody());
            refundPaymentResponseList.add(refundPaymentResponse);

            // Apply Refund
            ApplyRefundRequest applyRefundRequest = new ApplyRefundRequest();
            applyRefundRequest.amount = refundPaymentRequest.amount;
            applyRefundRequest.effectiveDate = refundPaymentRequest.effectiveDate;
            applyRefundRequest.appliedToId = refundPaymentRequest.paymentId;
            applyRefundRequest.comments = refundPaymentRequest.comments;
            body = json.serialize(applyRefundRequest);
            endpoint = 'callout:MySalesforce' + APPLY_REFUND_ENDPOINT.replace('{{refundId}}', refundPaymentResponse.id);
            response = RefundPaymentAction.post(endpoint, body);
        }
        return refundPaymentResponseList;
    }

    public static RefundPaymentResponse parseResponse(String body) {
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(body);
        Map<String, Object> refundMap = (Map<String, Object>) responseMap.get('refund');

        RefundPaymentResponse refundPaymentResponse = new refundPaymentResponse();
        refundPaymentResponse.accountId = (String) refundMap.get('accountId');
        refundPaymentResponse.amount = (Decimal) refundMap.get('amount');
        refundPaymentResponse.currencyIsoCode = (String) refundMap.get('currencyIsoCode');
        refundPaymentResponse.effectiveDate = (String) refundMap.get('effectiveDate');
        refundPaymentResponse.id = (String) refundMap.get('id');
        refundPaymentResponse.refundNumber = (String) refundMap.get('refundNumber');
        refundPaymentResponse.requestDate = (String) refundMap.get('requestDate');
        refundPaymentResponse.status = (String) refundMap.get('status');

        return refundPaymentResponse;
    }

    public static HttpResponse post(String endpoint, String body) {

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(body);
        HttpResponse response = http.send(request);
        return response;
    }

    public class RefundPaymentRequest {
        @InvocableVariable(label='Payment Id' required=true)
        public transient String paymentId;

        @InvocableVariable(label='Account Id' required=true)
        public String accountId;

        @InvocableVariable(label='Amount' required=true)
        public Decimal amount;

        @InvocableVariable(label='Effective Date' required=true)
        public Datetime effectiveDate;

        @InvocableVariable(label='Comments' required=true)
        public String comments;
    }

    public class RefundPaymentResponse {
        @InvocableVariable
        public String accountId;
        @InvocableVariable
        public Decimal amount;
        @InvocableVariable
        public String currencyISOCode;
        @InvocableVariable
        public String effectiveDate;
        @InvocableVariable
        public String id;
        @InvocableVariable
        public String refundNumber;
        @InvocableVariable
        public String requestDate;
        @InvocableVariable
        public String status;
    }

    public class ApplyRefundRequest {
        public Decimal amount;
        public DateTime effectiveDate;
        public String appliedToId;
        public String comments;
    }
}