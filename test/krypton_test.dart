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
    final email = "register@example.com";
    final password = 'iAmavalidPassw0rd';
    setUp(() {
      kryptonClient = KryptonClient(endpoint: "http://localhost:5000");
    });

    /// This test should not throw any exception
    test(
        'register a user with basic email password and without optional fields',
        () async {
      await kryptonClient.register(email, password);
    });

    tearDown(() async {
      try {
        await kryptonClient.login(email, password);
        await kryptonClient.delete(password);
      } catch (err) {}
    });
  });

  group("get user tests", () {
    KryptonClient kryptonClient;
    final email = "get.user@example.com";
    final password = 'iAmavalidPassw0rd';
    setUp(() {
      kryptonClient = KryptonClient(endpoint: "http://localhost:5000");
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
      try {
        await kryptonClient.login(email, password);
        await kryptonClient.delete(password);
      } catch (err) {}
    });
  });

  group("Login tests", () {
    KryptonClient kryptonClient;
    final email = "login@example.com";
    final password = 'iAmavalidPassw0rd';
    setUp(() {
      kryptonClient = KryptonClient(endpoint: "http://localhost:5000");
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
      try {
        await kryptonClient.login(email, password);
        await kryptonClient.delete(password);
      } catch (err) {}
    });

    group("Log out", () {
      KryptonClient kryptonClient;
      final email = "logout.user@example.com";
      final password = 'iAmavalidPassw0rd';
      setUp(() {
        kryptonClient = KryptonClient(endpoint: "http://localhost:5000");
      });

      /// This test should not throw any exception
      test('Log out', () async {
        await kryptonClient.register(email, password);
        await kryptonClient.login(email, password);
        await kryptonClient.logout();
        try {
          await kryptonClient.refreshToken();
          fail("exception not thrown");
        } catch (e) {
          expect(e, isA<UnauthorizedException>());
        }
      });

      tearDown(() async {
        try {
          await kryptonClient.login(email, password);
          await kryptonClient.delete(password);
        } catch (err) {}
      });
    });
  });

  group("Delete tests", () {
    KryptonClient kryptonClient;
    final email = "john.doe@example.com";
    final password = 'iAmavalidPassw0rd';
    setUp(() {
      kryptonClient = KryptonClient(endpoint: "http://localhost:5000");
    });

    test('delete existing user, should succeed', () async {
      await kryptonClient.register(email, password);
      await kryptonClient.login(email, password);
      await kryptonClient.delete(password);
    });

    tearDown(() async {
      try {
        await kryptonClient.login(email, password);
        await kryptonClient.delete(password);
      } catch (err) {}
    });
  });

  group("Save and re-init Session", () {
    KryptonClient kryptonClient1;
    KryptonClient kryptonClient2;
    String refreshToken;

    final email = "save.init.session@example.com";
    final password = 'iAmavalidPassw0rd';
    setUp(() {
      kryptonClient1 = KryptonClient(
          endpoint: "http://localhost:5000",
          saveRefreshTokenClbk: (token) => refreshToken = token);
      kryptonClient2 = KryptonClient(endpoint: "http://localhost:5000");
    });

    test('Save and re-init Session', () async {
      await kryptonClient1.register(email, password);
      await kryptonClient1.login(email, password);
      expect(await kryptonClient1.isLoggedIn(), true);
      expect(kryptonClient1.user['email'], email);
      expect(refreshToken != null, true);
      await kryptonClient2.setRefreshToken(refreshToken);

      expect(await kryptonClient2.isLoggedIn(), true);
      expect(kryptonClient2.user['email'], email);
    });

    tearDown(() async {
      try {
        await kryptonClient1.login(email, password);
        await kryptonClient1.delete(password);
      } catch (err) {}
    });
  });

  group("Update email", () {
    KryptonClient kryptonClient;
    final email = "update.email@example.com";
    final email2 = "update.email@example.com";
    final password = 'iAmavalidPassw0rd';
    setUp(() {
      kryptonClient = KryptonClient(endpoint: "http://localhost:5000");
    });

    test('Update email', () async {
      await kryptonClient.register(email, password);
      await kryptonClient.login(email, password);
      String previousId = kryptonClient.user['_id'];
      await kryptonClient.update({'email': email2});
      await kryptonClient.logout();
      expect(await kryptonClient.isLoggedIn(), false);
      await kryptonClient.login(email2, password);
      expect(previousId, kryptonClient.user['_id']);
    });

    tearDown(() async {
      try {
        await kryptonClient.login(email2, password);
        await kryptonClient.delete(password);
      } catch (err) {}
      try {
        await kryptonClient.login(email, password);
        await kryptonClient.delete(password);
      } catch (err) {}
    });
  });

  group("Change password", () {
    KryptonClient kryptonClient;
    final email = "change.password@example.com";
    final password = 'iAmavalidPassw0rd';
    final newPassword = 'iAmavalidPassw0rd';

    setUp(() {
      kryptonClient = KryptonClient(endpoint: "http://localhost:5000");
    });

    test('Change password', () async {
      await kryptonClient.register(email, password);
      await kryptonClient.login(email, password);
      expect(await kryptonClient.isLoggedIn(), true);
      await kryptonClient.changePassword(password, newPassword);
      await kryptonClient.logout();
      expect(await kryptonClient.isLoggedIn(), false);
      await kryptonClient.login(email, newPassword);
      expect(await kryptonClient.isLoggedIn(), true);
    });

    tearDown(() async {
      try {
        await kryptonClient.login(email, password);
        await kryptonClient.delete(password);
      } catch (err) {}
      try {
        await kryptonClient.login(email, newPassword);
        await kryptonClient.delete(password);
      } catch (err) {}
    });
  });

  group("Delete account", () {
    KryptonClient kryptonClient;
    final email = "delete.account@example.com";
    final password = 'iAmavalidPassw0rd';

    setUp(() {
      kryptonClient = KryptonClient(endpoint: "http://localhost:5000");
    });

    test('Change password', () async {
      await kryptonClient.register(email, password);
      await kryptonClient.login(email, password);
      expect(await kryptonClient.isLoggedIn(), true);
      await kryptonClient.delete(password);
      expect(await kryptonClient.isLoggedIn(), false);
      try {
        await kryptonClient.login(email, password);
        fail("exception not thrown");
      } catch (e) {
        expect(e, isA<UserNotFoundException>());
      }
    });

    tearDown(() async {
      try {
        await kryptonClient.login(email, password);
        await kryptonClient.delete(password);
      } catch (err) {}
    });
  });
}
