import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'request/authorization_request.dart';
import 'model/config.dart';

class RequestCode {
  final StreamController<String?> _onCodeListener = StreamController();
  final Config _config;
  final AuthorizationRequest _authorizationRequest;
  void Function()? onCancel;

  var _onCodeStream;

  RequestCode(Config config, this.onCancel) : _config = config, _authorizationRequest = AuthorizationRequest(config);

  Future<String> requestCode() async {
    var code;
    final urlParams = _constructUrlParams();

    if (_config.context != null) {
      var initialURL =
      ('${_authorizationRequest.url}?$urlParams').replaceAll(' ', '%20');
      var web = WebView(
        initialUrl: initialURL,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (controller) {

        },
        onPageFinished: (url) {
          print('url: $url');
          var uri = Uri.parse(url);

          if (uri.queryParameters['error'] != null) {
            Navigator.of(_config.context!).pop();
            throw Exception('Access denied or authentation canceled.');
          }

          if (uri.queryParameters['code'] != null) {
            Navigator.of(_config.context!).pop(true);
            _onCodeListener.add(uri.queryParameters['code']);
          }
        },
        debuggingEnabled: true,
      );

      final result = await Navigator.of(_config.context!).push(MaterialPageRoute(
          builder: (context) => Scaffold(
            body: SafeArea(child: web),
          )));
      if (result != true && onCancel != null) {
        onCancel!();
      }
    } else {
      throw Exception('Context is null. Please call setContext(context).');
    }

    code = await _onCode.first;
    return code;
  }

  Future<void> clearCookies() async {
    await CookieManager().clearCookies();
  }

  Stream<String> get _onCode =>
      _onCodeStream ??= _onCodeListener.stream.asBroadcastStream();

  String _constructUrlParams() =>
      _mapToQueryParams(_authorizationRequest.parameters);

  String _mapToQueryParams(Map<String, String?> params) {
    final queryParams = <String>[];
    params
        .forEach((String key, String? value) => queryParams.add('$key=$value'));
    return queryParams.join('&');
  }
}
