// Copyright (c) 2020, the Krypton project authors.
// For full authorship information, refer to the version control history at
// https://github.com/krypton-org/krypton-flutter
// All rights reserved. Use of this source code is governed by the
// MIT license that can be found in the LICENSE file.

library krypton.test.krypton;

import 'package:krypton/krypton.dart';
import 'package:test/test.dart';

void main() {
  const _kryptonClient = KryptonClient("http://localhost:5000");

  test('register a user with basic email password and without optional fields',
      () async {
    try {
      final isRegistered = await _kryptonClient.register(
          'john.doe@example.com', 'iAmavalidPassw0rd');
      expect(isRegistered, equals(true));
    } on FormatException catch (err) {
      print(err);
    }
  });
}
