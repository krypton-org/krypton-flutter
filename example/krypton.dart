// Copyright (c) 2020, the Krypton project authors.
// For full authorship information, refer to the version control history at
// https://github.com/krypton-org/krypton-flutter or visit the AUTHORS file.
// All rights reserved. Use of this source code is governed by the
// MIT license that can be found in the LICENSE file.

library krypton.example.krypton;

import 'package:krypton/krypton.dart';
// import 'package:dart_style/src/debug.dart' as debug;

void main(List<String> args) async {
  KryptonClient kryptonClient = KryptonClient(
      "https://localhost:5000"); // assuming Krypton Auth's Mongo DB instance is running on this URL
  try {
    await kryptonClient.register("nicolas@example.com", "1234unsecurepassword");
    await kryptonClient.login("nicolas@example.com", "1234unsecurepassword");
  } catch (err) {
    print(err);
  }
}
