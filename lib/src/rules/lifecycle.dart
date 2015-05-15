part of dsa.rule_engine.rules;

class LifecycleRuleType extends RuleType {
  @override
  setup(RuleContext context) {
    if (context.config.containsKey("setup")) {
      context.execute(context.config["setup"]);
    }
  }

  @override
  destroy(RuleContext context) {
    if (context.config.containsKey("destroy")) {
      context.execute(context.config["destroy"]);
    }
  }
}
