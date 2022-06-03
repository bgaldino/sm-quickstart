global class SM_LWCPricebookPicklist extends VisualEditor.DynamicPickList {
  VisualEditor.DesignTimePageContext context;

  global SM_LWCPricebookPicklist(VisualEditor.DesignTimePageContext context) {
    this.context = context;
  }

  global override VisualEditor.DataRow getDefaultValue() {
    Pricebook2 stdPricebook = [
      SELECT Id, Name, IsStandard
      FROM Pricebook2
      WHERE IsStandard = TRUE
      LIMIT 1
    ];
    String pbName = stdPricebook.Name;
    String pbId = String.valueOf(stdPricebook.Id);
    VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(
      pbName,
      pbId,
      true
    );
    return defaultValue;
  }

  global override VisualEditor.DynamicPickListRows getValues() {
    VisualEditor.DynamicPickListRows pbPicklist = new VisualEditor.DynamicPickListRows();

    Map<Id, Pricebook2> pricebooks = new Map<Id, Pricebook2>(
      [
        SELECT Id, Name, IsStandard, IsActive
        FROM Pricebook2
        WHERE IsActive = TRUE
      ]
    );
    for (Id key : pricebooks.keySet()) {
      String pbName = pricebooks.get(key).Name;
      String pbId = String.valueOf(key);
      VisualEditor.DataRow pbValue = new VisualEditor.DataRow(pbName, pbId);
      pbPicklist.addRow(pbValue);
    }

    return pbPicklist;
  }
}
