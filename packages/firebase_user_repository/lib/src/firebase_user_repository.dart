import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:user_repository_interface/user_repository_interface.dart";

class FirebaseUserRepository implements UserRepositoryInterface {
  FirebaseUserRepository({
    this.userCollecton = "users",
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;
  final String userCollecton;

  @override
  Future<LoginResponse> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      var userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return LoginResponse(
        loginSuccessful: true,
        userObject: userCredential.user,
      );
    } on FirebaseAuthException catch (e) {
      return LoginResponse(
        loginSuccessful: false,
        userObject: null,
        loginError: UserError(
          title: e.code,
          message: e.message ?? "An error occurred",
        ),
      );
    }
  }

  @override
  Future<RegistrationResponse> register({
    required Map<String, dynamic> values,
  }) async {
    try {
      var userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: values["email"],
        password: values["password"],
      );
      //remove password from values
      values.remove("password");

      await FirebaseFirestore.instance
          .collection(userCollecton)
          .doc(userCredential.user!.uid)
          .set(values);

      return RegistrationResponse(
        registrationSuccessful: true,
        userObject: userCredential.user,
      );
    } on FirebaseAuthException catch (e) {
      return RegistrationResponse(
        registrationSuccessful: false,
        userObject: null,
        registrationError: UserError(
          title: e.code,
          message: e.message ?? "An error occurred",
        ),
      );
    }
  }

  @override
  Future<RequestPasswordResponse> requestChangePassword({
    required String email,
  }) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const RequestPasswordResponse(
        requestSuccesfull: true,
      );
    } on FirebaseAuthException catch (e) {
      return RequestPasswordResponse(
        requestSuccesfull: false,
        requestPasswordError: UserError(
          title: e.code,
          message: e.message ?? "An error occurred",
        ),
      );
    }
  }

  @override
  Future<bool> logout() async {
    await _firebaseAuth.signOut();
    return true;
  }

  @override
  Future getLoggedInUser() async => _firebaseAuth.currentUser;

  @override
  Future<bool> isLoggedIn() async => _firebaseAuth.currentUser != null;
}
