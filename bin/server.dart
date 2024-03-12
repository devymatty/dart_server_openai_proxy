import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  // Создание HTTP сервера, который слушает localhost на порту 8080
  var server = await HttpServer.bind('localhost', 8080);
  print('Сервер запущен на http://${server.address.host}:${server.port}');

  // Обработка всех входящих запросов
  await for (var request in server) {
    // URL-адрес, на который будут перенаправляться запросы
    var targetUrl = Uri.parse('https://api.openai.com');

    // Создание нового URI с заменой схемы, хоста и порта на целевые,
    // но сохранением пути и параметров запроса
    var forwardedUri = targetUrl.replace(
      path: request.uri.path,
      queryParameters: request.uri.queryParameters,
    );

    try {
      // Перенаправление запроса на целевой URL
      var response = await http.get(forwardedUri);

      // Пересылка ответа от целевого сервера клиенту
      request.response
        ..statusCode = response.statusCode
        ..headers.contentType = ContentType.parse(response.headers['content-type']!)
        ..write(response.body)
        ..close();
    } catch (e) {
      // Обработка ошибок, например, если целевой сервер недоступен
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write('Произошла ошибка: $e')
        ..close();
    }
  }
}
