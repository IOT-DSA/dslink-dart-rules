part of dsa.rule_engine.dataflow;

class AccessBlock extends DataflowBlock {
  @override
  execute(DataflowContext context) async {
    var input = context.getInput("input");
    var index = context.getInput("index");

    return input[index];
  }

  @override
  List<String> get requiredInputs => ["input", "index"];
}
