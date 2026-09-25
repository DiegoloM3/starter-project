import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/core/presentation/formatting/relative_time.dart';
import 'package:news_app_clean_architecture/core/presentation/formatting/utf16_length_limit.dart';
import 'package:news_app_clean_architecture/core/presentation/widgets/app_image.dart';
import 'package:news_app_clean_architecture/core/presentation/widgets/app_toast.dart';
import 'package:news_app_clean_architecture/core/presentation/widgets/submit_progress_overlay.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/form/article_form_input.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/form/user_article_form_cubit.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/form/user_article_form_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/widgets/article_body_editing_controller.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/widgets/article_content_field.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';
import 'package:news_app_clean_architecture/shared/connectivity/presentation/bloc/connectivity_cubit.dart';

enum _FormExitAction { cancel, discard, draft, save }

class UserArticleFormScreen extends StatefulWidget {
  final UserArticleEntity? existingArticle;

  const UserArticleFormScreen({super.key, this.existingArticle});

  @override
  State<UserArticleFormScreen> createState() => _UserArticleFormScreenState();
}

class _UserArticleFormScreenState extends State<UserArticleFormScreen>
    with WidgetsBindingObserver {
  // Same ceilings firestore.rules enforces (title's there is 150; the form
  // keeps a tighter headline), counted in the same unit.
  static const _bylineMaxLength = 60;
  static const _titleMaxLength = 120;
  static const _summaryMaxLength = 300;

  final _formKey = GlobalKey<FormState>();
  final _submitOverlay = SubmitProgressOverlay();
  late final TextEditingController _authorNameController;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final ArticleBodyEditingController _contentController;

  Uint8List? _pickedImageBytes;
  String? _pickedImageExtension;
  String? _imageError;

  bool _previewingContent = false;

  /// Set right before leaving through discard, so PopScope's guard doesn't
  /// block this deliberate, already-decided exit.
  bool _discardConfirmed = false;
  bool _leaving = false;

  /// The form as it was when this session started -- a suggested byline
  /// counts as part of it, not as an edit. "Changed" and "discard" are
  /// measured against this.
  late ArticleFormInput _initial;

  /// What autosave last persisted: "is there anything new to autosave?" is
  /// measured against this, not against [_initial].
  late ArticleFormInput _lastAutosaved;

  Timer? _autosaveDebounce;
  Timer? _autosaveTimer;
  bool _autosavePaused = false;
  DateTime? _lastAutosavedAt;

  bool get _isEditing => widget.existingArticle != null;

  // A new article, or one still a draft, is what autosave keeps safe. Not a
  // published one: autosave writes drafts, and silently turning a
  // published article back into one is never what editing it means.
  bool get _autosaves => !_isEditing || widget.existingArticle!.isDraft;

  bool get _isPublished => _isEditing && !widget.existingArticle!.isDraft;

  UserArticleFormCubit get _cubit => context.read<UserArticleFormCubit>();

  bool get _isOnline => context.read<ConnectivityCubit>().state.isOnline;

  ArticleFormInput get _current => ArticleFormInput(
        authorName: _authorNameController.text,
        title: _titleController.text,
        description: _descriptionController.text,
        content: _contentController.text,
        imageBytes: _pickedImageBytes,
        imageExtension: _pickedImageExtension,
      );

  bool get _changedThisSession {
    final current = _current;
    return !current.hasSameTextAs(_initial) || !current.hasSameImageAs(_initial);
  }

  bool get _hasAutosavableChanges {
    final current = _current;
    return !current.hasSameTextAs(_lastAutosaved) ||
        (_cubit.autosavesImage && !current.hasSameImageAs(_lastAutosaved));
  }

  // Free to leave when there's nothing to decide -- except after autosave
  // wrote something whose net result is no change (edits typed, then
  // undone): that write still has to be undone on the way out.
  bool get _canLeaveFreely =>
      _discardConfirmed || (!_changedThisSession && _lastAutosavedAt == null);

  // A draft may have been saved without a photo, so its existing thumbnail
  // doesn't guarantee there is one.
  bool get _hasCoverImage =>
      _pickedImageBytes != null ||
      (widget.existingArticle?.thumbnailURL.isNotEmpty ?? false);

  // Only an article that's already public is "saved"; a new one or a draft
  // gets published by the same action.
  String _submitLabel(BuildContext context) =>
      _isPublished ? context.l10n.save : context.l10n.publish;

  @override
  void initState() {
    super.initState();
    final article = widget.existingArticle;
    _cubit.edit(article);
    _initial = article == null
        ? const ArticleFormInput.empty()
        : ArticleFormInput.fromArticle(article);
    _lastAutosaved = _initial;
    _authorNameController = TextEditingController(text: _initial.authorName);
    _titleController = TextEditingController(text: _initial.title);
    _descriptionController =
        TextEditingController(text: _initial.description);
    _contentController =
        ArticleBodyEditingController(text: _initial.content);
    // PopScope's canPop below only updates when this State rebuilds -- and
    // typing into a TextFormField doesn't do that on its own (the field
    // repaints itself straight from its controller, without telling its
    // ancestors). Without this, the unsaved-changes check stayed frozen at
    // whatever it was on the last rebuild something else triggered, so
    // typing a change and immediately going back skipped the prompt.
    for (final controller in _allControllers) {
      controller.addListener(_onFieldChanged);
    }
    if (!_isEditing) unawaited(_prefillAuthorName());
    if (_autosaves) {
      WidgetsBinding.instance.addObserver(this);
      // A safety net independent of typing pauses -- dictating, say, may
      // never leave the 3-second gap the debounce waits for.
      _autosaveTimer =
          Timer.periodic(const Duration(seconds: 30), (_) => _autosave());
    }
  }

  List<TextEditingController> get _allControllers => [
        _authorNameController,
        _titleController,
        _descriptionController,
        _contentController,
      ];

  void _onFieldChanged() {
    setState(() {});
    _scheduleAutosave();
  }

  void _scheduleAutosave() {
    if (!_autosaves) return;
    _autosaveDebounce?.cancel();
    _autosaveDebounce = Timer(const Duration(seconds: 3), _autosave);
  }

  // Being backgrounded (switching apps, the screen turning off) is when an
  // edit is most at risk of never reaching a timer tick -- so it's saved on
  // the spot.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      unawaited(_autosave());
    }
  }

  Future<void> _autosave() async {
    _autosaveDebounce?.cancel();
    // Offline, a Firestore write never completes -- nothing to do until
    // the connection is back, when the next tick picks the edit up.
    if (!_autosaves ||
        _autosavePaused ||
        !_hasAutosavableChanges ||
        !_isOnline) {
      return;
    }
    final input = _current;
    final saved = await _cubit.autosave(input);
    if (saved == null || !mounted) return;
    setState(() {
      _lastAutosaved = input;
      _lastAutosavedAt = DateTime.now();
    });
  }

  // One-time suggestion, not a live sync with the account: only offered on
  // a brand-new article, only into a byline the writer hasn't touched, and
  // only when it fits the byline's limit. It becomes part of the starting
  // point rather than an edit -- merely opening "New article" must neither
  // count as a change to discard nor autosave a draft made of just a name.
  Future<void> _prefillAuthorName() async {
    final suggested = await _cubit.suggestedAuthorName();
    if (!mounted ||
        suggested == null ||
        suggested.length > _bylineMaxLength ||
        _authorNameController.text.isNotEmpty) {
      return;
    }
    _initial = _initial.withAuthorName(suggested);
    _lastAutosaved = _lastAutosaved.withAuthorName(suggested);
    _authorNameController.text = suggested;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autosaveDebounce?.cancel();
    _autosaveTimer?.cancel();
    for (final controller in _allControllers) {
      controller.removeListener(_onFieldChanged);
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? picked;
    try {
      // maxWidth/maxHeight make image_picker downscale before returning
      // bytes -- a modern phone photo can be 5-15MB at full resolution,
      // wasted bandwidth and storage for a thumbnail never rendered larger
      // than the screen.
      picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
    } on PlatformException {
      // Photo access denied, or no gallery app to pick from.
      if (mounted) {
        AppToast.show(context,
            message: context.l10n.couldNotOpenPhotos,
            type: AppToastType.error);
      }
      return;
    }
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final extension = picked.name.contains('.')
        ? picked.name.split('.').last.toLowerCase()
        : 'jpg';
    setState(() {
      _pickedImageBytes = bytes;
      _pickedImageExtension = extension;
      _imageError = null;
    });
    _scheduleAutosave();
  }

  // An explicit save needs the server to answer before the overlay can turn
  // into a checkmark; offline it never would, so it's stopped up front with
  // a reason instead of a spinner that never ends.
  bool _ensureOnline() {
    if (_isOnline) return true;
    AppToast.show(context,
        message: context.l10n.offlineCannotSave, type: AppToastType.error);
    return false;
  }

  void _saveDraft() {
    // A draft is explicitly unfinished: none of the form's own validation
    // applies (no minimum lengths, no required photo).
    if (!_ensureOnline()) return;
    _autosaveDebounce?.cancel();
    _cubit.saveDraft(_current);
  }

  void _submit() {
    final formValid = _formKey.currentState!.validate();
    final needsNewImage = !_hasCoverImage;
    setState(() {
      _imageError = needsNewImage ? context.l10n.chooseCoverImage : null;
      // A content error is only visible in Write mode, not in the preview.
      if (!formValid) _previewingContent = false;
    });
    if (!formValid || needsNewImage || !_ensureOnline()) return;
    _autosaveDebounce?.cancel();
    _cubit.publish(_current);
  }

  Future<void> _moveToDrafts() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.moveToDraftsTitle),
        content: Text(dialogContext.l10n.moveToDraftsMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(dialogContext.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(dialogContext.l10n.moveToDrafts),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || !_ensureOnline()) return;
    unawaited(_cubit.saveDraft(_current));
  }

  Future<void> _handlePopAttempt(bool didPop) async {
    if (didPop || _leaving) return;
    if (!_changedThisSession) {
      await _discardAndLeave();
      return;
    }
    // Autosave mustn't write while the writer is deciding -- least of all
    // the very changes they're about to discard.
    _autosavePaused = true;
    _autosaveDebounce?.cancel();
    final action = await showDialog<_FormExitAction>(
      context: context,
      builder: (dialogContext) => _buildExitDialog(dialogContext),
    );
    if (!mounted) return;
    switch (action) {
      case _FormExitAction.discard:
        await _discardAndLeave();
      case _FormExitAction.draft:
        _autosavePaused = false;
        _saveDraft();
      case _FormExitAction.save:
        _autosavePaused = false;
        _submit();
      case _FormExitAction.cancel || null:
        _autosavePaused = false;
        _scheduleAutosave();
    }
  }

  AlertDialog _buildExitDialog(BuildContext dialogContext) {
    final l10n = dialogContext.l10n;
    return AlertDialog(
      // A published article's edits live only in this form until saved.
      // A new article or draft may already be autosaved, so the question
      // is what to do with it, not whether to lose it.
      title: Text(
          _autosaves ? l10n.leaveDraftTitle : l10n.discardChangesTitle),
      content: Text(
          _autosaves ? l10n.leaveDraftMessage : l10n.unsavedChangesMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, _FormExitAction.cancel),
          child: Text(l10n.keepEditing),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pop(dialogContext, _FormExitAction.discard),
          child: Text(l10n.discard),
        ),
        if (_autosaves)
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, _FormExitAction.draft),
            child: Text(l10n.saveDraft),
          ),
        ElevatedButton(
          onPressed: () => Navigator.pop(dialogContext, _FormExitAction.save),
          child: Text(_submitLabel(dialogContext)),
        ),
      ],
    );
  }

  /// Leaves without keeping this session's changes -- undoing whatever
  /// autosave already wrote (see UserArticleFormCubit.discardChanges).
  Future<void> _discardAndLeave() async {
    _leaving = true;
    _autosavePaused = true;
    _autosaveDebounce?.cancel();
    final discard = _cubit.discardChanges();
    if (_isOnline) {
      // Bounded, so a write the server is slow to confirm can't hold the
      // screen hostage; Firestore still applies it on its own.
      await discard.timeout(const Duration(seconds: 5), onTimeout: () {});
    } else {
      unawaited(discard);
    }
    if (!mounted) return;
    setState(() => _discardConfirmed = true);
    Navigator.pop(context);
  }

  Widget _buildImagePicker(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border:
              _imageError != null ? Border.all(color: colorScheme.error) : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: _pickedImageBytes != null
            ? Image.memory(
                _pickedImageBytes!,
                key: ValueKey(_pickedImageBytes.hashCode),
                fit: BoxFit.cover,
              ).animate().fadeIn(duration: 250.ms, curve: Curves.easeOut).scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1, 1),
                  duration: 250.ms,
                  curve: Curves.easeOutBack,
                )
            : (_hasCoverImage
                ? AppImage(url: widget.existingArticle!.thumbnailURL)
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            color: colorScheme.onSurfaceVariant, size: 36),
                        const SizedBox(height: 8),
                        Text(context.l10n.chooseCoverImage,
                            style:
                                TextStyle(color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  )),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return BlocBuilder<UserArticleFormCubit, UserArticleFormState>(
      builder: (context, state) {
        final submitting = state is UserArticleFormSubmitting;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_autosaves)
              TextButton(
                onPressed: submitting ? null : _saveDraft,
                child: Text(context.l10n.saveDraft),
              ),
            if (_isPublished)
              TextButton(
                onPressed: submitting ? null : _moveToDrafts,
                child: Text(context.l10n.moveToDrafts),
              ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              // Filled, unlike the text action next to it -- this is the
              // primary one. The overlay is already the loading indicator,
              // so this only disables the button instead of also spinning.
              child: ElevatedButton(
                onPressed: submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(_submitLabel(context)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canLeaveFreely,
      onPopInvokedWithResult: (didPop, result) => _handlePopAttempt(didPop),
      child: BlocListener<UserArticleFormCubit, UserArticleFormState>(
        listener: (context, state) {
          // The overlay covers the whole real wait: it's up for the entire
          // Submitting state and turns into the checkmark only once Success
          // actually arrives.
          if (state is UserArticleFormSubmitting) {
            _submitOverlay.showLoading(context);
          }
          if (state is UserArticleFormSuccess) {
            unawaited(_submitOverlay.showSuccess().then((_) {
              // true = saved, so callers can tell it apart from a discard.
              if (context.mounted) Navigator.pop(context, true);
            }));
          }
          if (state is UserArticleFormError) {
            _submitOverlay.dismiss();
            AppToast.show(context,
                message: context.l10n.articleSaveFailed,
                type: AppToastType.error);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            // FittedBox, not a plain Text: AppBar's default title style
            // truncates with an ellipsis once the actions eat into its
            // space -- real on narrow phones, longer languages and larger
            // system font sizes. Shrinking to fit keeps it whole.
            title: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                _isEditing ? context.l10n.editArticle : context.l10n.newArticle,
                maxLines: 1,
              ),
            ),
            actions: [_buildActions(context)],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_lastAutosavedAt != null) _AutosaveStatus(_lastAutosavedAt!),
                _SectionLabel(context.l10n.coverPhotoSection),
                _buildImagePicker(context),
                if (_imageError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _imageError!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                _SectionLabel(context.l10n.articleDetailsSection),
                TextFormField(
                  controller: _authorNameController,
                  decoration: InputDecoration(
                      labelText: context.l10n.bylineLabel),
                  inputFormatters: const [
                    Utf16LengthLimitingTextInputFormatter(_bylineMaxLength),
                  ],
                  buildCounter:
                      utf16LengthCounter(_authorNameController, _bylineMaxLength),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.l10n.requiredField;
                    }
                    return value.length > _bylineMaxLength
                        ? context.l10n.maximumCharacters(_bylineMaxLength)
                        : null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: context.l10n.titleLabel),
                  // Reads closer to an actual headline while writing it,
                  // not just another same-sized field in the list.
                  style: Theme.of(context).textTheme.headlineSmall,
                  inputFormatters: const [
                    Utf16LengthLimitingTextInputFormatter(_titleMaxLength),
                  ],
                  buildCounter:
                      utf16LengthCounter(_titleController, _titleMaxLength),
                  validator: (value) {
                    if (value == null || value.trim().length < 3) {
                      return context.l10n.minimumCharacters(3);
                    }
                    return value.length > _titleMaxLength
                        ? context.l10n.maximumCharacters(_titleMaxLength)
                        : null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration:
                      InputDecoration(labelText: context.l10n.summaryLabel),
                  maxLines: 2,
                  inputFormatters: const [
                    Utf16LengthLimitingTextInputFormatter(_summaryMaxLength),
                  ],
                  buildCounter: utf16LengthCounter(
                      _descriptionController, _summaryMaxLength),
                  validator: (value) {
                    if (value == null || value.trim().length < 10) {
                      return context.l10n.minimumCharacters(10);
                    }
                    return value.length > _summaryMaxLength
                        ? context.l10n.maximumCharacters(_summaryMaxLength)
                        : null;
                  },
                ),
                const SizedBox(height: 20),
                ArticleContentField(
                  controller: _contentController,
                  isPreviewing: _previewingContent,
                  onPreviewingChanged: (previewing) {
                    FocusScope.of(context).unfocus();
                    setState(() => _previewingContent = previewing);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Draft saved · 2 min ago", shown once autosave has actually persisted
/// something -- the one visible sign that the silent background saving is
/// happening at all.
class _AutosaveStatus extends StatelessWidget {
  final DateTime savedAt;

  const _AutosaveStatus(this.savedAt);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_done_outlined, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '${context.l10n.draftAutosaved} · '
            '${relativeTimeOrDate(savedAt, context.l10n, showDateAfter: const Duration(days: 1))}',
            style: theme.textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// A small uppercase heading grouping the fields below it, so the form
/// reads as distinct parts ("what it looks like" vs. "what it says")
/// instead of one long flat list of fields.
class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(letterSpacing: 1.2),
      ),
    );
  }
}
