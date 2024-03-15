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

import "adapter.dart";

/// Send an event to Android/iOS platform and wait for a response [AdapterResponse].
///
/// Example implementation:
///
/// ```dart
/// const MethodChannel _channel =
///     MethodChannel('foo.bar.plugin/channel/my_simple_controller');
///
/// void foo({
///   State? state,
///   void Function(String)? onSuccess,
///   void Function(Exception)? onFailure,
/// }) =>
///     doEvent<String>(
///       state: state,
///       event: "foo",
///       channel: _channel,
///       onSuccess: onSuccess,
///       onFailure: onFailure,
///     );
/// ```
Future<AdapterResponse<OUT>> doEvent<OUT>({
  /// Name of the event.
  ///
  /// This name is used on the platform-side to determine which method to invoke.
  required String event,

  /// MethodChannel where the event is to be published.
  required MethodChannel channel,

  /// (Optional) Data to be send with the event.
  ///
  /// E.g. if the method to be invoked requires parameters then add them as message.
  dynamic message,

  /// (Optional) State of widget from where the event is send.
  ///
  /// Used to determine if the state is mounted.
  /// If not then callbacks are not executed.
  State? state,

  /// (Optional) Decoding function used to decode the received JSON response.
  OUT Function(String)? decode,

  /// (Optional) Encoding function used to encode message if is not
  /// a StandardMessageCodec Type.
  String Function(dynamic)? encode,

  /// (Optional) Decoding function used to decode the received buffer response.
  OUT Function(List<int>)? decodeBuffer,

  /// (Optional) Encoding function used to encode message as buffer if is not
  /// a StandardMessageCodec Type.
  Uint8List Function(dynamic)? encodeBuffer,

  /// (Optional) Function to be executed if the event is processed successfully.
  void Function(OUT)? onSuccess,

  /// (Optional) Function to be executed if the event is processed unsuccessfully.
  void Function(Exception)? onFailure,

  /// (Optional) Function to be executed if the received response data is null.
  void Function()? onNullValue,

  /// (Optional) Function to be executed when the event is processed, regardless success (or NOT).
  void Function(AdapterResponse<OUT>)? onComplete,
}) async {
  /// Create a request message.
  ///
  /// If [message] is null then [request] is also null.
  final dynamic request = _toRequestMessage(message, encode, encodeBuffer);

  /// Send the event and wait for a response.
  final response = await _sendEvent(
    sendRequest: () => channel.invokeMethod<dynamic>(event, request),
    decode: decode,
    decodeBuffer: decodeBuffer
  );

  /// Check if state is mounted.
  ///
  /// if not then skip all callbacks and return the response.
  if (state?.mounted ?? true) {
    if (response.isSuccess) {
      onSuccess?.call(response.object);
    } else {
      onFailure?.call(response.exception);
    }
    onComplete?.call(response);
  }

  return response;
}

Future<AdapterResponse<OUT>> _sendEvent<OUT>({
  required dynamic Function() sendRequest,
  OUT Function(String)? decode,
  OUT Function(List<int>)? decodeBuffer,
}) async {
  try {
    final dynamic responseMessage = _handleResult(
      response: await sendRequest.call(),
      decode: decode,
      decodeBuffer: decodeBuffer,
    );

    return AdapterResponse<OUT>.success(responseMessage as OUT);
  } catch (e) {
    return AdapterResponse<OUT>.failure(_failureToException(e));
  }
}

Exception _failureToException(dynamic e) =>
    e is Error ? Exception(e.stackTrace) : e as Exception;

dynamic _toRequestMessage(
    dynamic message,
    String Function(dynamic)? encode,
    Uint8List Function(dynamic)? encodeBuffer,
) {
  if (message == null) {
    return null;
  }

  if(encodeBuffer != null) {
    return encodeBuffer(message);
  }

  if (encode != null) {
    return encode(message);
  }

  return message;
}

dynamic _handleResult<OUT>({
  dynamic response,
  OUT Function(String)? decode,
  OUT Function(List<int>)? decodeBuffer,
}) {
  if (response == null) {
    return response;
  }
  return decodeBuffer?.call(response as List<int>)
      ?? decode?.call(response.toString())
      ?? response;

}
