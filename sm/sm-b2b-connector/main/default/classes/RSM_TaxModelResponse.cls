global with sharing class RSM_TaxModelResponse {

    public AmountDetail amountDetails;
    public List<LineItem> lineItems;

    public class LineItem {
        public AmountDetail amountDetails;
        public String effectiveDate;
        public String lineNumber;
        public List<TaxItem> taxes;
    }

    public class AmountDetail {
        public Decimal taxAmount;
    }

    public class TaxItem {
        public Decimal rate;
        public Decimal tax;
    }
}