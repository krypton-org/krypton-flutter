// Copyright (c) 2020, the Krypton project authors.
// For full authorship information, refer to the version control history at
// https://github.com/krypton-org/krypton-flutter or visit the AUTHORS file.
// All rights reserved. Use of this source code is governed by the
// MIT license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:krypton/src/exceptions.dart';
import 'dart:convert';
import 'data/pagination.dart';
import 'queries.dart';

const int DEFAULT_MIN_TIME_TO_LIVE = 30 * 1000; // 30 seconds

class KryptonClient {
  _KryptonState _state;
  String endpoint;
  int minTimeToLive;
  Dio _dio;
  CookieJar _cookieJar;

  KryptonClient(this.endpoint,
      {sessionID = null, this.minTimeToLive = DEFAULT_MIN_TIME_TO_LIVE}) {
    _state = new _KryptonState();
    _dio = new Dio();
    _cookieJar = CookieJar();
    _dio.interceptors.add(CookieManager(_cookieJar));
  }

  Future<void> initSessionId(String sessionId) async {
    List<Cookie> cookies = [new Cookie('refreshToken', sessionId)];
    _cookieJar.saveFromResponse(Uri.parse(endpoint), cookies);
    await refreshToken();
  }

  String getSessionId(String refreshToken) {
    List<Cookie> results = _cookieJar.loadForRequest(Uri.parse(endpoint));
    for (Cookie cookie in results) {
      if (cookie.name == 'refreshToken') {
        return cookie.value;
      }
    }
    return '';
  }

  DateTime get expiryDate => _state.expiryDate;

  Map<String, dynamic> get user => _state.user;

  Future<String> getToken() async {
    var limit = DateTime.now().add(new Duration(milliseconds: minTimeToLive));
    if (_state.token != '' && _state.expiryDate.isBefore(limit)) {
      await this.refreshToken();
    }
    return _state.token;
  }

  Future<String> getAuthorizationHeader() async {
    return 'Bearer ' + await this.getToken();
  }

  Future<void> refreshToken() async {
    await this._query(new RefreshQuery(), false);
  }

  Future<bool> isLoggedIn() async {
    var now = DateTime.now();
    if (_state.token != '' && _state.expiryDate.isAfter(now)) {
      return true;
    } else {
      try {
        await this.refreshToken();
      } catch (err) {
        return false;
      }
      return true;
    }
  }

  Future<void> register(String email, String password,
      [Map<String, dynamic> newFields]) async {
    if (newFields == null) newFields = {};
    await this._query(
        new RegisterQuery({
          'fields': {'email': email, 'password': password, ...newFields}
        }),
        false);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    await this
        ._query(new LoginQuery({'email': email, 'password': password}), false);
    return this._state.user;
  }

  Future<void> logout() async {
    await this._query(new LogoutQuery(), true);
    _state = new _KryptonState();
  }

  Future<Map<String, dynamic>> update(Map<String, dynamic> fields) async {
    await this._query(new UpdateQuery({'fields': fields}), true);
    return this._state.user;
  }

  Future<void> delete(String password) async {
    await this._query(new DeleteQuery({'password': password}), true);
    _state = new _KryptonState();
  }

  Future<void> recoverPassword(String email) async {
    await this._query(new SendPasswordRecoveryQuery({'email': email}), true);
  }

  Future<bool> isEmailAvailable(String email) async {
    Map<String, dynamic> data =
        await this._query(new EmailAvailableQuery({'email': email}), false);
    return data['emailAvailable'];
  }

  Future<void> changePassword(String actualPassword, String newPassword) async {
    await this._query(
        new UpdateQuery({
          'fields': {
            'password': newPassword,
            'previousPassword': actualPassword
          }
        }),
        true);
  }

  Future<void> sendVerificationEmail() async {
    await this._query(new SendVerificationEmailQuery(), true);
  }

  Future<Map<String, dynamic>> fetchUserOne(
      Map<String, dynamic> filter, List<String> requestedFields) async {
    Map<String, dynamic> data = await this
        ._query(new UserOneQuery({'filter': filter}, requestedFields), true);
    return data['userOne'];
  }

