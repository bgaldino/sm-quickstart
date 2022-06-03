public class CreditInvoiceAction {
    public static final String CREDIT_INVOICE_ENDPOINT = '/services/data/v55.0/commerce/invoicing/invoices/{{invoiceId}}/actions/credit';

    @InvocableMethod(label = 'Credit Invoice' callout = true)
    public static List<String> creditInvoice (List<CreditInvoiceRequest> creditInvoiceRequestList) {
        for(CreditInvoiceRequest creditInvoiceRequest: creditInvoiceRequestList) {
            creditInvoiceRequest.type = 'POSTED';
            creditInvoiceRequest.taxStrategy = 'Ignore';
            String body = json.serialize(creditInvoiceRequest);
            System.debug(body);
            String endpoint = 'callout:MySalesforce' + CREDIT_INVOICE_ENDPOINT.replace('{{invoiceId}}', creditInvoiceRequest.invoiceId);       
            futureCreditInvoice(endpoint, body);
        }
        return new List<String>();
    }

    @future(callout = true)
    public static void futureCreditInvoice(String endpoint, String body){
        HttpResponse response = CreditInvoiceAction.post(endpoint, body);
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

    public class CreditInvoiceRequest {
        @InvocableVariable(label='Invoice Id' required=true)
        public transient String invoiceId;

        @InvocableVariable(label='Invoice Lines' required=true)
        public List<InvoiceLineModel> invoiceLines;

        public String type;
        public String taxStrategy;
    }
}