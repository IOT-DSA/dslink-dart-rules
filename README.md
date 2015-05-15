# DSA Rule Engine

This a DSLink which allows you to write rules in which it uses to interact with DSA.

## Features

- Rule DSL
- Data Binding
- Data Flow

## Example

```yaml
- =: bind
  from: /conns/Storage/alex/msg
  to:
    invoke: /conns/Chrome/Speak
    parameter: text
- =: tick
  seconds: 5
  execute:
  - =: invoke
    path: /conns/Chrome/Speak
    params:
      text: "Hello World"
```

## Usage

```
pub get
dart bin/run.dart
```

Define your rules in the `rules.yaml` file.
