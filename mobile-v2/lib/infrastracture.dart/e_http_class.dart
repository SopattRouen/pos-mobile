import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/entity/enum/e_user_preference.dart';
import 'package:mobile/entity/enum/e_variable.dart';
import 'package:mobile/entity/helper/http_field.dart';
import 'package:mobile/entity/helper/http_key.dart';
import 'package:mobile/entity/helper/http_method.dart';

class EHTTP {
  /// Header
  static Map<String, String> _getHeaderMap({String authorization = ""}) {
    Map<String, String> header = {
      "Accept": "application/json",
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": 'Bearer $authorization',
    };
    return header;
  }

  /////////////////////
  ///Check for Internet Connection
  static Future<Map<EHTTPField, dynamic>> isOnline() async {
    ///internet checking
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return {EHTTPField.key: EHTTPKey.responseOK};
      } else {
        return {EHTTPField.key: EHTTPKey.errNoInternet};
      }
    } catch (e) {
      return {EHTTPField.key: EHTTPKey.errNoInternet};
    }
  }

  static Future<Map<EHTTPField, dynamic>> httpRequest({
    required String uri,
    required Map<String, dynamic> bodyMap,
    BuildContext? context,
    EHTTPMethod method = EHTTPMethod.get,
    bool isHead = false,
  }) async {
    var response = await isOnline();
    if (response[EHTTPField.key] != EHTTPKey.responseOK) {
      isOffline = true;
      UI.toast(
          text:
              'មិនអាចភ្ជាប់បានទេ សូមឆែកការភ្ជាប់អិនធឺណែត\n(No Internet Connection)',
          isSuccess: false);

      return {
        EHTTPField.code: 404,
        EHTTPField.key: EHTTPKey.errNoInternet,
        EHTTPField.body: EHTTPKey.errNoInternet.toString().split('.')[1],
        EHTTPField.error: EHTTPKey.errNoInternet.toString().split('.')[1]
      };
    }

    isOffline = false;

    /// REQUEST TRANSACTION TO SERVER
    // ignore: prefer_typing_uninitialized_variables
    var httpResponse;
    String queryString = '';
    try {
      switch (method) {
        case EHTTPMethod.get:
          List<String> arrQueryString = <String>[];
          bodyMap.forEach((k, v) {
            arrQueryString.add('$k=$v');
          });
          queryString = arrQueryString.join('&');
          httpResponse = await http
              .get(
                  Uri.parse(mainUrlApi +
                      uri +
                      (queryString == '' ? '' : '?$queryString')),
                  headers: isHead
                      ? _getHeaderMap(authorization: userPrefs.token!)
                      : _getHeaderMap())
              .timeout(const Duration(seconds: 120));
          break;

        case EHTTPMethod.delete:
          httpResponse = await http
              .delete(Uri.parse(mainUrlApi + uri),
                  body: bodyMap,
                  headers: _getHeaderMap(authorization: userPrefs.token!))
              .timeout(const Duration(seconds: 120));
          break;

        case EHTTPMethod.put:
          queryString = '?_method=PUT';
          continue post;
        post:
        case EHTTPMethod.post:
        default:
          httpResponse = await http
              .post(Uri.parse(mainUrlApi + uri),
                  body: bodyMap,
                  headers: isHead
                      ? _getHeaderMap(authorization: userPrefs.token!)
                      : _getHeaderMap())
              .timeout(const Duration(seconds: 120));
          break;
      }

      // print(queryString);

      if (httpResponse == null) {
        return {
          EHTTPField.code: 408,
          EHTTPField.key: EHTTPKey.errNoResponse,
          EHTTPField.body: EHTTPKey.errNoResponse,
          EHTTPField.error: EHTTPKey.errNoResponse
        };
      } else if (httpResponse.body.toString().contains('EXIPIRED_TOKEN')) {
        print('object');
        userPrefs.token = '';
        await UserPreferences.saveUserFromToken(userPrefs.token!);
        // onExpire();
        var decodedError = json.decode(httpResponse.body);
        return {
          EHTTPField.code: httpResponse.statusCode,
          EHTTPField.key: EHTTPKey.errUnauthenticated,
          EHTTPField.body: decodedError ??
              httpResponse.body.toString(), // Can be many error case possible
          EHTTPField.error: _getErrorMessageOutline(
            decodedError ?? httpResponse.body.toString(),
            httpResponse.statusCode,
          )
        };
      } else if (httpResponse.statusCode == 500) {
        UserPreferences.saveUserFromToken(userPrefs.token!);

        var decodedError = json.decode(httpResponse.body);
        // if (decodedError == null) decodedError = '';
        return {
          EHTTPField.code: httpResponse.statusCode,
          EHTTPField.key: EHTTPKey.errResponse,
          EHTTPField.body: decodedError ??
              httpResponse.body['data']
                  .toString(), // Can be many error case possible
          EHTTPField.error: _getErrorMessageOutline(
            decodedError ?? httpResponse.body.toString(),
            httpResponse.statusCode,
          )
        };
      }
      ////////////////////
      ///Other error
      else if (httpResponse.statusCode != 200) {
        var decodedError = json.decode(httpResponse.body);
        return {
          EHTTPField.code: httpResponse.statusCode,
          EHTTPField.key: EHTTPKey.errResponse,
          EHTTPField.body: decodedError ??
              httpResponse.body['data']
                  .toString(), // Can be many error case possible
          EHTTPField.error: _getErrorMessageOutline(
            decodedError ?? httpResponse.body.toString(),
            httpResponse.statusCode,
          )
        };
      }
      ////////////////////
      ///Unauthenticated > redirect to login page
      else if (httpResponse.statusCode == 401) {
        var decodedError = json.decode(httpResponse.body);
        return {
          EHTTPField.code: httpResponse.statusCode,
          EHTTPField.key: EHTTPKey.errUnauthenticated,
          EHTTPField.body: decodedError ??
              httpResponse.body.toString(), // Can be many error case possible
          EHTTPField.error: _getErrorMessageOutline(
            decodedError ?? httpResponse.body.toString(),
            httpResponse.statusCode,
          )
        };
      }
      // SUCCESSFUL
      else {
        return {
          EHTTPField.code: httpResponse.statusCode,
          EHTTPField.key: EHTTPKey.responseOK,
          EHTTPField.body: json.decode(httpResponse.body),
          EHTTPField.error: _getErrorMessageOutline(
            json.decode(httpResponse.body),
            httpResponse.statusCode,
          )
        };
      }
    }

    /// UNEXPECTED ERROR
    catch (error) {
      bool loseConnection =
          error.toString() == "Software caused connection abort";
      if (loseConnection) {
        isOffline = true;
        UI.toast(
          text:
              'មិនអាចភ្ជាប់បានទេ សូមឆែកការភ្ជាប់អិនធឺណែត\n(No Internet Connection)',
          isSuccess: false,
        );

        return {
          EHTTPField.code: 404,
          EHTTPField.key: EHTTPKey.errNoInternet,
          EHTTPField.body: EHTTPKey.errNoInternet.toString().split('.')[1],
          EHTTPField.error: EHTTPKey.errNoInternet.toString().split('.')[1]
        };
      }
      return {
        EHTTPField.code: 400,
        EHTTPField.key: EHTTPKey.errUnexpect,
        EHTTPField.body: error.toString(),
        EHTTPField.error: error.toString()
      }; // Can be many case possible
    }
  }

  /////////////////
  /// Turn error JSON to string as part of RCHTTPField.error
  static String _getErrorMessageOutline(var error, var responseCode) {
    String msg = '';
    if (error is Map) {
      error.forEach((k, v) {
        if (v is! List) {
          msg += v.toString();
        } else {
          // array
          for (var i = 0; i < v.length; i++) {
            msg += v[i].toString();
          }
        }
      });
    } else {
      msg = 'Error [${responseCode.toString()}] : $error';
    }
    return msg;
  }
}
// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:mobile/entity/enum/e_user_preference.dart';
// import 'package:mobile/entity/enum/e_variable.dart';
// import 'package:mobile/entity/helper/http_field.dart';
// import 'package:mobile/entity/helper/http_key.dart';
// import 'package:mobile/entity/helper/http_method.dart';
// import 'package:mobile/entity/enum/e_ui.dart';


