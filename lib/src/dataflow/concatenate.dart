part of dsa.rule_engine.dataflow;

class ConcatenateBlock extends DataflowBlock {
  @override
  List<String> requiredInputs = ["name"];

  @override
  execute(DataflowContext context) {
    var inputs = context.getInput("inputs");
    var buff = new StringBuffer();
    for (var input in inputs) {
      buff.write(input);
    }
    return buff.toString();
  }
}
