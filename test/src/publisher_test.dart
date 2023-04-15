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

class FakeChannel extends MethodChannel {
  FakeChannel(String name) : super(name);

  dynamic expected;

  @override
  Future<T?> invokeMethod<T>(String method, [ dynamic arguments ]) {
    return Future.value(expected as T);
  }

}

void main() {

  late MethodChannel channel;

  setUp(() {
    channel = FakeChannel("klutter.foo/publisher/stream");
    WidgetsFlutterBinding.ensureInitialized();
  });

  test("Execute an event which has no message and expects a standard type response", () async {
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

}
