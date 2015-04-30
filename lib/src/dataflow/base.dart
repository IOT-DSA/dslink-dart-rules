part of dsa.rule_engine.dataflow;

abstract class DataflowContext {
  dynamic getInput(String name);
  void setOutput(String name, dynamic value);
}

abstract class DataflowBlock {
  List<String> get requiredInputs;
  execute(DataflowContext context);
}
