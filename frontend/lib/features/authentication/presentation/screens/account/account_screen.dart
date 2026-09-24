import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/widgets/alert_banner.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/widgets/reader_scaffold.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/article_byline/article_byline_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/article_byline/article_byline_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/journalist_stats/journalist_stats_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/journalist_stats/journalist_stats_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/widgets/article_failure_text.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../domain/entities/app_user.dart';
import '../../../domain/params/update_display_name_params.dart';
import '../../widgets/auth_failure_text.dart';
import '../../bloc/session/session_cubit.dart';
import '../../bloc/session/session_state.dart';

/// The signed-in person's own corner of the app — and, when nobody is signed
/// in, the invitation to make an account.
///
/// Signing in is never required to read (see `docs/DECISIONS.md` decision
/// #31), so the signed-out state is a normal state of this screen and not an
/// error.
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();
    // Whatever went wrong on the sign-in screen was said there; this screen
    // starts clean and only reports what happens on it.
    context.read<SessionCubit>().clearFailure();
    _loadStatsFor(context.read<SessionCubit>().state.user);
  }

  /// What went wrong here, or null. Read off the status rather than off
  /// `error` alone, so a failure already cleared stops being reported.
  static Object? _failureOf(SessionState state) =>
      state.status == SessionStatus.failure ? state.error : null;

  void _loadStatsFor(AppUserEntity? user) {
    final stats = context.read<JournalistStatsCubit>();

    if (user == null) {
      stats.clear();
      return;
    }

    stats.loadFor(user.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SessionCubit, SessionState>(
      // The numbers belong to whoever is signed in, so they are reloaded when
      // that changes and dropped when nobody is.
      listenWhen: (previous, current) =>
          previous.user != current.user || previous.status != current.status,
      listener: (context, state) => _loadStatsFor(state.user),
      builder: (context, state) {
        final user = state.user;

        return Scaffold(
          body: SafeArea(
            child: user == null
                ? const _SignedOutInvitation()
                : _SignedIn(user: user, failure: _failureOf(state)),
          ),
        );
      },
    );
  }
}

class _SignedIn extends StatelessWidget {
  final AppUserEntity user;

  /// Whatever the last account operation refused to do, or null.
  final Object? failure;

  const _SignedIn({required this.user, this.failure});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xxxl,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      children: [
        // A banner rather than the snack bar this used to be: a rejected name
        // needs to stay readable next to the row that was rejected, not
        // vanish four seconds later at the bottom of the screen.
        if (failure != null) ...[
          AlertBanner(
            AuthFailureText.messageFor(AppLocalizations.of(context), failure),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        const _BylineNotice(),
        Center(
          child: Column(
            children: [
              AuthorAvatar(name: user.authorName, size: 84, soft: true),
              const SizedBox(height: AppSpacing.lg),
              Text(
                user.authorName,
                style: theme.textTheme.displayLarge?.copyWith(fontSize: 28),
                textAlign: TextAlign.center,
                // 50 characters is a legal name on a narrow phone, and this
                // is display size: without a limit it ran off the screen.
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                user.email,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              const _StatsChip(),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        const Divider(),
        const SizedBox(height: AppSpacing.lg),
        const _MyArticlesRow(),
        const SizedBox(height: AppSpacing.md),
        _AccountRow(
          icon: Icons.badge_outlined,
          label: AppLocalizations.of(context).nameReadersSee,
          trailing: Text(
            user.authorName,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
          onTap: () => _editDisplayName(context, user),
        ),
        const SizedBox(height: AppSpacing.huge),
        _SignOutButton(
          onPressed: () => context.read<SessionCubit>().signOut(),
        ),
      ],
    );
  }
}

/// Asks for a new byline, and then makes it true of the work already out.
///
/// Changing the name used to apply only to the next article, because the
/// byline is copied onto each one as it is saved. Somebody correcting a name
/// they typed in a hurry at sign-up found their published work still carrying
/// the old one, with nothing on the screen admitting it. The rename is now
/// two steps: the account, and then the catalogue.
Future<void> _editDisplayName(BuildContext context, AppUserEntity user) async {
  final session = context.read<SessionCubit>();
  final byline = context.read<ArticleBylineCubit>();

  final name = await showDialog<String>(
    context: context,
    builder: (_) => _DisplayNameDialog(initialName: user.displayName),
  );

  if (name == null) {
    return;
  }

  await session.updateDisplayName(name);

  final renamed = session.state.user;

  // A rejected name (blank, or too long) never reaches the articles: they
  // would otherwise be rewritten to something the account itself refused.
  if (renamed == null || session.state.status == SessionStatus.failure) {
    return;
  }

  await byline.renameTo(
    userId: renamed.id,
    authorName: renamed.authorName,
  );
}

/// Reports what renaming did to the work already published.
///
/// Renaming reaches back over the whole catalogue, which is not obvious from a
/// dialog that only asked for a name — so when it moves something, it says so.
/// And the two steps can come apart, because the name is stored by the auth
/// provider and the bylines by Firestore: a silent half-rename is exactly the
/// kind of thing an author only discovers from a reader.
class _BylineNotice extends StatelessWidget {
  const _BylineNotice();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArticleBylineCubit, ArticleBylineState>(
      builder: (context, state) {
        final message = _messageFor(AppLocalizations.of(context), state);

        if (message == null) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          child: AlertBanner(
            message,
            tone: state.status == ArticleBylineStatus.failure
                ? AlertTone.error
                : AlertTone.success,
          ),
        );
      },
    );
  }

  /// What there is to say, or null when there is nothing.
  ///
  /// A rename that moved no articles is silent: somebody who has not
  /// published yet does not need to be told that nothing was republished.
  static String? _messageFor(AppLocalizations l10n, ArticleBylineState state) {
    switch (state.status) {
      case ArticleBylineStatus.failure:
        return ArticleFailureText.messageFor(l10n, state.error);
      case ArticleBylineStatus.done:
        return state.renamedCount == 0
            ? null
            : l10n.bylineUpdated(state.renamedCount);
      case ArticleBylineStatus.idle:
      case ArticleBylineStatus.working:
        return null;
    }
  }
}

/// Owns its own text controller.
///
/// `showDialog` returns the moment the route is popped, while the dialog is
/// still animating out and its field is still on screen. A controller created
/// and disposed around that call is therefore disposed while still in use —
/// letting the dialog manage its own lifecycle is what avoids that.
class _DisplayNameDialog extends StatefulWidget {
  final String initialName;

  const _DisplayNameDialog({required this.initialName});

  @override
  State<_DisplayNameDialog> createState() => _DisplayNameDialogState();
}

class _DisplayNameDialogState extends State<_DisplayNameDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).nameReadersSee),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: UpdateDisplayNameParams.maxLength,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).yourName,
          helperText: AppLocalizations.of(context).nameHelper,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(AppLocalizations.of(context).save),
        ),
      ],
    );
  }
}

