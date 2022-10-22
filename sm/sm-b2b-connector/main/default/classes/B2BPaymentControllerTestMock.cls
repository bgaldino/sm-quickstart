@isTest
global class B2BPaymentControllerTestMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {

                HttpResponse response = new HttpResponse();        
                response.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                String resBody = '{\'id\':\'pi_3KUuaYJL5gmZS8DZ17JkFCPZ\',\'object\':\'payment_intent\',\'amount\':8494,\'amount_capturable\':0,\'amount_received\':0,\'application\':null,\'application_fee_amount\':null,\'automatic_payment_methods\':null,\'canceled_at\':null,\'cancellation_reason\':null,\'capture_method\':\'manual\',\'charges\':{\'object\':\'list\',\'data\':[],\'has_more\':false,\'total_count\':0,\'url\':\'/v1/charges?payment_intent=pi_3KUuaYJL5gmZS8DZ17JkFCPZ\'},\'client_secret\':\'pi_3KUuaYJL5gmZS8DZ17JkFCPZ_secret_shdQgQYvkCcKMPbfDk41Obep7\',\'confirmation_method\':\'automatic\',\'created\':1645283470,\'currency\':\'usd\',\'customer\':\'cus_L0kBEpk4EZOV8G\',\'description\':null,\'invoice\':null,\'last_payment_error\':null,\'livemode\':false,\'metadata\':{\'cartId\':\'0a63K00000001i4QAA\',\'orderId\':\'8013K000000b26rQAA\'},\'next_action\':null,\'on_behalf_of\':null,\'payment_method\':null,\'payment_method_options\':{\'card\':{\'installments\':null,\'network\':null,\'request_three_d_secure\':\'automatic\'}},\'payment_method_types\':[\'card\'],\'processing\':null,\'receipt_email\':null,\'review\':null,\'setup_future_usage\':null,\'shipping\':null,\'source\':null,\'statement_descriptor\':null,\'statement_descriptor_suffix\':null,\'status\':\'requires_payment_method\',\'transfer_data\':null,\'transfer_group\':null}';
                response.setBody(resBody);
                response.setStatusCode(200);
               // response.setTimeout(40000)
                return response;
    }
}