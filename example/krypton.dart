// Copyright (c) 2020, the Krypton project authors.
// For full authorship information, refer to the version control history at
// https://github.com/krypton-org/krypton-flutter or visit the AUTHORS file.
// All rights reserved. Use of this source code is governed by the
// MIT license that can be found in the LICENSE file.

library krypton.example.krypton;

import 'package:krypton/krypton.dart';
// import 'package:dart_style/src/debug.dart' as debug;

void main(List<String> args) {
  // Enable debugging so you can see some of the formatter's internal state.
  // Normal users do not do this.
  // debug.traceChunkBuilder = true;
  // debug.traceLineWriter = true;
  // debug.traceSplitter = true;
  // debug.useAnsiColors = true;

  KryptonClient kryptonClient =
      KryptonClient("https://localhost:5000");
  kryptonClient.register("nicolas@example.com", "1234unsecurepassword");
}
