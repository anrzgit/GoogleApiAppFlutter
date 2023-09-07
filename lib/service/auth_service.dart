import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/youtube/v3.dart';

// ignore: prefer_typing_uninitialized_variables
var httpClient;
var accessToken;

class AuthService {
  signInWithGoogle() async {
    try {
      ///
      final _googleSignIn = GoogleSignIn(
        scopes: <String>[
          // YouTubeApi.youtubeReadonlyScope,
          'https://www.googleapis.com/auth/gmail.readonly',
        ],
      );

      ///

      // Trigger the authentication flow
      final GoogleSignInAccount? gUser = await _googleSignIn.signIn();

      ///
      if (gUser == null) {
        print('Error: Google sign-in failed');
        return;
      }

      var authClient = await _googleSignIn.authenticatedClient();

      httpClient = await authClient;
      accessToken = await authClient!.credentials.accessToken;

      print("authClient  $authClient");
      print("httpClient in sign in $httpClient");

      void listenUserChange() {
        _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? user) {
          print('user changed');
        });
      }

      ///
      ///

      // Obtain the auth details from the request
      final GoogleSignInAuthentication gAuth = await gUser!.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken, idToken: gAuth.idToken);

      // Once signed in, return the UserCredential
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      //check if user already exist

      final userRef = FirebaseFirestore.instance
          .collection('google_users')
          .doc(userCredential.user!.uid);
      final doc = await userRef.get();
      if (doc.exists) {
        // User is already present, update only specific values
        await userRef.update({
          'last_login': DateTime.now().toLocal().toString(),
          // Add other fields you want to update here
        });
      } else {
        // User is not present, create a new document
        await userRef.set({
          'email': userCredential.user!.email,
          'username': userCredential.user!.uid,
          'profile_pic': userCredential.user!.photoURL,
          'name': userCredential.user!.displayName,
          'phoneNumber': userCredential.user!.phoneNumber,
          'created_at': DateTime.now().toUtc().toString(),
          'is_admin': false,
          'is_super_admin': false,
        });
      }

      //update the user provider
    } catch (e) {
      return e;
    }
  }

  signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    print('signed out');
  }

  getHttpClient() {
    print('httpClient in getHttpClient $httpClient');
    return httpClient;
  }

  getAccessToken() {
    print('accessToken in getAccessToken $accessToken');
    return accessToken;
  }
}
