part of dsa.rule_engine.dataflow;

class PrintBlock extends DataflowBlock {
  @override
  execute(DataflowContext context) {
    print(context.getInput("message"));
  }

  @override
  List<String> requiredInputs = [];
}