/// "12 articles · 3.4K views", once there is something to say.
///
/// It stays out of the way entirely for somebody who has not written yet:
/// "0 articles · 0 views" is a worse welcome than nothing at all.
class _StatsChip extends StatelessWidget {
  const _StatsChip();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalistStatsCubit, JournalistStatsState>(
      builder: (context, state) {
        if (!state.isReady || !state.hasArticles) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Text(
            AppLocalizations.of(context).statsSummary(
              AppLocalizations.of(context).articleCount(state.articleCount),
              compactCount(state.totalViews),
            ),
            style: Theme.of(context).textTheme.labelLarge,
          ),
        );
      },
    );
  }

  static String compactCount(int value) {
    if (value < 1000) {
      return '$value';
    }

    final thousands = value / 1000;

    return '${thousands.toStringAsFixed(thousands < 10 ? 1 : 0)}K';
  }
}

class _MyArticlesRow extends StatelessWidget {
  const _MyArticlesRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalistStatsCubit, JournalistStatsState>(
      builder: (context, state) {
        return _AccountRow(
          icon: Icons.description_outlined,
          label: AppLocalizations.of(context).myArticles,
          trailing: state.isReady && state.hasArticles
              ? Text(
                  '${state.articleCount}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.accent,
                      ),
                )
              : null,
          onTap: () => Navigator.pushNamed(context, '/MyArticles'),
        );
      },
    );
  }
}

class _AccountRow extends StatelessWidget {
  /// Most of the row a value may take before it is cut short, leaving the
  /// rest to the label that says what it is.
  static const double _maxTrailingFraction = 0.5;

  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _AccountRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.card,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.cardRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) => Row(
                children: [
                  Icon(icon, size: 22),
                  const SizedBox(width: AppSpacing.md),
                  // The label is the only child that stretches, so it takes
                  // whatever the rest of the row does not. Making the value
                  // flexible as well split the free space between the two and
                  // left the remainder at the end of the row, which pushed
                  // the value and the chevron away from the right edge.
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 16,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: AppSpacing.md),
                    // Capped rather than flexible: the value takes the width
                    // it needs and sits against the chevron, and a long one
                    // — a display name at its 50 character limit — is cut
                    // short here instead of overflowing the row.
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * _maxTrailingFraction,
                      ),
                      child: trailing!,
                    ),
                  ],
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).textTheme.labelSmall?.color,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SignOutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.logout, size: 20, color: AppColors.danger),
      label: Text(AppLocalizations.of(context).signOut),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.danger,
        side: BorderSide(color: AppColors.danger.withValues(alpha: 0.4)),
      ),
    );
  }
}

/// What this tab shows to a reader with no account.
///
/// It explains what an account is *for* rather than demanding one: nothing
/// they are doing right now requires it.
class _SignedOutInvitation extends StatelessWidget {
  const _SignedOutInvitation();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit_outlined,
                size: 32,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              AppLocalizations.of(context).accountInviteTitle,
              style: theme.textTheme.displayLarge?.copyWith(fontSize: 26),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppLocalizations.of(context).accountInviteMessage,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, '/SignUp'),
              child: Text(AppLocalizations.of(context).createAnAccount),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/SignIn'),
              child: Text(AppLocalizations.of(context).alreadyHaveAccount),
            ),
          ],
        ),
      ),
    );
  }
}
