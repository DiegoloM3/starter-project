import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/comment.dart';
import '../../domain/params/add_comment_params.dart';
import '../bloc/comments/comments_cubit.dart';
import '../bloc/comments/comments_state.dart';
import 'comment_tile.dart';

/// Comments below an article: a field to write one and the list, newest first.
/// It is meant to be placed inside a scrollable screen.
class CommentsSection extends StatefulWidget {
  final String? currentUserId;
  final ValueChanged<String> onAuthorTap;

  const CommentsSection({super.key, required this.currentUserId, required this.onAuthorTap});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommentsCubit, CommentsState>(
      listenWhen: (previous, current) => current.failedAction != null && previous.failedAction != current.failedAction,
      listener: _showFailure,
      builder:
          (context, state) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'COMENTARIOS (${state.comments.length})',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.5),
              ),
              const SizedBox(height: 12),
              _buildTextField(state),
              const SizedBox(height: 8),
              ..._buildComments(state),
            ],
          ),
    );
  }

  Widget _buildTextField(CommentsState state) {
    final errorText = state.validationErrors.map(_messageFor).firstOrNull;
    return TextField(
      controller: _textController,
      maxLines: null,
      maxLength: CommentLimits.textMaxLength,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: 'Escribe un comentario…',
        errorText: errorText,
        counterText: '',
        suffixIcon:
            state.isSending
                ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                )
                : IconButton(tooltip: 'Publicar comentario', icon: const Icon(Icons.send), onPressed: _send),
      ),
    );
  }

  List<Widget> _buildComments(CommentsState state) {
    if (state.comments.isNotEmpty) {
      return [
        for (final comment in state.comments) ...[
          CommentTile(
            comment: comment,
            onAuthorTap: () => widget.onAuthorTap(comment.authorId),
            onDelete: _deleteActionFor(comment),
          ),
          const Divider(),
        ],
      ];
    }
    return switch (state.status) {
      CommentsStatus.initial || CommentsStatus.loading => const [
        Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
      ],
      CommentsStatus.failure => [
        const SizedBox(height: 16),
        const Text('No se pudieron cargar los comentarios.', textAlign: TextAlign.center),
        TextButton(onPressed: context.read<CommentsCubit>().load, child: const Text('Reintentar')),
      ],
      CommentsStatus.success => const [
        Padding(padding: EdgeInsets.all(24), child: Text('Sé el primero en comentar.', textAlign: TextAlign.center)),
      ],
    };
  }

  String _messageFor(CommentValidationError error) => switch (error) {
    CommentValidationError.textEmpty => 'Escribe un comentario.',
    CommentValidationError.textTooLong => 'Máximo ${CommentLimits.textMaxLength} caracteres.',
  };

  VoidCallback? _deleteActionFor(CommentEntity comment) {
    if (!comment.isAuthoredBy(widget.currentUserId)) return null;
    return () => _confirmDelete(comment);
  }

  Future<void> _send() async {
    final wasAdded = await context.read<CommentsCubit>().add(_textController.text);
    if (wasAdded) {
      _textController.clear();
      if (mounted) FocusScope.of(context).unfocus();
    }
  }

  Future<void> _confirmDelete(CommentEntity comment) async {
    final commentsCubit = context.read<CommentsCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('¿Eliminar comentario?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancelar')),
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Eliminar')),
            ],
          ),
    );
    if (confirmed == true) commentsCubit.delete(comment);
  }

  void _showFailure(BuildContext context, CommentsState state) {
    final message =
        state.failedAction == CommentsAction.add
            ? 'No se pudo publicar el comentario. Inténtalo de nuevo.'
            : 'No se pudo eliminar el comentario. Inténtalo de nuevo.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
