// Copyright (c) 2021 - 2022 Buijs Software
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

import "package:flutter/services.dart";
import "package:flutter/widgets.dart";
import "package:klutter_ui/klutter_ui.dart";
import "package:test/test.dart";

void main() {
  late MethodChannel channel;
  late MethodChannel brokenChannel;
  setUp(() {
    channel = FakeChannel("klutter.foo/publisher/stream");
    brokenChannel = BrokenChannel("klutter.foo/publisher/stream/says/boom");
    WidgetsFlutterBinding.ensureInitialized();
  });

  test(
      "Execute an event which has no message and expects a standard type response",
      () async {
    // given:
    const configuredEvent = "sayHi";
    const expectedResult = "Hi!";

    // and:
    (channel as FakeChannel).expected = expectedResult;

    // when:
    final result = await doEvent<String>(
      event: configuredEvent,
      channel: channel,
    );

    // then:
    expect(result.isSuccess, true);
    expect(result.object, expectedResult);
  });

  test("All callbacks are ignored if state is not mounted", () async {
        // given:
        const configuredEvent = "sayHi";
        const expectedResult = "Hi!";

        // and:
        (channel as FakeChannel).expected = expectedResult;

        // when:
        final result = await doEvent<String>(
          state: const NeverMounted().createState(),
          event: configuredEvent,
          channel: channel,
          onComplete: (str) => throw Exception("Complete!"),
          onSuccess: (str) => throw Exception("Success!"),
          onFailure: (str) => throw Exception("Failure!"),
        );

        // then:
        expect(result.isSuccess, true);
      });

  test("OnFailure is ignored if event was successfully processed", () async {
    // given:
    const configuredEvent = "sayHi";
    const expectedResult = "Hi!";

    var success = false;
    var completed = false;

    // and:
    (channel as FakeChannel).expected = expectedResult;

    // when:
    final result = await doEvent<String>(
      state: const AlwaysMounted().createState(),
      event: configuredEvent,
      channel: channel,
      onComplete: (str) => completed = true,
      onSuccess: (str) => success = true,
      onFailure: (str) => throw Exception("Failure!"),
    );

    // then:
    expect(result.isSuccess, true);
    expect(success, true);
    expect(completed, true);
  });

  test("OnSuccess is ignored if event was a failure", () async {
    // given:
    const configuredEvent = "sayHi";

    var failure = false;
    var completed = false;

    // and:
    (brokenChannel as BrokenChannel).message = "Boom!";

    // when:
    final result = await doEvent<String>(
      state: const AlwaysMounted().createState(),
      event: configuredEvent,
      channel: channel,
      onComplete: (str) => completed = true,
      onSuccess: (str) => throw Exception("Success!"),
      onFailure: (str) => failure =true,
    );

    // then:
    expect(result.isSuccess, false);
    expect(failure, true);
    expect(completed, true);
  });
}

class FakeChannel extends MethodChannel {
  FakeChannel(String name) : super(name);

  dynamic expected;

  @override
  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) {
    return Future.value(expected as T);
  }
}

class BrokenChannel extends MethodChannel {
  BrokenChannel(String name) : super(name);

  String? message;

  @override
  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) {
    throw Exception(message);
  }
}

class NeverMounted extends StatefulWidget {
  const NeverMounted({Key? key}) : super(key: key);

  @override
  State<NeverMounted> createState() => _NeverMountedState();
}

class _NeverMountedState extends State<NeverMounted> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  @override
  bool get mounted => false;
}

class AlwaysMounted extends StatefulWidget {
  const AlwaysMounted({Key? key}) : super(key: key);

  @override
  State<AlwaysMounted> createState() => _AlwaysMountedState();
}

class _AlwaysMountedState extends State<AlwaysMounted> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  @override
  bool get mounted => true;
}
