// Copyright (c) 2021 - 2023 Buijs Software
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
import "dart:async";

import "package:flutter/services.dart";
import "package:flutter/widgets.dart";

/// A widget that receives 0 or more messages of type [T]
/// and automatically updates it and it's dependents state.
///
/// Example implementation:
///
/// ```dart
/// const _stream = EventChannel('foo.bar.plugin/channel/counter');
///
/// class Counter extends Subscriber<int> {
///     const Counter({
///       required Widget Function(int?) child,
///       Key? key,
///     }) : super(
///       child: child,
///       channel: _stream,
///       topic: "counter",
///       key: key,
///     );
///
///     @override
///     int decode(dynamic json) => json as int;
/// }
/// ```
abstract class Subscriber<T> extends StatefulWidget {
  /// Construct a new instance.
  const Subscriber({
    required this.child,
    required this.channel,
    required this.topic,
    Key? key,
  }) : super(key: key);

  /// Any widget which wants access to the [T] data stream.
  final Widget Function(T?) child;

  /// Channel on which to subscribe.
  final EventChannel channel;

  /// Topic on which to subscribe.
  ///
  /// Topic values are used to determine if data on a channel
  /// is intended for this [Subscriber].
  final String topic;

  /// Decoding function used to decode data of Type [T].
  ///
  /// If [T] is a StandardMessageCodec Type then a simple cast will suffice:
  ///
  /// ```dart
  ///     @override
  ///     int decode(dynamic json) => json as int;
  /// ```
  T decode(dynamic json);

  @override
  State<Subscriber<T>> createState() => _SubscriberState<T>();
}

class _SubscriberState<T> extends State<Subscriber<T>> {
  T? _data;
  StreamSubscription? _streamSubscription;

  void _start() {
    _streamSubscription ??=
        widget.channel.receiveBroadcastStream(widget.topic).listen(_update);
  }

  void _stop() {
    if (_streamSubscription != null) {
      _streamSubscription!.cancel();
      _streamSubscription = null;
    }
  }

  void _update(dynamic data) {
    setState(() => _data = widget.decode(data));
  }

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child.call(_data);
  }
}
