part of dsa.rule_engine.dataflow;

class SetValueBlock extends DataflowBlock {
  @override
  execute(DataflowContext context) async {
    var path = context.getInput("path");
    var value = context.getInput("value");

    await context.rule.set(path, value);

    context.setOutput("value", value);
  }

  @override
  List<String> get requiredInputs => ["path", "value"];
}
