// Copyright (c) 2020, the Krypton project authors.
// For full authorship information, refer to the version control history at
// https://github.com/krypton-org/krypton-flutter or visit the AUTHORS file.
// All rights reserved. Use of this source code is governed by the
// MIT license that can be found in the LICENSE file.

library krypton.test.krypton;

import 'package:krypton/krypton.dart';
import 'package:test/test.dart';

void main() {
  group("Register tests", () {
    KryptonClient kryptonClient;
    final email = "john.doe@example.com";
    final password = 'iAmavalidPassw0rd';
    setUp(() {
      kryptonClient = KryptonClient("http://localhost:5000");
    });

    /// This test should not throw any exception
    test(
        'register a user with basic email password and without optional fields',
        () async {
      await kryptonClient.register(email, password);
    });

    tearDown(() async {
      await kryptonClient.login(email, password);
      await kryptonClient.delete(password);
    });
  });

  group("get user tests", () {
    KryptonClient kryptonClient;
    final email = "john.doe@example.com";
    final password = 'iAmavalidPassw0rd';
    setUp(() {
      kryptonClient = KryptonClient("http://localhost:5000");
    });

    /// This test should not throw any exception
    test(
        'register a user with basic email password and without optional fields and get user',
        () async {
      var isLoggedIn = await kryptonClient.isLoggedIn();
      expect(isLoggedIn, false);
      await kryptonClient.register(email, password);
      await kryptonClient.login(email, password);
      expect(kryptonClient.user, isNot(null));
      expect(kryptonClient.user['email'], email);
      isLoggedIn = await kryptonClient.isLoggedIn();
      expect(isLoggedIn, true);
      expect(kryptonClient.expiryDate.isAfter(new DateTime.now()), true);
    });

    tearDown(() async {
      await kryptonClient.login(email, password);
      await kryptonClient.delete(password);
    });
  });

  group("Login tests", () {
    KryptonClient kryptonClient;
    final email = "john.doe@example.com";
    final password = 'iAmavalidPassw0rd';
    setUp(() {
      kryptonClient = KryptonClient("http://localhost:5000");
    });

    test(
        'login without register first, should fail with Exception UserNotFound',
        () async {
      try {
        await kryptonClient.login(email, password);
        fail("exception not thrown");
      } catch (e) {
        expect(e, isA<UserNotFoundException>());
      }

    });
    test('login after register should succeed', () async {
      await kryptonClient.register(email, password);
      await kryptonClient.login(email, password);
    });
    tearDown(() async {
      await kryptonClient.login(email, password);
      await kryptonClient.delete(password);
    });
  });

  group("Delete tests", () {
    KryptonClient kryptonClient;
    final email = "john.doe@example.com";
    final password = 'iAmavalidPassw0rd';
    setUp(() {
      kryptonClient = KryptonClient("http://localhost:5000");
    });

    test('delete existing user, should succeed', () async {
      await kryptonClient.register(email, password);
      await kryptonClient.login(email, password);
      await kryptonClient.delete(password);
    });

    tearDown(() async {
      await kryptonClient.login(email, password);
      await kryptonClient.delete(password);
    });
  });
}
