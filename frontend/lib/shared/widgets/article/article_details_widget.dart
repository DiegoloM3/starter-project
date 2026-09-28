
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/config/theme/global_themes.dart';
import 'package:news_app_clean_architecture/shared/widgets/feedback/press_loading_indicator_widget.dart';
import 'package:news_app_clean_architecture/shared/widgets/interaction/confirm_action_sheet.dart';

class ArticleDetailsWidget extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String description;
  final String dateText;
  final bool isSaved;
  final VoidCallback? onSave;
  final VoidCallback? onDelete;

  const ArticleDetailsWidget({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.dateText,
    this.isSaved = false,
    this.onSave,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      floatingActionButton: _buildActionButton(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(Icons.arrow_back, color: colorScheme.primary),
      ),
      title: Text('Artículo', style: GlobalTheme.masthead(colorScheme, fontSize: 20)),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: GlobalTheme.kRule),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTitleAndDate(context),
          _buildImage(context),
          _buildDescription(context),
        ],
      ),
    );
  }

  Widget _buildTitleAndDate(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: colorScheme.onSurface)),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: colorScheme.onSurface.withValues(alpha: 0.6)),
              const SizedBox(width: 4),
              Text(dateText, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: 250,
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(border: Border.all(color: GlobalTheme.kInk, width: 1)),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildImagePlaceholder(
          context,
          child: PressLoadingIndicatorWidget(color: Theme.of(context).colorScheme.secondary),
        ),
        errorWidget: (context, url, error) => _buildImagePlaceholder(
          context,
          child: Icon(Icons.broken_image, color: GlobalTheme.kInkMuted),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context, {required Widget child}) {
    return Container(
      color: GlobalTheme.kRule,
      child: Center(child: child),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Text(description, style: Theme.of(context).textTheme.bodyLarge),
    );
  }

  Widget? _buildActionButton(BuildContext context) {
    if (onDelete != null) return _buildDeleteButton();
    if (onSave != null) return _buildSaveButton();
    return null;
  }

  Widget _buildSaveButton() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: GlobalTheme.kInk, width: 1.5)),
      child: FloatingActionButton(
        onPressed: onSave,
        child: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border, color: Colors.white),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
           decoration: BoxDecoration(border: Border.all(color: GlobalTheme.kInk, width: 1.5)),
          child: FloatingActionButton(
            backgroundColor: colorScheme.secondary,
            onPressed: () => _confirmDelete(context),
            child: Icon(Icons.delete_outline, color: colorScheme.onSecondary),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    ConfirmActionSheet.show(
      context,
      title: '¿Borrar artículo?',
      message: 'Esta acción no se puede deshacer.',
      confirmLabel: 'Borrar',
      confirmColor: colorScheme.secondary,
      onConfirm: () {
        context.pop();
        onDelete!.call();
      },
    );
  }
}