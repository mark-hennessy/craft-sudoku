library server;

import "dart:io";
import "dart:utf";

const HOST = "0.0.0.0";
const _CLIENT_FILES = "web/client";


void main() {
// Heroku will set the PORT value
  var port = int.parse(Platform.environment['PORT']);

  HttpServer.bind(HOST, port).then((server) {
    server.listen((HttpRequest request) {
      onRequest(request, request.response);
    });
  });
  print("Server running on http://${HOST}:${port}.");
}

void onRequest(HttpRequest request, HttpResponse response) {
  File file = new File(_CLIENT_FILES + "/sudoku_game.html");

  // Set mime type
  String mimeType = 'text/html; charset=UTF-8';
  response.headers.set('Content-Type', mimeType);

  // Set content length
  RandomAccessFile openedFile = file.openSync();
  response.contentLength = openedFile.lengthSync();
  openedFile.closeSync();

  // Pipe the file content into the response.
  file.openRead().pipe(response);
}