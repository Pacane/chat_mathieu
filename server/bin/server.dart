// Copyright (c) 2017, Joel Trottier-Hebert. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io' as io;

import 'package:args/args.dart';
import 'dart:async';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_cors/shelf_cors.dart' as shelf_cors;
import 'package:shelf/shelf_io.dart' as shelf_io;

int number = 0;
Future<Null> main(List<String> args) async {
  var parser = new ArgParser()
    ..addOption('port', abbr: 'p', defaultsTo: '8090');

  var result = parser.parse(args);

  var port = int.parse(result['port'], onError: (val) {
    io.stdout.writeln('Could not parse port value "$val" into a number.');
    io.exit(1);
  });

  var handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addMiddleware(shelf_cors.createCorsHeadersMiddleware())
      .addHandler(askNumber);

  shelf_io.serve(handler, '0.0.0.0', port).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });

  Future handleMessage(io.WebSocket socket, dynamic message) async {
    print(message);
    socket.add('Received!');
    socket.close();
  }

  Future startSocket() async {
    try {
      io.HttpServer server = await io.HttpServer.bind('localhost', 8092);
      server.listen((io.HttpRequest req) async {
        if (req.uri.path == '/ws') {
          io.WebSocket socket = await io.WebSocketTransformer.upgrade(req);
          socket.listen((msg) => handleMessage(socket, msg));
        }
      });
    } catch (e) {
      print("An error occurred. ${e.toString()}");
    }
  }

  startSocket();
}

shelf.Response askNumber(shelf.Request request) {
  if (request.requestedUri.path == '/number') {
    number++;
    return new shelf.Response.ok(number.toString());
  }

  return new shelf.Response.forbidden('Cannot access this path');
}
