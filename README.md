[![](https://img.shields.io/badge/Buijs-Software-blue)](https://pub.dev/publishers/buijs.dev/packages)
[![GitHub license](https://img.shields.io/github/license/buijs-dev/klutter-dart-ui?color=black&logoColor=black)](https://github.com/buijs-dev/klutter-dart-ui/blob/main/LICENSE)
[![pub](https://img.shields.io/pub/v/klutter_ui)](https://pub.dev/packages/klutter_ui)
[![codecov](https://codecov.io/gh/buijs-dev/klutter-dart-ui/branch/main/graph/badge.svg?token=z0HCTKNLn5)](https://codecov.io/gh/buijs-dev/klutter-dart-ui)
[![CodeScene Code Health](https://codescene.io/projects/38075/status-badges/code-health)](https://codescene.io/projects/38075)

<img src="https://github.com/buijs-dev/klutter/blob/develop/.github/assets/metadata/icon/klutter_logo.png?raw=true" alt="buijs software logo" />

Flutter Widgets to be used in conjunction with the [klutter plugin](https://github.com/buijs-dev/klutter-dart).
Full support for:

- [MethodChannel](#MethodChannel)
- [EventChannel](#EventChannel)

## MethodChannel
Example function which invokes method foo on the given channel and returns a String value.

```dart
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:klutter_ui/klutter_ui.dart';

const MethodChannel _channel =
    MethodChannel('foo.bar.plugin/channel/my_simple_controller');

void foo({
  State? state,
  void Function(String)? onSuccess,
  void Function(Exception)? onFailure,
}) =>
    doEvent<String>(
      state: state,
      event: "foo",
      channel: _channel,
      onSuccess: onSuccess,
      onFailure: onFailure,
    );
```

Using the function as a tearoff requires just a single line of code:

```dart
TextButton(onPressed: foo, child: Text("Click"))
```

## EventChannel
Example implementation of a Subscriber (statefull widget) which subscribes to a channel and updates it state
everytime a new counter value is received.

```dart
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:klutter_ui/klutter_ui.dart';

const _stream = EventChannel('foo.bar.plugin/channel/counter');

class Counter extends Subscriber<int> {
    const Counter({
      required Widget Function(int?) builder,
      Key? key,
    }) : super(
      builder: builder,
      channel: _stream,
      topic: "counter",
      key: key,
    );
    
    @override
    int decode(dynamic json) => json as int;
}
```

All that is required to use the returned data is to wrap any widget with the Counter widget and then use it's value.

```dart
Counter(builder: (res) => Text("$res")),
```