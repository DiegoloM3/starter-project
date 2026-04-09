import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/constants/dimens.dart';
import 'package:news_app_clean_architecture/core/extensions/context_extensions.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/base_scaffold.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/button/loading_button.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/text_field/base_text_field.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/text_field/text_field_type.dart';
import 'package:news_app_clean_architecture/features/login/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/login/presentation/bloc/login_bloc.dart';
import 'package:news_app_clean_architecture/features/login/presentation/bloc/register_field_error.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;

    return BaseScaffold(
      body: BlocProvider<LoginBloc>.value(
        value: sl<LoginBloc>(),
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: Dimens.screenPaddingHorizontal,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BaseTextField(
                    controller: _nameController,
                    hint: localizations.name,
                    type: TextFieldType.outline,
                    errorText: state.registerErrors
                        .getNameError(localizations: localizations),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: Dimens.m),
                    child: BaseTextField(
                      controller: _emailController,
                      hint: localizations.email,
                      type: TextFieldType.outline,
                      errorText: state.registerErrors
                          .getEmailError(localizations: localizations),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      top: Dimens.m,
                    ),
                    child: BaseTextField(
                      controller: _passwordController,
                      hint: localizations.password,
                      textType: BaseTextFieldType.password,
                      type: TextFieldType.outline,
                      errorText: state.registerErrors
                          .getPasswordError(localizations: localizations),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: Dimens.l),
                    child: LoadingButton(
                      isLoading: state is LoginLoading,
                      text: localizations.register,
                      onTap: () {
                        context.read<LoginBloc>().add(
                              CreateUserRequested(
                                user: UserEntity(
                                  id: '',
                                  email: _emailController.text,
                                  name: _nameController.text,
                                ),
                                password: _passwordController.text,
                              ),
                            );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
