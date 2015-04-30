part of dsa.rule_engine.rules;

abstract class RuleType {
  setup(RuleContext context);
  destroy(RuleContext context);
}

abstract class RuleContext {
  Requester get requester;
  Map<String, dynamic> get config;

  ReqSubscribeListener subscribe(String path, void callback(ValueUpdate update), {int cacheLevel: 1}) {
    return requester.subscribe(path, callback, cacheLevel);
  }

  Future<RequesterUpdate> set(String path, dynamic value) {
    return requester.set(path, value);
  }

  Future execute(action, [DataflowContext context]);
}

