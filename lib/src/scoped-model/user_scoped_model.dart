import 'package:SasaPlant/src/enums/auth_mode.dart';
import 'package:SasaPlant/src/models/user_info_model.dart';
import 'package:SasaPlant/src/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserModel extends Model {
  List<User> _users = [];
  List<UserInfo> _userInfos = [];

  User _authenticatedUser;
  UserInfo _authenticatedUserInfo;

  bool _isLoading = false;

  List<User> get users {
    return List.from(_users);
  }

  List<UserInfo> get userInfos {
    return List.from(_userInfos);
  }

  User get authtenticatedUser {
    return _authenticatedUser;
  }

  UserInfo get authtenticatedUserInfo {
    return _authenticatedUserInfo;
  }

  bool get isLoading {
    return _isLoading;
  }

  Future<bool> fetchUserInfos() async {
    _isLoading = true;
    notifyListeners();

    try {
      final http.Response response = await http
          .get("https://sasaplant-69216-default-rtdb.firebaseio.com/users.json");

      // print("Fecthing data: ${response.body}");
      final Map<String, dynamic> fetchedData = json.decode(response.body);

      final List<UserInfo> userInfos = [];

      fetchedData.forEach((String id, dynamic userInfoData) {
        UserInfo userInfo = UserInfo(
          id: id,
          email: userInfoData['email'],
          userType: userInfoData['userType'],
          userId: userInfoData['localId'],
          username: userInfoData['username'],
        );

        userInfos.add(userInfo);
      });

      _userInfos = userInfos;
      _isLoading = false;
      notifyListeners();
      return Future.value(true);
    } catch (error) {
      print("The errror: $error");
      _isLoading = false;
      notifyListeners();
      return Future.value(false);
    }
  }

  Future<bool> addUserInfo(Map<String, dynamic> userInfo) async {
    _isLoading = true;
    notifyListeners();

    try {
      final http.Response response = await http.post(
          "https://sasaplant-69216-default-rtdb.firebaseio.com/users.json",
          body: json.encode(userInfo));

      final Map<String, dynamic> responseData = json.decode(response.body);

      UserInfo userInfoWithID = UserInfo(
        id: responseData['name'],
        email: userInfo['email'],
        username: userInfo['username'],
      );

      _userInfos.add(userInfoWithID);
      _isLoading = false;
      notifyListeners();
      return Future.value(true);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return Future.value(false);
    }
  }

  Future<UserInfo> getUserInfo(String userId) async {
    final bool response = await fetchUserInfos();
    print("The response: $response");
    UserInfo foundUserInfo;

    print("the user Infos: $_userInfos");
    if (response) {
      for (int i = 0; i < _userInfos.length; i++) {
        if (_userInfos[i].userId == userId) {
          foundUserInfo = _userInfos[i];
          print("The found user: $foundUserInfo");
          break;
        }
      }
    }

    return Future.value(foundUserInfo);
  }

  UserInfo getUserDetails(String userId) {
    fetchUserInfos();
    UserInfo foundUserInfo;

    for (int i = 0; i < _userInfos.length; i++) {
      if (_userInfos[i].userId == userId) {
        foundUserInfo = _userInfos[i];
        break;
      }
    }
    return foundUserInfo;
  }

  Future<Map<String, dynamic>> authenticate(String email, String password,
      {AuthMode authMode = AuthMode.SignIn,
      Map<String, dynamic> userInfo}) async {
    _isLoading = true;
    notifyListeners();

    Map<String, dynamic> authData = {
      "email": email,
      "password": password,
      "returnSecureToken": true,
    };

    String message;
    bool hasError = false;

    try {
      http.Response response;
      if (authMode == AuthMode.SignUp) {
        response = await http.post(
          "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyBpyppfpmRZbhcgZFhN4oKsyQG-u9SeRTY",
          body: json.encode(authData),
          headers: {'Content-Type': 'application/json'},
        );
      } else if (authMode == AuthMode.SignIn) {
        response = await http.post(
          "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyBpyppfpmRZbhcgZFhN4oKsyQG-u9SeRTY",
          body: json.encode(authData),
          headers: {'Content-Type': 'application/json'},
        );
      }

      Map<String, dynamic> responseBody = json.decode(response.body);

      if (responseBody.containsKey('idToken')) {
        _authenticatedUser = User(
          id: responseBody['localId'],
          email: responseBody['email'],
          token: responseBody['idToken'],
        );

        if (authMode == AuthMode.SignIn) {
          _authenticatedUserInfo = await getUserInfo(responseBody['localId']);

          message = "Sign in successfully";
        } else if (authMode == AuthMode.SignUp) {
          userInfo['localId'] = responseBody['localId'];
          addUserInfo(userInfo);
          message = "Sign up successfully";
        }
      } else {
        hasError = true;
        if (responseBody['error']['message'] == 'EMAIL_EXISTS') {
          message = "Email already exists";
        } else if (responseBody['error']['message'] == "EMAIL_NOT_FOUND") {
          message = "Email does not exist";
        } else if (responseBody['error']['message'] == "INVALID_PASSWORD") {
          message = "Password is incorrect";
        }
      }

      _isLoading = false;
      notifyListeners();
      return {
        'message': message,
        'hasError': hasError,
      };
    } catch (error) {
      print("The error: $error");
      _isLoading = false;
      notifyListeners();

      return {
        'message': 'Failed to sign up',
        'hasError': !hasError,
      };
    }
  }

  void logout() {
    _authenticatedUser = null;
    _authenticatedUserInfo = null;
  }
}
