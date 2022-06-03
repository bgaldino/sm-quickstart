global class SM_LWCGatewayPicklist extends VisualEditor.DynamicPickList {
  VisualEditor.DesignTimePageContext context;

  global SM_LWCGatewayPicklist(VisualEditor.DesignTimePageContext context) {
    this.context = context;
  }

  global override VisualEditor.DataRow getDefaultValue() {
    PaymentGateway payGate = [
      SELECT Id, PaymentGatewayName, Status
      FROM PaymentGateway
      WHERE Status = 'Active'
      LIMIT 1
    ];
    String label = payGate.PaymentGatewayName;
    String value = String.valueOf(payGate.Id);
    VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(
      label,
      value,
      true
    );
    return defaultValue;
  }

  global override VisualEditor.DynamicPickListRows getValues() {
    VisualEditor.DynamicPickListRows pgPicklist = new VisualEditor.DynamicPickListRows();

    Map<Id, PaymentGateway> payGateways = new Map<Id, PaymentGateway>(
      [
        SELECT Id, PaymentGatewayName, Status
        FROM PaymentGateway
        WHERE Status = 'Active'
      ]
    );
    for (Id key : payGateways.keySet()) {
      String label = payGateways.get(key).PaymentGatewayName;
      String value = String.valueOf(key);
      VisualEditor.DataRow pgValue = new VisualEditor.DataRow(label, value);
      pgPicklist.addRow(pgValue);
    }

    return pgPicklist;
  }
}
