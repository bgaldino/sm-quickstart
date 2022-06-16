global class CPQB_QuickKeySetupPicklist extends VisualEditor.DynamicPickList{
    VisualEditor.DesignTimePageContext context;

    global CPQB_QuickKeySetupPicklist(VisualEditor.DesignTimePageContext context) {
       this.context = context;
    }

    global override VisualEditor.DataRow getDefaultValue() {
        if(context.entityName == 'SBQQ__Quote__c') {
            VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('-- Set on Quote --', '');
            return defaultValue;
        } else {
            Pricebook2 stdPricebook = [SELECT Id, Name, IsStandard FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
            String pbName = stdPricebook.Name;
            String pbId = String.valueOf(stdPricebook.Id);
            VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(pbName, pbId, true);
            return defaultValue;
        }

    }

    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows pbPicklist = new VisualEditor.DynamicPickListRows();

        if(context.entityName == 'SBQQ__Quote__c') {
            VisualEditor.DataRow pbValue = new VisualEditor.DataRow('-- Set on Quote --', '');
            pbPicklist.addRow(pbValue);
        } else {
            Map<Id,Pricebook2> pricebooks = new Map<Id,Pricebook2>([SELECT Id, Name, IsStandard, IsActive FROM Pricebook2 WHERE IsActive = true]);
            for(Id key : pricebooks.keySet()) {
                String pbName = pricebooks.get(key).Name;
                String pbId = String.valueOf(key);
                VisualEditor.DataRow pbValue = new VisualEditor.DataRow(pbName, pbId);
                pbPicklist.addRow(pbValue);
            }
        }

        return pbPicklist;
    }
}