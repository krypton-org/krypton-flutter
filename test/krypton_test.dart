// Copyright (c) 2020, the Krypton project authors.
// For full authorship information, refer to the version control history at
// https://github.com/krypton-org/krypton-flutter or visit the AUTHORS file.
// All rights reserved. Use of this source code is governed by the
// MIT license that can be found in the LICENSE file.

library krypton.test.krypton;

import 'package:krypton/krypton.dart';
import 'package:test/test.dart';

void main() {
  final _kryptonClient = KryptonClient("http://localhost:5000");

  /// This test should not throw any exception
  test('register a user with basic email password and without optional fields',
      () async {
      await _kryptonClient.register(
          'john.doe@example.com', 'iAmavalidPassw0rd');
  });
}
