import "package:flutter/material.dart";
import "package:flutter_user/flutter_user.dart";

class FlutterUserOptions {
  FlutterUserOptions({
    this.loginOptions = const LoginOptions(),
    this.loginTranslations = const LoginTranslations(),
    this.forgotPasswordTranslations = const ForgotPasswordTranslations(),
    this.beforeLogin,
    this.afterLogin,
    this.onBoardedUser,
    this.useOnboarding = false,
    this.automaticLogin = true,
    this.onOnboardingComplete,
    this.onRegister,
    this.onForgotPassword,
    this.onRequestForgotPassword,
    this.onForgotPasswordSuccess,
    this.onForgotPasswordUnsuccessful,
    this.onRegistrationError,
    this.afterRegistration,
    this.afterRegistrationSuccess,
    this.afterRegistrationUnsuccessful,
    registrationOptions,
  }) : registrationOptions = registrationOptions ?? RegistrationOptions();

  final LoginOptions loginOptions;
  final LoginTranslations loginTranslations;
  final RegistrationOptions? registrationOptions;
  final ForgotPasswordTranslations forgotPasswordTranslations;
  final Future Function(String email, String password)? beforeLogin;
  final Future Function()? afterLogin;
  final Future<OnboardedUserMixin?> Function()? onBoardedUser;
  final bool useOnboarding;

  /// Automatically log in the user if they have already logged in before
  final bool automaticLogin;
  final Future Function(Map<int, Map<String, dynamic>> onboardingResults)?
      onOnboardingComplete;
  final Future Function(String email, String password, BuildContext context)?
      onRegister;
  final Future Function(String email, BuildContext context)? onForgotPassword;
  final Future Function(String email)? onRequestForgotPassword;
  final Future Function()? onForgotPasswordSuccess;
  final Future Function()? onForgotPasswordUnsuccessful;
  final Future<int?> Function(String error)? onRegistrationError;
  final Future Function()? afterRegistration;
  final Future Function()? afterRegistrationSuccess;
  final Future Function()? afterRegistrationUnsuccessful;
}
