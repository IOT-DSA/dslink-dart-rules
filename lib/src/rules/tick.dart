part of dsa.rule_engine.rules;

class TickRuleType extends RuleType {
  Timer timer;

  @override
  setup(RuleContext context) {
    int ms;

    if (context.config.containsKey("milliseconds")) {
      ms = context.config["milliseconds"];
    } else if (context.config.containsKey("seconds")) {
      ms = context.config["seconds"] * 1000;
    }

    timer = new Timer.periodic(new Duration(milliseconds: ms), (_) async {
      await context.execute(context.config["execute"]);
    });
  }

  @override
  destroy(RuleContext context) {
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
  }
}
