import "dart:async";

import "package:flutter/services.dart";
import "package:flutter/widgets.dart";

import "adapter.dart";

Future<AdapterResponse<OUT>> doEvent<OUT>({
  required String event,
  required MethodChannel channel,
  dynamic message,
  State? state,
  OUT Function(String)? decode,
  String Function(dynamic)? encode,
  void Function(OUT)? onSuccess,
  void Function(Exception)? onFailure,
  void Function()? onNullValue,
  void Function(AdapterResponse<OUT>)? onComplete,
}) async {
  final dynamic request = _toRequestMessage(message, encode);

  final response = await _sendEvent(
    sendRequest: () => channel.invokeMethod<dynamic>(event, request),
    deserialize: decode,
  );

  if (state?.mounted ?? true) {
    onComplete?.call(response);
    if (response.isSuccess) {
      onSuccess?.call(response.object);
    } else {
      onFailure?.call(response.exception);
    }
  }

  return response;
}

Future<AdapterResponse<OUT>> _sendEvent<OUT>({
  required dynamic Function() sendRequest,
  OUT Function(String)? deserialize,
}) async {
  try {
    final dynamic responseMessage = _handleResult(
      response: await sendRequest.call(),
      deserialize: deserialize,
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
) {
  if (message == null) {
    return null;
  }

  if (encode == null) {
    return message;
  }

  return encode.call(message);
}

dynamic _handleResult<OUT>({
  dynamic response,
  OUT Function(String)? deserialize,
}) =>
    deserialize?.call(response.toString()) ?? response;
