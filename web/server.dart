// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library server;

import "dart:io";
import "dart:utf";

const HOST = "0.0.0.0";

const LOG_REQUESTS = true;

const _CLIENT_FILES = "web/client";


void main() {
// Heroku will set the PORT value
  var port = int.parse(Platform.environment['PORT']);

  HttpServer.bind(HOST, port).then((server) {
    server.listen((HttpRequest request) {
      request.response.write('Hello, world');
      request.response.close();
    });
  });
  print("Server running on http://${HOST}:${port}.");
}