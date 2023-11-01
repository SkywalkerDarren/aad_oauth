import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RequestCodeWorkOs {
  final BuildContext _context;
  void Function()? onCancel;
  void Function()? onDismiss;

  RequestCodeWorkOs({
    required BuildContext context,
    this.onCancel,
    this.onDismiss
  }) : _context = context;

  Future<String> requestCode(String authUrl) async {
    final completer = Completer<String>();
    var initialURL = authUrl.replaceAll(' ', '%20');
    var web = WebView(
      initialUrl: initialURL,
      javascriptMode: JavascriptMode.unrestricted,
      onPageFinished: (url) {
        print('url: $url');
        var uri = Uri.parse(url);

        if (uri.queryParameters['error'] != null) {
          Navigator.of(_context).pop();
          if (!completer.isCompleted) {
            completer.completeError(
                Exception('Access denied or authentation canceled.'));
          }
          return;
        }

        if (uri.queryParameters['code'] != null) {
          Navigator.of(_context).pop(true);
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

    final result = await Navigator.of(_context).push(MaterialPageRoute(
        builder: (context) =>
            Scaffold(
              body: SafeArea(child: web),
            )));
    if (result != true && onCancel != null) {
      onCancel!();
    }
    return completer.future;
  }

  Future<String> requestCodeUrl(String authUrl) async {
    final completer = Completer<String>();
    var initialURL = authUrl.replaceAll(' ', '%20');
    var web = WebView(
      initialUrl: initialURL,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (controller) {},
      onWebResourceError: (WebResourceError error) {
        print('WebResourceError: $error');
        throw Exception('WebResourceError: $error');
      },
      onPageFinished: (url) {
        print('url: $url');
        var uri = Uri.parse(url);

        if (uri.queryParameters['error'] != null) {
          Navigator.of(_context).pop();
          throw Exception('Access denied or authentation canceled.');
        }

        if (uri.queryParameters['code'] != null) {
          Navigator.of(_context).pop(true);
          if (onDismiss != null) {
            onDismiss!();
          }
          completer.complete(uri.toString());
        }
      },
      debuggingEnabled: true,
    );

    final result = await Navigator.of(_context).push(MaterialPageRoute(
        builder: (context) => Scaffold(
          body: SafeArea(child: web),
        )));
    if (result != true && onCancel != null) {
      onCancel!();
    }
    return completer.future;
  }

  Future<void> clearCookies() async {
    await CookieManager().clearCookies();
  }
}
