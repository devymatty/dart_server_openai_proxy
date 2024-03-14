import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  var server = await HttpServer.bind(InternetAddress.loopbackIPv4, 27728);
  print('Прокси-сервер запущен на http://${server.address.address}:${server.port}');

  await for (HttpRequest request in server) {
    var client = http.Client();
    try {
      // Измените URL на адрес API, к которому вы хотите обратиться
      var uri = Uri.parse('https://api.openai.com' + request.uri.path);
      var response = await client.get(uri);

      request.response
        ..statusCode = response.statusCode
        ..write(response.body)
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write('Ошибка: $e')
        ..close();
    } finally {
      client.close();
    }
  }
}
