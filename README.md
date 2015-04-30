# DSA Rule Engine

This a DSLink which allows you to write rules in which it uses to interact with DSA.

## Features

- Data Binding

## Example

```yaml
- type: bind
  from: /conns/Storage/test/message
  to:
    invoke: /conns/Chrome/Speak
    parameter: text
```

## Usage

```
pub get
dart bin/run.dart
```

Define your rules in the `rules.yaml` file.
