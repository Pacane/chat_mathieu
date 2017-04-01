// Copyright (c) 2017, Joel Trottier-Hebert. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:async';
import 'package:http/browser_client.dart' as http;

Future<Null> main() async {
  var outputDiv = querySelector('#output');
  var button = querySelector('#send');

  outputDiv.text = 'Your Dart app is running.';
  button.onClick.listen((MouseEvent event) async {
    var client = new http.BrowserClient();

    var response = await client.get('http://localhost:8090/number');
    outputDiv.text = response.body;
  });
}
