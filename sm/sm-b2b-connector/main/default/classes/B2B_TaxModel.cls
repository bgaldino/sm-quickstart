public with sharing class B2B_TaxModel {
    public String taxType;
    public String taxEngineId;
    public Boolean isCommit;
    public String taxTransactionType;
    public DateTime transactionDate;
    public List<CartProductLine> lineItems;
    public String currencyIsoCode;

    public class CartProductLine {
        public String lineNumber;
        public Decimal amount;
    }
}