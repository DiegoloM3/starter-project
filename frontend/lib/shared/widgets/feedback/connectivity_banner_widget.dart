import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/global_themes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/shared/bloc/connectivity/connectivity_bloc.dart';
import 'package:news_app_clean_architecture/di/service_locator.dart';

class ConnectivityBannerWidget extends StatelessWidget {
  final Widget child;
  const ConnectivityBannerWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ConnectivityBloc>(),
      child: BlocBuilder<ConnectivityBloc, ConnectivityState>(
        builder: _buildContent,
      ),
    );
  }

  Widget _buildContent(BuildContext context, ConnectivityState state) {
    return Column(
      children: [
        _buildAnimatedBanner(state),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildAnimatedBanner(ConnectivityState state) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        child: state is ConnectivityOffline ? _buildBanner() : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildBanner() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        color: GlobalTheme.kOxblood,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 14, color: GlobalTheme.kPaper),
              const SizedBox(width: 8),
              const Text(
                'SIN CONEXIÓN A INTERNET',
                style: TextStyle(
                  color: GlobalTheme.kPaper,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}