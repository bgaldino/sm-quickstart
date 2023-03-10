/**
 * @description       : 
 * @author            : Abhishek Walia
 * @group             : Docmation LLC
 * @last modified on  : 01-23-2022
 * @last modified by  : Abhishek Walia
**/
public with sharing class B2BStripeModel {
    @auraEnabled public String Id; //returned id from Sripe - token or customer id based on object
    @auraEnabled public String transactionObject; //charge or customer
    @auraEnabled public String stripeTransactionToken; ////Auth or Charge Token id  if object is Charge
    @auraEnabled public String CustomerId; //Customer id populated if object is customer
    @auraEnabled public String cardLastFourDigit; // last 4 digits of credit or debit card.
    @auraEnabled public String cardExpiryMonth; //Expiry Month of the credit or debit card.
    @auraEnabled public String cardExpiryYear; //Expiry year of the credit or debit card
    @auraEnabled public String country;
    @auraEnabled public String email; //required when customer wants to save the payment
    @auraEnabled public String brand;
    @auraEnabled public String card;
    @auraEnabled public Decimal chargeAmount; //Amount to be paid for this transaction.
    @auraEnabled public String currencyCode;
    @auraEnabled public String type; //'authorized' or 'charged'
    @auraEnabled public String stripeChargeProcessError; //details of errors during stripe charge process
    @auraEnabled public String client_secret;
    @auraEnabled public String chargeCurrencyType; // type of currency in which charge be paid.
    @auraEnabled public String obj;// need to set up to object
    @auraEnabled public String payableNetAmount; //Amount to be paid for this transaction.
    @auraEnabled public String balance_transaction;
    @auraEnabled public String storefrontName; //current storefront.
    @auraEnabled public String cartId; //cartId.
    @auraEnabled public Map<String,Object> charges; //cartId.
}