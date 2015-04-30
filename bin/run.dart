import "dart:async";
import "dart:io";

import "package:dslink/client.dart";
import "package:dslink/requester.dart";

import "package:dsa_rule_engine/rules.dart";

import "package:yaml/yaml.dart";

LinkProvider link;
Requester requester;
RuleManager manager;

main(List<String> args) async {
  link = new LinkProvider(args, "RuleEngine-", isRequester: true, isResponder: false);

  link.connect();
  requester = await link.link.onRequesterReady;
  List<Map<String, dynamic>> rules = await loadRules();
  print("Rules Loaded.");
  manager = new RuleManager(new CmdlineRuleManagerAdapter());

  for (var rule in rules) {
    await manager.add(rule["type"], rule);
  }
}

Future<List<Map<String, dynamic>>> loadRules() async {
  var file = new File("rules.yaml");

  if (!(await file.exists())) {
    await file.create(recursive: true);
  }

  var result = loadYaml(await file.readAsString());

  if (result == null) {
    result = [];
  }

  return result;
}

class CmdlineRuleManagerAdapter extends RuleManagerAdapter {
  final Map<String, RuleType> ruleTypes = {
    "bind": new BindRuleType()
  };

  @override
  RuleContext getRuleContext(Map<String, dynamic> config) {
    return new CmdlineRuleContext(config);
  }

  @override
  RuleType getRuleType(String name) => ruleTypes[name];
}

class CmdlineRuleContext extends RuleContext {
  final Map<String, dynamic> config;

  CmdlineRuleContext(this.config);

  @override
  Requester get requester => link.link.requester;
}