// class EHTTP {
//   /// Header
//   static Future<Map<String, String>> _getHeaderMap({bool isHead = false}) async {
//     String token = await UserPreferences.getUserToken(); // Fetch the token securely
//     return {
//       "Accept": "application/json",
//       "Content-Type": "application/x-www-form-urlencoded",
//       "Authorization": token.isNotEmpty ? 'Bearer $token' : '',
//     };
//   }

//   static Future<Map<EHTTPField, dynamic>> isOnline() async {
//     try {
//       final result = await InternetAddress.lookup('google.com');
//       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//         return {EHTTPField.key: EHTTPKey.responseOK};
//       } else {
//         return {EHTTPField.key: EHTTPKey.errNoInternet};
//       }
//     } catch (e) {
//       return {EHTTPField.key: EHTTPKey.errNoInternet};
//     }
//   }

//   static Future<Map<EHTTPField, dynamic>> httpRequest({
//     required String uri,
//     required Map<String, dynamic> bodyMap,
//     BuildContext? context,
//     EHTTPMethod method = EHTTPMethod.get,
//     bool isHead = false,
//   }) async {
//     var response = await isOnline();
//     if (response[EHTTPField.key] != EHTTPKey.responseOK) {
//       isOffline = true;
//       UI.toast(
//           text: 'មិនអាចភ្ជាប់បានទេ សូមឆែកការភ្ជាប់អិនធឺណែត\n(No Internet Connection)',
//           isSuccess: false);
//       return {
//         EHTTPField.code: 404,
//         EHTTPField.key: EHTTPKey.errNoInternet,
//         EHTTPField.body: EHTTPKey.errNoInternet.toString().split('.')[1],
//         EHTTPField.error: EHTTPKey.errNoInternet.toString().split('.')[1],
//       };
//     }

