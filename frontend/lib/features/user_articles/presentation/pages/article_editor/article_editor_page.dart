import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/config/theme/app_theme_extension.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/article_editor/article_editor_bloc.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/article_editor/article_editor_event.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/article_editor/article_editor_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/services/thumbnail_picker_service.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/widgets/primary_button.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/widgets/thumbnail_picker_tile.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class ArticleEditorPage extends StatefulWidget {
  const ArticleEditorPage({this.editing, super.key});

  final UserArticleEntity? editing;

  @override
  State<ArticleEditorPage> createState() => _ArticleEditorPageState();
}

class _ArticleEditorPageState extends State<ArticleEditorPage> {
  late final ArticleEditorBloc _bloc;
  late final ThumbnailPickerService _picker;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _picker = sl<ThumbnailPickerService>();
    _bloc = ArticleEditorBloc(
      publishArticle: sl(),
      updateArticle: sl(),
      uploadThumbnail: sl(),
      authSession: sl(),
      editing: widget.editing,
    );

    final initial = _bloc.state;
    _titleController.text = initial.title;
    _descriptionController.text = initial.description;
    _contentController.text = initial.content;
    _tagsController.text = initial.tags.join(', ');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<ArticleEditorBloc, ArticleEditorState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == EditorStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.isEditing ? 'Article updated' : 'Article published',
                ),
              ),
            );
            context.pop();
          }
          if (state.status == EditorStatus.failure && state.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_failureMessage(state.failure!)),
                backgroundColor: context.appTheme.danger,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title:
                Text(widget.editing == null ? 'New Article' : 'Edit Article'),
            elevation: 0,
          ),
          body: BlocBuilder<ArticleEditorBloc, ArticleEditorState>(
            builder: _buildForm,
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, ArticleEditorState state) {
    final theme = context.appTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(theme.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ThumbnailPickerTile(
            onPick: _pickThumbnail,
            remoteURL: state.thumbnailURL,
            pendingBytes: state.pendingBytes,
          ),
          SizedBox(height: theme.spacing.lg),
          _Field(
            controller: _titleController,
            label: 'Title',
            hint: 'A short, catchy title (min 5 chars)',
            onChanged: (v) => _bloc.add(ArticleEditorEvent.titleChanged(v)),
          ),
          SizedBox(height: theme.spacing.md),
          _Field(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Optional teaser (max 280 chars)',
            maxLines: 2,
            onChanged: (v) =>
                _bloc.add(ArticleEditorEvent.descriptionChanged(v)),
          ),
          SizedBox(height: theme.spacing.md),
          _Field(
            controller: _contentController,
            label: 'Content',
            hint: 'Write your article (min 50 chars)',
            maxLines: 10,
            onChanged: (v) => _bloc.add(ArticleEditorEvent.contentChanged(v)),
          ),
          SizedBox(height: theme.spacing.md),
          _Field(
            controller: _tagsController,
            label: 'Tags',
            hint: 'Comma-separated, up to 5',
            onChanged: (v) => _bloc.add(
              ArticleEditorEvent.tagsChanged(_parseTags(v)),
            ),
          ),
          SizedBox(height: theme.spacing.xl),
          PrimaryButton(
            label: state.isEditing ? 'Save changes' : 'Publish',
            icon: Icons.check,
            isLoading: state.status == EditorStatus.submitting,
            onPressed: state.canSubmit
                ? () => _bloc.add(const ArticleEditorEvent.submitted())
                : null,
          ),
          if (!state.canSubmit && state.status != EditorStatus.submitting) ...[
            SizedBox(height: theme.spacing.sm),
            Text(
              _requirementsHint(state),
              style: TextStyle(fontSize: 12, color: theme.onSurfaceMuted),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickThumbnail() async {
    final picked = await _picker.pickImage();
    if (picked == null) return;
    _bloc.add(
      ArticleEditorEvent.thumbnailPicked(
        fileName: picked.fileName,
        bytes: picked.bytes,
        contentType: picked.contentType,
      ),
    );
  }

  List<String> _parseTags(String raw) {
    return raw
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  String _requirementsHint(ArticleEditorState state) {
    final missing = <String>[];
    if (state.title.length < 5) missing.add('title ≥ 5 chars');
    if (state.content.length < 50) missing.add('content ≥ 50 chars');
    if (state.thumbnailURL.isEmpty) missing.add('thumbnail');
    return 'Missing: ${missing.join(", ")}';
  }

  String _failureMessage(AppFailure failure) {
    return failure.when(
      network: (m, _) => m ?? 'Network error',
      cache: (m) => m ?? 'Cache error',
      validation: (f, r) => '$f: $r',
      auth: (m) => m ?? 'Please sign in',
      unknown: (_, __) => 'Something went wrong',
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: theme.onSurface,
          ),
        ),
        SizedBox(height: theme.spacing.xs),
        Semantics(
          label: label,
          textField: true,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: theme.surfaceMuted,
              border: OutlineInputBorder(
                borderRadius: theme.radii.smRadius,
                borderSide: BorderSide(color: theme.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: theme.radii.smRadius,
                borderSide: BorderSide(color: theme.divider),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