  Future<List<Map<String, dynamic>>> fetchUserByIds(
      List<String> ids, List<String> requestedFields) async {
    Map<String, dynamic> data = await this
        ._query(new UserByIdsQuery({'ids': ids}, requestedFields), true);
    return data['userByIds'];
  }

  Future<List<Map<String, dynamic>>> fetchUserMany(
      Map<String, dynamic> filter, List<String> requestedFields,
      [int limit]) async {
    Map<String, dynamic> data = await this._query(
        new UserManyQuery({'filter': filter, 'limit': limit}, requestedFields),
        true);
    return data['userMany'];
  }

  Future<int> fetchUserCount([Map<String, dynamic> filter]) async {
    Map<String, dynamic> variables = {};
    if (filter != null) {
      variables['filter'] = filter;
    }
    Map<String, dynamic> data =
        await this._query(new UserCountQuery(variables), true);
    return data['userCount'];
  }

  Future<Pagination> fetchUserWithPagination(Map<String, dynamic> filter,
      List<String> requestedFields, int page, int perPage) async {
    Map<String, dynamic> data = await this._query(
        new UserPaginationQuery(
            {'filter': filter, 'page': page, 'perPage': perPage},
            requestedFields),
        true);
    return Pagination.fromJson(data['userPagination']);
  }

  Future<String> fetchPublicKey() async {
    Map<String, dynamic> data = await this._query(new PublicKeyQuery(), true);
    return data['publicKey'];
  }

  Future<Map<String, dynamic>> _query(
      Query query, bool isAuthTokenRequired) async {
    var headers = {
      Headers.contentTypeHeader: 'application/json',
    };

    if (isAuthTokenRequired) {
      headers['Authorization'] = await this.getAuthorizationHeader();
    }

    Response response = await _dio.post(endpoint,
        data: query.toJson(), options: Options(headers: headers));
    if (response.data['errors'] != null) {
      throw _parseKryptonException(response.data['errors']);
    }
    if (response.data['data'] != null) {
      _updateAuthData(response.data['data']);
    }
    return response.data['data'];
  }

  Exception _parseKryptonException(List<dynamic> errors) {
    String errorType = errors[0]['type'];
    String message = errors[0]['message'];
    switch (errorType) {
      case "AlreadyLoggedInError":
        return new AlreadyLoggedInException(message);
      case "EmailAlreadyConfirmedError":
        return new EmailAlreadyConfirmedException(message);
      case "EmailAlreadyExistsError":
        return new EmailAlreadyExistsException(message);
      case "EmailNotSentError":
        return new EmailNotSentException(message);
      case "UpdatePasswordTooLateError":
        return new UpdatePasswordTooLateException(message);
      case "UnauthorizedError":
        return new UnauthorizedException(message);
      case "UserNotFoundError":
        return new UserNotFoundException(message);
      case "UserValidationError":
        return new UserValidationException(message);
      case "WrongPasswordError":
        return new WrongPasswordException(message);
      default:
        return new KryptonException(message);
    }
  }

  void _updateAuthData(Map<String, dynamic> data) {
    if (data['login'] != null) {
      _setState(data['login']);
    } else if (data['refreshToken'] != null) {
      _setState(data['refreshToken']);
    } else if (data['updateMe'] != null) {
      _setState(data['updateMe']);
    }
  }

  Map<String, dynamic> _decodeToken(String token) {
    final parts = token.split('.');
    final payload = parts[1];
    var normalized = base64Url.normalize(payload);
    var resp = utf8.decode(base64Url.decode(normalized));
    return json.decode(resp);
  }

  void _setState(Map<String, dynamic> dataItemContent) {
    _state = new _KryptonState(
        token: dataItemContent['token'],
        expiryDate: DateTime.parse(dataItemContent['expiryDate']),
        user: _decodeToken(dataItemContent['token']));
  }
}

class _KryptonState {
  String token;
  DateTime expiryDate;
  Map<String, dynamic> user;

  _KryptonState({this.token = '', expiryDate, user})
      : expiryDate = expiryDate ?? new DateTime.fromMicrosecondsSinceEpoch(0),
        user = user ?? new Map();
}
