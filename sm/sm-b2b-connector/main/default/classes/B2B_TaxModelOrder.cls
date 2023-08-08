public with sharing class B2B_TaxModelOrder {
    public String taxType;
    public String taxEngineId;
    public Boolean isCommit;
    public String taxTransactionType;
    public DateTime transactionDate;
    public List<OrderProductLine> lineItems;
    public String currencyIsoCode;

    public class OrderProductLine {
        public String lineNumber;
        public Decimal amount;
    }
}