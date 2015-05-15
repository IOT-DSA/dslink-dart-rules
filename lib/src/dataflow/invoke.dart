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
      for (var x in r.keys) {
        context.setOutput(x, r[x]);
      }
    } else {
      var data = [];
      var updates = [];

      for (var update in result) {
        data.addAll(update.rows);
        updates.add({
          "columns": update.rawColumns,
          "rows": update.rows,
          "updates": update.updates
        });
      }

      context.setOutput("rows", data);
      context.setOutput("updates", updates);
    }

    if (context.getInput("with") != null || context.getInput("execute") != null) {
      context.flip();
      var i = context.getInput("with");
      if (i == null) i = context.getInput("execute");
      await context.rule.execute(i, context);
      context.flip();
    }
  }

  @override
  List<String> requiredInputs = ["path"];
}
