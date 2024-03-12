import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

Future<void> main() async {
  var server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  print('Прокси сервер запущен на порту ${server.port}...');

  await for (HttpRequest request in server) {
    Uri targetUri = Uri.parse('https://api.openai.com'); // Укажите целевой URL

    http.Request proxyRequest = http.Request(request.method, targetUri)
      ..headers.addAll(request.headers as Map<String, String>)
      ..body = await utf8.decoder.bind(request).join();

    // Игнорирование Content-Length может привести к ошибкам, если тело изменено
    proxyRequest.headers.remove('content-length');

    http.StreamedResponse response = await http.Client().send(proxyRequest);

    request.response
      ..statusCode = response.statusCode
      ..headers.contentType = ContentType.parse(response.headers['content-type']!);

    await response.stream.pipe(request.response);
  }
}
