import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_user/src/models/registration/auth_field.dart";
import "package:flutter_user/src/models/registration/registration_options.dart";
import "package:user_repository_interface/user_repository_interface.dart";

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({
    required this.userService,
    required this.registrationOptions,
    required this.onError,
    required this.afterRegistration,
    super.key,
  });
  final UserService userService;

  final RegistrationOptions registrationOptions;
  final Future<int?> Function(String?) onError;
  final Future<void> Function() afterRegistration;

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  final _animationDuration = const Duration(milliseconds: 300);
  final _animationCurve = Curves.ease;

  /// Validates the current step.
  void _validate(int currentPage) {
    var isStepValid = true;

    // Loop through each field in the current step
    for (var field in widget.registrationOptions.steps[currentPage].fields) {
      for (var validator in field.validators) {
        var validationResult = validator(field.value);
        if (validationResult != null) {
          // If any validator returns an error, mark step as invalid and break
          isStepValid = false;
          break;
        }
      }
      if (!isStepValid) {
        break; // No need to check further fields if one is already invalid
      }
    }
  }

  Future<void> onPrevious() async {
    FocusScope.of(context).unfocus();
    await _pageController.previousPage(
      duration: _animationDuration,
      curve: _animationCurve,
    );
  }

  Future<void> onNext() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();
    _validate(_pageController.page!.toInt());

    var success = await onFinish();
    if (success) {
      return;
    }

    await _pageController.nextPage(
      duration: _animationDuration,
      curve: _animationCurve,
    );
  }

  Future<bool> onFinish() async {
    if (_pageController.page!.toInt() ==
        widget.registrationOptions.steps.length - 1) {
      var values = <String, dynamic>{};

      for (var step in widget.registrationOptions.steps) {
        for (var field in step.fields) {
          values[field.name] = field.value;
        }
      }

      var registrationReponse =
          await widget.userService.register(values: values);

      if (!registrationReponse.registrationSuccessful) {
        var pageToReturn = await widget.onError
            .call(registrationReponse.registrationError?.title);

        if (pageToReturn != null) {
          if (pageToReturn == _pageController.page!.toInt()) {
            return true;
          }
          await _pageController.animateToPage(
            pageToReturn,
            duration: _animationDuration,
            curve: _animationCurve,
          );
          return true;
        }
      } else {
        await widget.afterRegistration.call();
      }
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var registrationOptions = widget.registrationOptions;
    return Scaffold(
      backgroundColor: registrationOptions.registrationBackgroundColor,
      appBar: registrationOptions.customAppbarBuilder.call(
        registrationOptions.translations.title,
      ),
      body: SafeArea(
        child: Center(
          child: Form(
            key: _formKey,
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (var currentStep = 0;
                    currentStep < registrationOptions.steps.length;
                    currentStep++) ...[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (registrationOptions.title != null) ...[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              flex: registrationOptions
                                  .spacerOptions.beforeTitleFlex,
                              child: Container(),
                            ),
                            registrationOptions.title!,
                            Expanded(
                              flex: registrationOptions
                                  .spacerOptions.afterTitleFlex,
                              child: Container(),
                            ),
                          ],
                        ),
                      ],
                      Expanded(
                        flex: registrationOptions.spacerOptions.formFlex,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Column(
                            children: [
                              for (AuthField field in registrationOptions
                                  .steps[currentStep].fields) ...[
                                if (field.title != null) ...[
                                  wrapWithDefaultStyle(
                                    style: theme.textTheme.headlineLarge!,
                                    widget: field.title!,
                                  ),
                                ],
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: registrationOptions.maxFormWidth,
                                  ),
                                  child: field.build(context, () {
                                    _validate(currentStep);
                                  }),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                bottom: 20,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  registrationOptions.previousButtonBuilder
                                          ?.call(
                                        onPrevious,
                                        registrationOptions
                                            .translations.previousStepBtn,
                                        currentStep,
                                      ) ??
                                      Visibility(
                                        visible: currentStep != 0,
                                        child: stepButton(
                                          buttonText: registrationOptions
                                              .translations.previousStepBtn,
                                          onTap: () async {
                                            await onPrevious();
                                          },
                                        ),
                                      ),
                                  registrationOptions.nextButtonBuilder?.call(
                                        onPrevious,
                                        currentStep ==
                                                registrationOptions
                                                        .steps.length -
                                                    1
                                            ? registrationOptions
                                                .translations.registerBtn
                                            : registrationOptions
                                                .translations.nextStepBtn,
                                        currentStep,
                                      ) ??
                                      stepButton(
                                        buttonText: currentStep ==
                                                registrationOptions
                                                        .steps.length -
                                                    1
                                            ? registrationOptions
                                                .translations.registerBtn
                                            : registrationOptions
                                                .translations.nextStepBtn,
                                        onTap: () async {
                                          await onNext();
                                        },
                                      ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          if (registrationOptions.loginButton != null) ...[
                            registrationOptions.loginButton!,
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget stepButton({
    required String buttonText,
    required Future Function()? onTap,
  }) {
    var theme = Theme.of(context);
    return Flexible(
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            maxWidth: 180,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(
                0xff979797,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              buttonText,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget wrapWithDefaultStyle({
    required Widget widget,
    required TextStyle style,
  }) =>
      DefaultTextStyle(style: style, child: widget);
}
