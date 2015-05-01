part of dsa.rule_engine.dataflow;

class InvokeBlock extends DataflowBlock {
  @override
  execute(DataflowContext context) async {
    var path = context.getInput("path");
    var params = context.getInput("params");
    if (params == null) params = {};
    List<RequesterInvokeUpdate> result = await context.rule.requester.invoke(path, params).toList();
    if (result.length == 1 && result.first.updates.first.length == 1) {
      var r = result.first.updates.first;
      var i = 0;
      for (var x in r.keys) {
        context.setOutput(x, r[x]);
        i++;
      }
    }
  }

  @override
  List<String> requiredInputs = ["path"];
}
