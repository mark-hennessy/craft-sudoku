/*
  Dart code sample: Simple file server
  1. Download, uncompress and rename the folder to 'FileDownloadServer'.
  2. Put files you want to send into the folder.
  3. From Dart Editor, File > Open Folder and select this FileDownloadServer folder.
  4. Run the FileServer.dart as server.
  5. Access the server from Chrome: http://localhost:8080/fserver
     or directly: http://localhost:8080/fserver/readme.txt
    Ref.
      https://gist.github.com/2564561
      https://gist.github.com/2564562
      http://www.cresc.co.jp/tech/java/Google_Dart/DartLanguageGuide.pdf (in Japanese)
    Modified May 2012, by Terry Mitsuoka.
    Revised July 2012 to include MIME library.
    Revised Sept. 2012 to incorporate catch syntax change.
    Revised Oct. 2012 to incorporate M1 changes.
    Revised Feb. 2013 to incorporate newly added dart:async library.
    Revised Feb. 2013 to incorporate M3 changes.
    March 2013, API changes (String and HttpResponse) fixed
*/

import 'dart:io';
import 'MIME.dart' as mime;
import "dart:utf" as utf;
import 'dart:async';

// HOST must be 0.0.0.0 for Heroku
const HOST = '0.0.0.0';
int port;
const _PORT_KEY = "PORT";
const LOG_REQUESTS = true;
const String INDEX_PAGE = "/sudoku_game.html";

String _basePath;
String get _clientPath => "$_basePath/../client";

void main() {
  computeBasePath().then((unused) {
    initPort();
    startServer();
  });
}

/**
 * Compute base path for the request based on the location of the
 * script and then start the server.
 */
Future computeBasePath() {
  File script = new File(new Options().script);
  return script.directory().then((Directory dir) {
    _basePath = dir.path;
  });
}

void initPort() {
// Heroku will set the PORT value
  if(Platform.environment.containsKey(_PORT_KEY)) {
    port = int.parse(Platform.environment[_PORT_KEY]);
  } else {
    port = 8080;
  }
}

void startServer() {
  HttpServer.bind(HOST, port)
  .then((HttpServer server) {
    server.listen((HttpRequest request) {
      HttpResponse response = request.response;
      var requestPath = request.uri.path;
      print(requestPath);
      requestReceivedHandler(request, response);
    });
    print("Serving on http://${HOST}:${port}.");
  });
}

void requestReceivedHandler(HttpRequest request, HttpResponse response) {
  String bodyString = "";      // request body byte data
  var completer = new Completer();
  if (request.method == "GET") { completer.complete("query string data received");
  } else if (request.method == "POST") {
    request
      .transform(new StringDecoder())
      .listen(
          (String str){bodyString = bodyString + str;},
          onDone: (){
            completer.complete("body data received");},
          onError: (e){
            print('exeption occured : ${e.toString()}');}
        );
  }
  else {
    response.statusCode = HttpStatus.METHOD_NOT_ALLOWED;
    response.close();
    return;
  }
  // process the request
  completer.future.then((data){
    if (LOG_REQUESTS) {
      print(createLogMessage(request, bodyString));
    }
    if (request.queryParameters['fileName'] != null) {
      new FileHandler().onRequest(request, response);
    } else {
      String fileName = request.uri.path;
      if (fileName.length > 2) {
        new FileHandler().onRequest(request, response, fileName);
      } else {
        new FileHandler().onRequest(request, response, INDEX_PAGE);
      }
    }
  });
}


class FileHandler {

  void onRequest(HttpRequest request, HttpResponse response, [String fileName = null]) {
    try {
      if (fileName == null) {
        fileName = request.queryParameters['fileName'];
      }
      if (LOG_REQUESTS) {
        print('Requested file name : $fileName');
      }
      if(!fileName.startsWith("/")) {
        fileName = "/$fileName";
      }
      File file = new File(_clientPath + fileName);
      if (file.existsSync()) {
        String mimeType = 'text/html; charset=UTF-8';
        int lastDot = fileName.lastIndexOf('.', fileName.length - 1);
        if (lastDot != -1) {
          String extension = fileName.substring(lastDot + 1);
          mimeType = mime.mimeType(extension);
        }
        response.headers.set('Content-Type', mimeType);
//      response.headers.set('Content-Disposition', 'attachment; filename=\'${fileName}\'');
        // Get the length of the file for setting the Content-Length header.
        RandomAccessFile openedFile = file.openSync();
        response.contentLength = openedFile.lengthSync();
        openedFile.closeSync();
        // Pipe the file content into the response.
        file.openRead().pipe(response);
      } else {
        if (LOG_REQUESTS) {
          print('File not found: $fileName');
        }
        new NotFoundHandler().onRequest(request, response);
      }
    } on Exception catch (err) {
      print('File Handler error : $err.toString()');
    }
  }
}


