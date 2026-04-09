import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/config/routes/paths.dart';
import 'package:news_app_clean_architecture/core/constants/dimens.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/base_scaffold.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/button/base_button.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/button/button_type.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/button/loading_button.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/text_field/base_text_field.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/text_field/text_field_type.dart';
import 'package:news_app_clean_architecture/features/login/presentation/bloc/login_bloc.dart';
import 'package:news_app_clean_architecture/features/login/presentation/bloc/login_field_error.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: BlocProvider.value(
        value: sl<LoginBloc>(),
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) => switch (state) {
            NotLoggedIn() ||
            LoginInitial() ||
            LoggedIn() ||
            LoginLoading() =>
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: Dimens.screenPaddingHorizontal,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BaseTextField(
                      controller: _emailController,
                      hint: AppLocalizations.of(context).email,
                      type: TextFieldType.outline,
                      errorText: state.loginErrors.getEmailError(
                          localizations: AppLocalizations.of(context)),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        top: Dimens.m,
                      ),
                      child: BaseTextField(
                        controller: _passwordController,
                        hint: AppLocalizations.of(context).password,
                        textType: BaseTextFieldType.password,
                        type: TextFieldType.outline,
                        errorText: state.loginErrors.getPasswordError(
                            localizations: AppLocalizations.of(context)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(top: Dimens.l),
                      child: LoadingButton(
                        isLoading: state is LoginLoading,
                        text: AppLocalizations.of(context).login,
                        onTap: () {
                          context.read<LoginBloc>().add(
                                SignInWithEmailAndPasswordRequested(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                ),
                              );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(top: Dimens.m),
                      child: BaseButton(
                        text: AppLocalizations.of(context).register,
                        type: ButtonType.alternative,
                        onTap: () => context.pushNamed(Paths.register.name),
                      ),
                    ),
                  ],
                ),
              ),
            LoginError() => Center(
                child: Text(AppLocalizations.of(context).something_was_wrong),
              ),
          },
        ),
      ),
    );
  }
}
