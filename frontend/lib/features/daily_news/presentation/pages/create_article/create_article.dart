import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../injection_container.dart';
import '../../bloc/article/create/create_article_cubit.dart';
import '../../bloc/article/create/create_article_state.dart';

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
  String? _imagePath;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateArticleCubit>(
      create: (_) => sl<CreateArticleCubit>(),
      child: Builder(
        builder: (innerContext) => Scaffold(
          appBar: _buildAppBar(innerContext),
          body: BlocListener<CreateArticleCubit, CreateArticleState>(
            listener: (context, state) {
              if (state is CreateArticleSuccess) {
                Navigator.pop(context);
              }
            },
            child: _buildBody(innerContext),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pop(context),
        child: const Icon(Ionicons.chevron_back, color: Colors.black),
      ),
      title: const Text(
        'Create Article',
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 6,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _onPickImage,
              icon: const Icon(Icons.image_outlined),
              label: Text(
                _imagePath == null
                    ? 'Select image (optional)'
                    : 'Image selected',
              ),
            ),
            if (_imagePath != null) ...[
              const SizedBox(height: 8),
              Text(
                _imagePath!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _onSubmit(context),
                child: const Text('Save article'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<CreateArticleCubit>().submit(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          content: _contentController.text.trim().isEmpty
              ? null
              : _contentController.text.trim(),
          imagePath: _imagePath,
        );
  }

  Future<void> _onPickImage() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery);
      if (file == null || !mounted) return;

      setState(() {
        _imagePath = file.path;
      });
    } on PlatformException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open image picker. Restart the app and try again.'),
        ),
      );
    }
  }
}
