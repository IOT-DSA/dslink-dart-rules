import "dart:async";
import "dart:io";

import "package:dslink/client.dart";
import "package:dslink/requester.dart";
import "package:dslink/utils.dart";

import "package:dsa_rule_engine/rules.dart";
import "package:dsa_rule_engine/dataflow.dart";

import "package:yaml/yaml.dart";
import "package:logging/logging.dart";

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
    var type = rule.containsKey("type") ? rule["type"] : rule["="];

    if (type == null) {
      print("Error in rule ${rule}: type not specified. Skipping.");
      continue;
    }

    await manager.add(type, rule);
  }

  logger.level = Level.SEVERE;
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
  void reset() {
    outputs.clear();
    inputs.clear();
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
      Map<String, dynamic> data = {};
      for (var x in action) {
        for (var key in data.keys) {
          c.setInput(key, data[key]);
        }

        await execute(x, c);

        for (var key in c.outputs.keys) {
          data[key] = c.outputs[key];
        }

        c.reset();
      }
      return;
    }

    var type = action.containsKey("type") ? action["type"] : action["="];

    if (type == null) {
      print("Error in rule ${config}: type for action ${action} not specified. Skipping rule.");
      return;
    }

    if (blocks.containsKey(type)) {
      var b = blocks[type];
      List<String> missing = b.requiredInputs.where((it) => !action.containsKey(it)).toList();
      if (missing.isNotEmpty) {
        print("Error in rule ${config}: type for action ${action} is missing the required inputs ${missing}. Skipping rule.");
        return;
      }

      for (var n in action.keys) {
        ctx.setInput(n, action[n]);
      }

      await b.execute(ctx);
    } else {
      print("Error in rule ${config}: type for action ${action} is not valid. Skipping rule.");
      return;
    }
  }
}

final Map<String, DataflowBlock> blocks = {
  "concatenate": new ConcatenateBlock(),
  "print": new PrintBlock(),
  "invoke": new InvokeBlock(),
  "getValue": new GetValueBlock(),
  "setValue": new SetValueBlock()
};
