import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/constants/colors.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';

class UserAvatar extends StatelessWidget {
  final double radius;

  const UserAvatar({
    super.key,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFD6E4F0),
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthSuccess && !state.user.isAnonymous) {
            final String initial =
                state.user.displayName?.substring(0, 2).toUpperCase() ?? 'AU';
            return Text(
              initial,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.8,
              ),
            );
          }
          return Icon(
            Icons.person,
            color: AppColors.primary,
            size: radius,
          );
        },
      ),
    );
  }
}
