import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/core/constants/app_colors.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/storage_repository.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
class PublishArticlePage extends StatefulWidget {
  const PublishArticlePage({Key? key}) : super(key: key);

  @override
  State<PublishArticlePage> createState() => _PublishArticlePageState();
}

class _PublishArticlePageState extends State<PublishArticlePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RemoteArticlesBloc, RemoteArticlesState>(
      listener: (context, state) {
        if (state is PostArticleSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Noticia publicada con éxito!'), backgroundColor: AppColors.success),
          );
          Navigator.pop(context);
        } else if (state is PostArticleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.error?.message ?? "Fallo al publicar"}'), backgroundColor: AppColors.highlight),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Ionicons.close_outline, color: AppColors.primary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Publicar Noticia'),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state is PostArticleLoading ? null : _onPostPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      shadowColor: AppColors.primary.withOpacity(0.4),
                    ),
                    child: state is PostArticleLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text('ENVIAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  );
                },
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTitleInput(),
                const SizedBox(height: 20),
                _buildImagePicker(),
                const SizedBox(height: 20),
                _buildContentInput(),
                const SizedBox(height: 20),
                _buildMarkdownTip(),
                const SizedBox(height: 40), // Bottom breathing room
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onPostPressed() async {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa el título y el contenido.')),
      );
      return;
    }

    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes estar autenticado para publicar.')),
      );
      return;
    }

    try {
      String imageUrl = 'https://images.unsplash.com/photo-1504711432869-efd597cdd042?auto=format&fit=crop&q=80&w=1000'; // Default
      
      if (_selectedImage != null) {
        // Real upload to Firebase Storage using segregated repository
        imageUrl = await sl<StorageRepository>().uploadImage(_selectedImage!, authState.user.uid);
      }

      final article = ArticleEntity(
        author: authState.user.displayName ?? 'Agente Symmetry',
        title: _titleController.text.trim(),
        description: _contentController.text.trim().split('.').first,
        content: _contentController.text.trim(),
        publishedAt: DateTime.now().toIso8601String(),
        url: 'symmetry://article/${DateTime.now().millisecondsSinceEpoch}',
        urlToImage: imageUrl,
      );

      context.read<RemoteArticlesBloc>().add(PostArticle(article));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir imagen: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Widget _buildTitleInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: TextField(
        controller: _titleController,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        maxLines: null,
        decoration: const InputDecoration(
          hintText: 'Titular de la noticia...',
          hintStyle: TextStyle(color: AppColors.textMuted),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textMuted.withOpacity(0.2)),
        image: _selectedImage != null ? DecorationImage(
          image: FileImage(_selectedImage!),
          fit: BoxFit.cover,
        ) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_selectedImage == null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle
                  ),
                  child: const Icon(Ionicons.image_outline, color: AppColors.primary, size: 28),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Añadir imagen de portada',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Ionicons.camera_outline, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text('Cambiar imagen', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al seleccionar imagen')),
      );
    }
  }

  Widget _buildContentInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.05)),
      ),
      child: TextField(
        controller: _contentController,
        style: const TextStyle(fontSize: 16, color: AppColors.textBody, height: 1.5),
        maxLines: 12,
        decoration: const InputDecoration(
          hintText: 'Escribe el contenido aquí. Soporta Markdown...',
          hintStyle: TextStyle(color: AppColors.textMuted),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildMarkdownTip() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Ionicons.information_circle_outline, size: 16, color: AppColors.primary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Puedes usar # para títulos y ** para negrita.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
