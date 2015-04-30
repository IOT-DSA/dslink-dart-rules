part of dsa.rule_engine.dataflow;

abstract class DataflowContext {
  RuleContext get rule;
  dynamic getInput(String name);
  void setInput(String name, dynamic value);
  void setOutput(String name, dynamic value);
  void flip();
  void clearOutputs();
}

abstract class DataflowBlock {
  List<String> get requiredInputs;
  execute(DataflowContext context);
}