class NotFoundHandler {

  static final String notFoundPageHtml = '''
<html><head>
<title>404 Not Found</title>
</head><body>
<h1>Not Found</h1>
<p>The requested URL or File was not found on this server.</p>
</body></html>''';

  void onRequest(HttpRequest request, HttpResponse response){
    response
      ..statusCode = HttpStatus.NOT_FOUND
      ..headers.set('Content-Type', 'text/html; charset=UTF-8')
      ..write(notFoundPageHtml)
      ..close();
  }
}


// create log message
StringBuffer createLogMessage(HttpRequest request, [String bodyString]) {
  var sb = new StringBuffer( '''basePath : ${_basePath}
request.headers.host : ${request.headers.host}
request.headers.port : ${request.headers.port}
request.connectionInfo.localPort : ${request.connectionInfo.localPort}
request.connectionInfo.remoteHost : ${request.connectionInfo.remoteHost}
request.connectionInfo.remotePort : ${request.connectionInfo.remotePort}
request.method : ${request.method}
request.persistentConnection : ${request.persistentConnection}
request.protocolVersion : ${request.protocolVersion}
request.contentLength : ${request.contentLength}
request.uri : ${request.uri}
request.uri.path : ${request.uri.path}
request.uri.query : ${request.uri.query}
request.uri.queryParameters :
''');
  request.queryParameters.forEach((key, value){
    sb.write("  ${key} : ${value}\n");
  });
  sb.write('''request.cookies :
''');
  request.cookies.forEach((value){
    sb.write("  ${value.toString()}\n");
  });
  sb.write('''request.headers.expires : ${request.headers.expires}
request.headers :
  ''');
  var str = request.headers.toString();
  for (int i = 0; i < str.length - 1; i++){
    if (str[i] == "\n") { sb.write("\n  ");
    } else { sb.write(str[i]);
    }
  }
  sb.write('''\nrequest.session.id : ${request.session.id}
requset.session.isNew : ${request.session.isNew}
''');
  if (request.method == "POST") {
    var enctype = request.headers["content-type"];
    if (enctype[0].contains("text")) {
      sb.write("request body string : ${bodyString.replaceAll('+', ' ')}");
    } else if (enctype[0].contains("urlencoded")) {
      sb.write("request body string (URL decoded): ${urlDecode(bodyString)}");
    }
  }
  sb.write("\n");
  return sb;
}


// make safe string buffer data as HTML text
StringBuffer makeSafe(StringBuffer b) {
  var s = b.toString();
  b = new StringBuffer();
  for (int i = 0; i < s.length; i++){
    if (s[i] == '&') { b.write('&amp;');
    } else if (s[i] == '"') { b.write('&quot;');
    } else if (s[i] == "'") { b.write('&#39;');
    } else if (s[i] == '<') { b.write('&lt;');
    } else if (s[i] == '>') { b.write('&gt;');
    } else { b.write(s[i]);
    }
  }
  return b;
}


// URL decoder decodes url encoded utf-8 bytes
// Use this method to decode query string
// We need this kind of encoder and decoder with optional [encType] argument
String urlDecode(String s){
  int i, p, q;
   var ol = new List<int>();
   for (i = 0; i < s.length; i++) {
     if (s[i].codeUnitAt(0) == 0x2b) { ol.add(0x20); // convert + to space
     } else if (s[i].codeUnitAt(0) == 0x25) {        // convert hex bytes to a single bite
       i++;
       p = s[i].toUpperCase().codeUnitAt(0) - 0x30;
       if (p > 9) p = p - 7;
       i++;
       q = s[i].toUpperCase().codeUnitAt(0) - 0x30;
       if (q > 9) q = q - 7;
       ol.add(p * 16 + q);
     }
     else { ol.add(s[i].codeUnitAt(0));
     }
   }
  return utf.decodeUtf8(ol);
}