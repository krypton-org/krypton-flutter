// Copyright (c) 2020, the Krypton project authors.
// For full authorship information, refer to the version control history at
// https://github.com/krypton-org/krypton-flutter or visit the AUTHORS file.
// All rights reserved. Use of this source code is governed by the
// MIT license that can be found in the LICENSE file.

enum QueryEnum {
  register,
}

// Require dart >= 2.6.0
extension QueryExtension on QueryEnum {

  String get value {
    switch (this) {
      case QueryEnum.register:
      return _register;
      default:
      return null;
    }
  }
}

const String _register = r'''
  mutation register($fields: UserRegisterInput!) {
    register(fields: $fields)
  }
''';
