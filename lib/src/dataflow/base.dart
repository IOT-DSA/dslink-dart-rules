part of dsa.rule_engine.dataflow;

abstract class DataflowContext {
  Map<String, dynamic> get outputs;
  Map<String, dynamic> get inputs;
  RuleContext get rule;

  dynamic getInput(String name);
  void setInput(String name, dynamic value);
  void setOutput(String name, dynamic value);
  void flip();
  void clearOutputs();
  void reset();
}

abstract class DataflowBlock {
  List<String> get requiredInputs;
  execute(DataflowContext context);
}
