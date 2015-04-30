part of dsa.rule_engine.rules;

class BindRuleType extends RuleType {
  ReqSubscribeListener listener;

  @override
  setup(RuleContext context) async {
    String from = context.config["from"];
    var to = context.config["to"];

    String ts;

    listener = context.subscribe(from, (ValueUpdate update) {
      if (ts == update.ts) {
        return;
      }

      ts = update.ts;

      var value = update.value;

      if (to is String) {
        context.set(to, value);
      } else if (to is Map) {
        var tp = to["invoke"];
        var tpa = to["parameter"];

        context.requester.invoke(tp, {
          tpa: value
        });
      }
    });
  }

  @override
  destroy(RuleContext context) async {
    if (listener != null) {
      await listener.cancel();
      listener = null;
    }
  }
}
