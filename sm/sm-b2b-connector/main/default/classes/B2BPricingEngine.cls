/**
 * @description       : 
 * @author            : Prabhat Kumar
 * @group             : 
 * @last modified on  : 24-05-2022
 * @last modified by  : Prabhat Kumar
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   03-03-2023   Prabhat Kumar  Initial Version
**/
public with sharing class B2BPricingEngine {
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

	public B2BPricingEngine(String listPricebookId,List<String> candidatePricebookIds){
        this.listPricebookId = listPricebookId;
        this.candidatePricebookIds = candidatePricebookIds;
        this.pricingFlow = 'GET_FINAL_PRICE';
    }
	
    public String getRequestWithNoPAINoPAGandSubscriptionsEnabled(B2BPricingEngine pricingEngine,String productId,Integer quantity,String productSellingModelId, String CurrencyIsoCode){
        
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

    public String getRequestWithPercentDiscretionaryPAGandSubscriptionsEnabled(B2BPricingEngine pricingEngine,List<B2BPricingEngine.SalesTransactionItem> salestransactionList ,Integer discount,Boolean isDiscountApplicable){
        
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
        stRecord.CurrencyIsoCode = 'USD';
        stRecords.record = stRecord;
        stRecords.referenceId='ref_sales_txn';
        records.add(stRecords);
        /*SalesTransaction  record end */

        /*SalesTransactionItem  record*/
        Integer salesTxnRefIndex = 1;
        for(SalesTransactionItem st : salestransactionList){
            System.debug('sales transaction'+st);
           
            Records stiRecords =  new Records();
            SalesTransactionItem stiRecord = new SalesTransactionItem();
            Attributes stiAttributes = new Attributes();
            stiRecord.attributes = stiAttributes;
            stiAttributes.type = 'SalesTransactionItem';
            stiRecord.CurrencyIsoCode = st.CurrencyIsoCode;
            stiRecord.SalesTransactionId = '@{ref_sales_txn.Id}';
            
            stiRecord.ProductId = st.ProductId;
            stiRecord.Quantity = st.Quantity;
            stiRecord.ProductSellingModelId = st.ProductSellingModelId;
            stiRecords.record = stiRecord;
            stiRecords.referenceId='ref_sales_txn_item'+salesTxnRefIndex;
            salesTxnRefIndex++;
            records.add(stiRecords);
        }
        
        /*SalesTransactionItem  record end */
        if(isDiscountApplicable){
            /*PriceAdjustmentGroup  record*/
            Records pagRecords =  new Records();
            PriceAdjustmentGroup pagRecord = new PriceAdjustmentGroup();
            Attributes pagAttributes = new Attributes();
            pagRecord.attributes = pagAttributes;
            pagAttributes.type = 'PriceAdjustmentGroup';
        
            pagRecord.SalesTransactionId = '@{ref_sales_txn.Id}';
            pagRecord.AdjustmentType = 'AdjustmentPercentage';
            pagRecord.AdjustmentValue = discount;
            pagRecord.AdjustmentSource = 'Discretionary';
            pagRecord.Description = '10% Discretionary Discount applied at the header level';
        
            pagRecords.record = pagRecord;
            pagRecords.referenceId='ref_price_adjustment_group1';
            records.add(pagRecords);
            /*PriceAdjustmentGroup  record end */
        }
        
        pricingEngine.graph = graph;
        
        return JSON.serialize(pricingEngine);
    }

    public String getRequestWithPercentDiscretionaryPAIandSubscriptionsEnabled(B2BPricingEngine pricingEngine,List<B2BPricingEngine.SalesTransactionItem> salestransactionList ,Integer discount,Boolean isDiscountApplicable){
        
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
        stRecord.CurrencyIsoCode = 'USD';
        stRecords.record = stRecord;
        stRecords.referenceId='ref_sales_txn';
        records.add(stRecords);
        /*SalesTransaction  record end */

        /*SalesTransactionItem  record*/
        Integer salesTxnRefIndex = 1;
        for(SalesTransactionItem st : salestransactionList){
            System.debug('sales transaction'+st);
           
            Records stiRecords =  new Records();
            SalesTransactionItem stiRecord = new SalesTransactionItem();
            Attributes stiAttributes = new Attributes();
            stiRecord.attributes = stiAttributes;
            stiAttributes.type = 'SalesTransactionItem';
            stiRecord.CurrencyIsoCode = st.CurrencyIsoCode;
            stiRecord.SalesTransactionId = '@{ref_sales_txn.Id}';
            
            stiRecord.ProductId = st.ProductId;
            stiRecord.Quantity = st.Quantity;
            stiRecord.ProductSellingModelId = st.ProductSellingModelId;
            stiRecords.record = stiRecord;
            stiRecords.referenceId='ref_sales_txn_item'+salesTxnRefIndex;
            salesTxnRefIndex++;
            records.add(stiRecords);
        }
        
        /*SalesTransactionItem  record end */
        if(isDiscountApplicable){
            /*PriceAdjustmentItem  record*/
            Records paiRecords =  new Records();
            PriceAdjustmentItem paiRecord = new PriceAdjustmentItem();
            Attributes paiAttributes = new Attributes();
            paiRecord.attributes = paiAttributes;
            paiAttributes.type = 'PriceAdjustmentItem';
        
            paiRecord.SalesTransactionItemId = '@{ref_sales_txn_item1.Id}';
            paiRecord.AdjustmentType = 'AdjustmentPercentage';
            paiRecord.AdjustmentValue = discount;
            paiRecord.AdjustmentSource = 'Discretionary';
            paiRecord.Description = '10% Discretionary Discount applied at the header level';
        
            paiRecords.record = paiRecord;
            paiRecords.referenceId='ref_price_adjustment_item1';
            records.add(paiRecords);
            /*PriceAdjusPriceAdjustmentItemtmentGroup  record end */
        }
        
        pricingEngine.graph = graph;
        
        return JSON.serialize(pricingEngine);
    }
}