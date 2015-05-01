part of dsa.rule_engine.dataflow;

class GetValueBlock extends DataflowBlock {
  @override
  execute(DataflowContext context) async {
    String path = context.getInput("path");
    String varName = context.getInput("var");

    if (varName == null) varName = "value";

    ReqSubscribeListener listener;

    Completer c = new Completer();

    listener = context.rule.subscribe(path, (ValueUpdate update) {
      var value = update.value;
      context.setOutput(varName, value);
      listener.cancel();
      c.complete();
    });

    await c.future;
  }

  @override
  List<String> get requiredInputs => ["path"];
}
