import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/article.dart';
import '../../bloc/article/remote/remote_article_bloc.dart';
import '../../bloc/article/remote/remote_article_event.dart';

class CreateArticlePage extends StatefulWidget {
  const CreateArticlePage({Key? key}) : super(key: key);

  @override
  State<CreateArticlePage> createState() => _CreateArticlePageState();
}

class _CreateArticlePageState extends State<CreateArticlePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageController = TextEditingController(
    text: 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=1200',
  );
  bool _isPreviewing = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f0e8),
      appBar: AppBar(
        backgroundColor: const Color(0xfff4f0e8),
        title: const Text('NEWSROOM', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w800)),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        actions: [
          TextButton(
            onPressed: _togglePreview,
            child: Text(_isPreviewing ? 'EDIT' : 'PREVIEW'),
          ),
        ],
      ),
      body: _isPreviewing ? _buildPreview() : _buildEditor(),
      bottomNavigationBar: _buildPublishBar(),
    );
  }

  Widget _buildEditor() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
        children: [
          const Text('YOUR BYLINE', style: TextStyle(fontSize: 12, letterSpacing: 2, color: Color(0xffb24a2f))),
          const SizedBox(height: 8),
          const Text('Shape the story.', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, height: .95)),
          const SizedBox(height: 26),
          _field(_titleController, 'Headline', 'Give readers a reason to stop.', 2),
          _field(_descriptionController, 'Standfirst', 'The one sentence that earns the next paragraph.', 3),
          _field(_contentController, 'The story', 'Write what matters. Keep the signal.', 12),
          _field(_imageController, 'Thumbnail URL', 'Paste a public image URL for now.', 1, keyboardType: TextInputType.url),
          const SizedBox(height: 16),
          _imagePreview(),
        ],
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, String hint, int lines, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        minLines: lines,
        maxLines: lines == 1 ? 1 : null,
        keyboardType: keyboardType,
        validator: (value) => value == null || value.trim().isEmpty ? 'This field is required' : null,
        decoration: InputDecoration(labelText: label, hintText: hint, alignLabelWithHint: true),
      ),
    );
  }

  Widget _imagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 150,
        child: Image.network(
          _imageController.text,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xffded7ca),
            alignment: Alignment.center,
            child: const Text('Preview unavailable'),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
      children: [
        const Text('PREVIEW / 01', style: TextStyle(fontSize: 12, letterSpacing: 2, color: Color(0xffb24a2f))),
        const SizedBox(height: 16),
        Text(_titleController.text.isEmpty ? 'Untitled story' : _titleController.text, style: const TextStyle(fontSize: 36, height: 1, fontWeight: FontWeight.w900)),
        const SizedBox(height: 18),
        _imagePreview(),
        const SizedBox(height: 18),
        Text(_descriptionController.text, style: const TextStyle(fontSize: 18, height: 1.35, fontWeight: FontWeight.w600)),
        const SizedBox(height: 18),
        Text(_contentController.text, style: const TextStyle(fontSize: 16, height: 1.55)),
      ],
    );
  }

  Widget _buildPublishBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 14),
        child: SizedBox(
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _publish,
            icon: const Icon(Icons.send_rounded),
            label: const Text('PUBLISH TO THE FRONT PAGE'),
          ),
        ),
      ),
    );
  }

  void _togglePreview() {
    setState(() => _isPreviewing = !_isPreviewing);
  }

  void _publish() {
    if (!_formKey.currentState!.validate()) {
      setState(() => _isPreviewing = false);
      return;
    }

    final article = ArticleEntity(
      id: DateTime.now().millisecondsSinceEpoch,
      author: 'Staff writer',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      content: _contentController.text.trim(),
      urlToImage: _imageController.text.trim(),
      publishedAt: _formatDate(DateTime.now()),
    );

    context.read<RemoteArticlesBloc>().add(PublishArticle(article));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Published. Your story is live.')));
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
