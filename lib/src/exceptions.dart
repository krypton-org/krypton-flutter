// Copyright (c) 2020, the Krypton project authors.
// For full authorship information, refer to the version control history at
// https://github.com/krypton-org/krypton-flutter or visit the AUTHORS file.
// All rights reserved. Use of this source code is governed by the
// MIT license that can be found in the LICENSE file.

library krypton.src.exceptions;

/// A Krypton exception.
class KryptonException implements Exception {
  String message;
  KryptonException(this.message);

  @override
  String toString() => message;
}

/// Email already exists in the database.
class EmailAlreadyExistsException extends KryptonException {
  EmailAlreadyExistsException(String message) : super(message);
}

/// Password does not match.
class WrongPasswordException extends KryptonException {
  WrongPasswordException(String message) : super(message);
}

/// Account recorery email too old.
class UpdatePasswordTooLateException extends KryptonException {
  UpdatePasswordTooLateException(String message) : super(message);
}

/// Email could not be sent.
class EmailNotSentException extends KryptonException {
  EmailNotSentException(String message) : super(message);
}

/// User not found.
class UserNotFoundException extends KryptonException {
  UserNotFoundException(String message) : super(message);
}

/// Request not authorized.
class UnauthorizedException extends KryptonException {
  UnauthorizedException(String message) : super(message);
}

/// User token encryption failed.
class TokenEncryptionException extends KryptonException {
  TokenEncryptionException(String message) : super(message);
}

/// Email already confirmed.
class EmailAlreadyConfirmedException extends KryptonException {
  EmailAlreadyConfirmedException(String message) : super(message);
}

/// User updates do not pass the fields' validator.
class UserValidationException extends KryptonException {
  UserValidationException(String message) : super(message);
}

/// User already logged in.
class AlreadyLoggedInException extends KryptonException {
  AlreadyLoggedInException(String message) : super(message);
}

/// Encryption failed.
class EncryptionFailedException extends KryptonException {
  EncryptionFailedException(String message) : super(message);
}
