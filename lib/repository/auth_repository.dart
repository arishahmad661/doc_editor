import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/constants.dart';
import 'package:google_docs/model/error_model.dart';
import 'package:google_docs/repository/local_storage_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

import '../model/user_model.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(googleSignIn: GoogleSignIn(), client: Client(), localStorageRepository: LocalStorageRepository()));

final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthRepository{
  final GoogleSignIn _googleSignIn;
  final Client _client;
  final LocalStorageRepository _localStorageRepository;
  AuthRepository({
    required Client client,
    required GoogleSignIn googleSignIn,
    required LocalStorageRepository localStorageRepository,
}): _googleSignIn = googleSignIn, _client = client, _localStorageRepository = localStorageRepository;

  Future<ErrorModel> signInwithGoogle() async {
    ErrorModel error = ErrorModel(error: "Some Unexpected Error Occurred", data: null);
    try{
      final user = await _googleSignIn.signIn();
      if(user != null){
        final userAcc = UserModel(
          email: user.email,
          name: user.displayName!,
          profilePic: user.photoUrl ?? "",
          uid: '',
          token:'',
        );
        var res = await _client.post(
            Uri.parse('$host/api/signup'),
          body:userAcc.toJson(),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          }
        );

        switch(res.statusCode){
          case 200:
            final newUser = userAcc.copyWith(
              uid: jsonDecode(res.body)['user']['_id'],
              token: jsonDecode(res.body)['token'],
            );
            error = ErrorModel(error: null, data: newUser);
            _localStorageRepository.setToken(newUser.token);
            break;
          default:
            break;
        }
      }
    }
    catch(e){
      log(e.toString());
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  Future<ErrorModel> getUserdata() async {
    ErrorModel error = ErrorModel(error: "Some Unexpected Error Occurred", data: null);
    try {
      String? token = await _localStorageRepository.getToken();

      if (token != null) {
        var res = await _client.get(
            Uri.parse('$host/'),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'x-auth-token': token,
            }
        );
        switch(res.statusCode){
          case 200:
            final newUser = UserModel.fromJson(jsonEncode(jsonDecode(res.body)['user'],)).copyWith(token: token);
            error = ErrorModel(error: null, data: newUser);
            _localStorageRepository.setToken(newUser.token);
            break;
          default:
            break;
        }
      }
    }
    catch(e){
      log(e.toString());
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  void signOut() async {
    await _googleSignIn.signOut();
    _localStorageRepository.setToken('');
  }
}