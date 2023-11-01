import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'request/authorization_request.dart';
import 'model/config.dart';

class RequestCode {
  final Config _config;
  final AuthorizationRequest _authorizationRequest;
  void Function()? onCancel;
  void Function()? onDismiss;

  RequestCode(Config config, this.onCancel, this.onDismiss) : _config = config, _authorizationRequest = AuthorizationRequest(config);

  void setContext(BuildContext context) {
    _config.context = context;
  }

  Future<String> requestCode() async {
    final urlParams = _constructUrlParams();

    if (_config.context != null) {
      final completer = Completer<String>();
      var initialURL =
        ('${_authorizationRequest.url}?$urlParams').replaceAll(' ', '%20');
      var web = WebView(
        initialUrl: initialURL,
        javascriptMode: JavascriptMode.unrestricted,
        onPageFinished: (url) {
          print('url: $url');
          var uri = Uri.parse(url);

          if (uri.queryParameters['error'] != null) {
            Navigator.of(_config.context!).pop();
            if (!completer.isCompleted) {
              completer.completeError(Exception('Access denied or authentation canceled.'));
            }
            return;
          }

          if (uri.queryParameters['code'] != null) {
            Navigator.of(_config.context!).pop(true);
            if (onDismiss != null) {
              onDismiss!();
            }
            if (!completer.isCompleted) {
              completer.complete(uri.queryParameters['code']);
            }
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
      return completer.future;
    } else {
      throw Exception('Context is null. Please call setContext(context).');
    }
  }

  Future<String> requestCodeUrl() async {
    final urlParams = _constructUrlParams();

    if (_config.context != null) {
      final completer = Completer<String>();
      var initialURL =
          "${('${_authorizationRequest.url}?$urlParams').replaceAll(' ', '%20')}"
          "&nonce=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";
      var web = WebView(
        initialUrl: initialURL,
        javascriptMode: JavascriptMode.unrestricted,
        onPageFinished: (url) {
          print('url: $url');
          var uri = Uri.parse(url);

          if (uri.queryParameters['error'] != null) {
            Navigator.of(_config.context!).pop();
            if (!completer.isCompleted) {
              completer.completeError(Exception('Access denied or authentation canceled.'));
            }
            return;
          }

          if (uri.queryParameters['code'] != null) {
            Navigator.of(_config.context!).pop(true);
            if (onDismiss != null) {
              onDismiss!();
            }
            if (!completer.isCompleted) {
              completer.complete(uri.toString());
            }
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
      return completer.future;
    } else {
      throw Exception('Context is null. Please call setContext(context).');
    }
  }

  Future<void> clearCookies() async {
    await CookieManager().clearCookies();
  }

  String _constructUrlParams() =>
      _mapToQueryParams(_authorizationRequest.parameters);

  String _mapToQueryParams(Map<String, String?> params) {
    final queryParams = <String>[];
    params
        .forEach((String key, String? value) => queryParams.add('$key=$value'));
    return queryParams.join('&');
  }
}
