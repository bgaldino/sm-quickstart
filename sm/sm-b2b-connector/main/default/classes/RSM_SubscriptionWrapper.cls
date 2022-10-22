public class RSM_SubscriptionWrapper {

	public Integer subscriptionTerm;
	public String endDate;
	public String startDate;
	public String roundingMode;
	public String listPricebookId;
	public List<String> candidatePricebookIds;
	public String pricingFlow;
	public Graph graph;
    
	public class Graph {
		public String graphId;
		public List<Records> records;
	}

	public class Attributes {
		public String type;
	}

	public class Record {
		public Attributes attributes;
		public String CurrencyIsoCode;
	}

	public class SalesTransactionItem {

		public Attributes attributes;
		public String CurrencyIsoCode;
		public String SalesTransactionId;
        public String ProductSellingModelId;
		public String ProductId;
		public Integer Quantity;
	}

	public class PriceAdjustmentGroup {
		public Attributes attributes;
		public String SalesTransactionId;
		public String AdjustmentType;
		public Integer AdjustmentValue;
		public String AdjustmentSource;
		public String Description;
	}

    public class PriceAdjustmentItem {
		public Attributes attributes;
		public String SalesTransactionItemId;
		public String AdjustmentType;
		public Integer AdjustmentValue;
		public String AdjustmentSource;
		public String Description;
	}

	public class Records {
		public String referenceId;
		public Object record;
	}


    public RSM_SubscriptionWrapper(String listPricebookId,List<String> candidatePricebookIds){
        this.listPricebookId = listPricebookId;
        this.candidatePricebookIds = candidatePricebookIds;
        this.pricingFlow = 'GET_FINAL_PRICE';
        this.subscriptionTerm = 1;
	    this.startDate = '2021-01-01';
	    this.roundingMode = 'RoundUp';

    }

    public String getTermPriceProduct(RSM_SubscriptionWrapper pricingEngine,String productId,Integer quantity,String productSellingModelId, String CurrencyIsoCode){
        
        Graph graph = new Graph();
        List<Records> records = new List<Records> ();
        graph.records = records;
        graph.graphId = '1';
        /*SalesTransaction  record*/
        Records stRecords =  new Records();
        Record stRecord = new Record();
        Attributes stAttributes = new Attributes();
        stRecord.attributes = stAttributes;
        stAttributes.type = 'SalesTransaction';
        stRecord.CurrencyIsoCode = CurrencyIsoCode;
        stRecords.record = stRecord;
        stRecords.referenceId='ref_sales_txn';
        records.add(stRecords);
        /*SalesTransaction  record end */

        /*SalesTransactionItem  record*/
        Records stiRecords =  new Records();
        SalesTransactionItem stiRecord = new SalesTransactionItem();
        Attributes stiAttributes = new Attributes();
        stiRecord.attributes = stiAttributes;
        stiAttributes.type = 'SalesTransactionItem';
        stiRecord.CurrencyIsoCode = CurrencyIsoCode;
        stiRecord.SalesTransactionId = '@{ref_sales_txn.Id}';
        stiRecord.ProductId = productId;
        stiRecord.Quantity = quantity;
        stiRecord.ProductSellingModelId = productSellingModelId;
        stiRecords.record = stiRecord;
        stiRecords.referenceId='ref_sales_txn_item1';
        records.add(stiRecords);
        /*SalesTransactionItem  record end */
        pricingEngine.graph = graph;

        return JSON.serialize(pricingEngine);
    }




}