//     isOffline = false;

//     // REQUEST TRANSACTION TO SERVER
//     var httpResponse;
//     String queryString = '';

//     try {
//       var headerMap = await _getHeaderMap(isHead: isHead);
//       switch (method) {
//         case EHTTPMethod.get:
//           List<String> arrQueryString = [];
//           bodyMap.forEach((k, v) {
//             arrQueryString.add('$k=$v');
//           });
//           queryString = arrQueryString.join('&');
//           httpResponse = await http.get(
//             Uri.parse(mainUrlApi + uri + (queryString.isEmpty ? '' : '?$queryString')),
//             headers: headerMap,
//           ).timeout(const Duration(seconds: 120));
//           break;

//         case EHTTPMethod.delete:
//           httpResponse = await http.delete(
//             Uri.parse(mainUrlApi + uri),
//             body: bodyMap,
//             headers: headerMap,
//           ).timeout(const Duration(seconds: 120));
//           break;

//         case EHTTPMethod.put:
//         case EHTTPMethod.post:
//         default:
//           httpResponse = await http.post(
//             Uri.parse(mainUrlApi + uri),
//             body: bodyMap,
//             headers: headerMap,
//           ).timeout(const Duration(seconds: 120));
//           break;
//       }

//       // Handle responses...
//       if (httpResponse == null) {
//         return {
//           EHTTPField.code: 408,
//           EHTTPField.key: EHTTPKey.errNoResponse,
//           EHTTPField.body: EHTTPKey.errNoResponse,
//           EHTTPField.error: EHTTPKey.errNoResponse,
//         };
//       }

//       // Continue handling various status codes...
//       if (httpResponse.statusCode == 200) {
//         return {
//           EHTTPField.code: httpResponse.statusCode,
//           EHTTPField.key: EHTTPKey.responseOK,
//           EHTTPField.body: json.decode(httpResponse.body),
//           EHTTPField.error: '',
//         };
//       } else {
//         // Handle other status codes
//         var decodedError = json.decode(httpResponse.body);
//         return {
//           EHTTPField.code: httpResponse.statusCode,
//           EHTTPField.key: EHTTPKey.errResponse,
//           EHTTPField.body: decodedError ?? '',
//           EHTTPField.error: _getErrorMessageOutline(decodedError, httpResponse.statusCode),
//         };
//       }
//     } catch (error) {
//       return {
//         EHTTPField.code: 400,
//         EHTTPField.key: EHTTPKey.errUnexpect,
//         EHTTPField.body: error.toString(),
//         EHTTPField.error: error.toString(),
//       };
//     }
//   }

//   static String _getErrorMessageOutline(var error, var responseCode) {
//     String msg = '';
//     if (error is Map) {
//       error.forEach((k, v) {
//         if (v is! List) {
//           msg += v.toString();
//         } else {
//           for (var item in v) {
//             msg += item.toString();
//           }
//         }
//       });
//     } else {
//       msg = 'Error [${responseCode.toString()}] : $error';
//     }
//     return msg;
//   }
// }
