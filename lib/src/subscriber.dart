import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

abstract class Subscriber<T> extends StatefulWidget {
  const Subscriber({
    required this.child,
    required this.channel,
    Key? key,
  }) : super(key: key);

  final Widget Function(T?) child;
  final EventChannel channel;

  T decode(dynamic json);

  @override
  State<Subscriber<T>> createState() => _SubscriberState<T>();
}

class _SubscriberState<T> extends State<Subscriber<T>> {
  T? _data;
  StreamSubscription? _streamSubscription;

  void _start() {
    _streamSubscription ??=
        widget.channel.receiveBroadcastStream().listen(_update);
  }

  void _stop() {
    if (_streamSubscription != null) {
      _streamSubscription!.cancel();
      _streamSubscription = null;
    }
  }

  void _update(dynamic data) {
    setState(() => _data = widget.decode(data as String));
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
