// Copyright (c) 2020, the Krypton project authors.
// For full authorship information, refer to the version control history at
// https://github.com/krypton-org/krypton-flutter or visit the AUTHORS file.
// All rights reserved. Use of this source code is governed by the
// MIT license that can be found in the LICENSE file.

library krypton.src.exceptions;

/// A Krypton exception.
class KryptonException implements Exception { }

/// Email already exists in the database.
class EmailAlreadyExistsException extends KryptonException {}

/// Password does not match.
class WrongPasswordException extends KryptonException {}

/// Account recorery email too old.
class UpdatePasswordTooLateException extends KryptonException {}

/// Email could not be sent.
class EmailNotSentException extends KryptonException {}

/// User not found.
class UserNotFoundException extends KryptonException {}

/// Request not authorized.
class UnauthorizedException extends KryptonException {}

/// User token encryption failed.
class TokenEncryptionException extends KryptonException {}

/// Email already confirmed.
class EmailAlreadyConfirmedException extends KryptonException {}

/// User updates do not pass the fields' validator.
class UserValidationException extends KryptonException {}

/// User already logged in.
class AlreadyLoggedInException extends KryptonException {}

/// Encryption failed.
class EncryptionFailedException extends KryptonException {}