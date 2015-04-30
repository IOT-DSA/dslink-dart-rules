part of dsa.rule_engine.rules;

class RuleManager {
  final RuleManagerAdapter adapter;

  RuleManager(this.adapter);

  add(String typeName, Map<String, dynamic> config) async {
    var context = adapter.getRuleContext(config);
    var type = adapter.getRuleType(typeName);

    await type.setup(context);
  }
}

abstract class RuleManagerAdapter {
  RuleContext getRuleContext(Map<String, dynamic> config);
  RuleType getRuleType(String name);
}
