import 'package:google_sign_in/google_sign_in.dart';

Future<String?> signInWithGoogle() async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      //for web
      clientId:
          '543363315255-1ge4unfce44qqh34qrjdl9vrvrdf91lu.apps.googleusercontent.com',

      // serverClientId:
      // '543363315255-1ge4unfce44qqh34qrjdl9vrvrdf91lu.apps.googleusercontent.com',
      scopes: <String>[
        'https://www.googleapis.com/auth/calendar',
        'https://www.googleapis.com/auth/calendar.events'
      ],
    );
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;
    return googleSignInAuthentication.accessToken;
  } catch (error) {
    print('Error signing in with Google');
    return null;
  }
}
