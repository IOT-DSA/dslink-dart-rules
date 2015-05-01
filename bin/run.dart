import "dart:async";
import "dart:io";

import "package:dslink/client.dart";
import "package:dslink/requester.dart";
import "package:dslink/utils.dart";

import "package:dsa_rule_engine/rules.dart";
import "package:dsa_rule_engine/dataflow.dart";

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

  updateLogLevel("none");
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

  if (result is Map) {
    if (result.containsKey("rules")) {
      result = result["rules"];
    } else if (result.containsKey("rules_key")) {
      result = result[result["rules_key"]];
    } else {
      result = [];
    }
  }

  return result;
}

class CmdlineRuleManagerAdapter extends RuleManagerAdapter {
  final Map<String, RuleType> ruleTypes = {
    "bind": new BindRuleType(),
    "tick": new TickRuleType()
  };

  @override
  RuleContext getRuleContext(Map<String, dynamic> config) {
    return new CmdlineRuleContext(config);
  }

  @override
  RuleType getRuleType(String name) => ruleTypes[name];
}

final RegExp VAR_REGEX = new RegExp(r"\{\{(.+)\}\}");

class DataflowContextImpl extends DataflowContext {
  Map<String, dynamic> inputs = {};
  Map<String, dynamic> outputs = {};

  @override
  getInput(String name) {
    var val = inputs[name];

    if (val is String) {
      val = val.replaceAllMapped(VAR_REGEX, (Match match) {
        var name = match.group(1);
        var v = getInput(name);

        return v;
      });
    }

    return val;
  }

  @override
  void setOutput(String name, value) {
    outputs[name] = value;
  }

  @override
  void flip() {
    var tmp = outputs;
    outputs = inputs;
    inputs = tmp;
  }

  @override
  void clearOutputs() {
    outputs.clear();
  }

  @override
  void setInput(String name, value) {
    inputs[name] = value;
  }

  @override
  RuleContext rule;
}

class CmdlineRuleContext extends RuleContext {
  final Map<String, dynamic> config;

  CmdlineRuleContext(this.config);

  @override
  Requester get requester => link.link.requester;

  @override
  Future execute(action, [DataflowContext ctx]) async {
    if (ctx == null) {
      ctx = new DataflowContextImpl()..rule = this;
    }

    if (action is List) {
      DataflowContext c = ctx;
      for (var x in action) {
        await execute(x, c);
        c.flip();
        c.clearOutputs();
      }

      return;
    }

    var type = action["type"];

    if (blocks.containsKey(type)) {
      for (var n in action.keys) {
        ctx.setInput(n, action[n]);
      }

      await blocks[type].execute(ctx);
    }
  }
}

final Map<String, DataflowBlock> blocks = {
  "concatenate": new ConcatenateBlock(),
  "print": new PrintBlock(),
  "invoke": new InvokeBlock(),
  "getValue": new GetValueBlock()
};
