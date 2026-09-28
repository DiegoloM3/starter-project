import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/config/theme/global_themes.dart';
import 'package:news_app_clean_architecture/di/service_locator.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/upload_article/upload_user_article_bloc.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/widgets/image_picker_field_widget.dart';
import 'package:news_app_clean_architecture/shared/widgets/feedback/press_loading_indicator_widget.dart';

class UploadUserArticleScreen extends StatefulWidget {
  const UploadUserArticleScreen({super.key});

  @override
  State<UploadUserArticleScreen> createState() => _UploadUserArticleScreenState();
}

class _UploadUserArticleScreenState extends State<UploadUserArticleScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  File? _image;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onFormChanged);
    _contentController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onFormChanged() => setState(() {});

  bool get _isFormValid =>
      _titleController.text.isNotEmpty && _contentController.text.isNotEmpty && _image != null;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UploadUserArticleBloc>(),
      child: BlocConsumer<UploadUserArticleBloc, UploadUserArticleState>(
        listener: _handleStateChange,
        builder: (context, state) {
          return Scaffold(
            appBar: _buildAppBar(context),
            body: _buildForm(context),
            bottomNavigationBar: _buildSubmitBar(context, state),
          );
        },
      ),
    );
  }



  void _handleStateChange(BuildContext context, UploadUserArticleState state) {
    if (state is UploadUserArticleSuccess) {
      context.pop();
    }
    if (state is UploadUserArticleError) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
    }
  }



  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(Icons.arrow_back, color: colorScheme.primary),
      ),
      title: Text('Nuevo artículo', style: GlobalTheme.masthead(colorScheme, fontSize: 18)),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: GlobalTheme.kRule),
      ),
    );
  }

  

  Widget _buildForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleField(context),
          const SizedBox(height: 12),
          Divider(height: 1, color: GlobalTheme.kRule),
          const SizedBox(height: 20),
          _buildImagePicker(),
          const SizedBox(height: 20),
          _buildContentField(context),
        ],
      ),
    );
  }

  Widget _buildTitleField(BuildContext context) {
    return TextField(
      controller: _titleController,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: const InputDecoration(
        hintText: 'Escribe tu título aquí...',
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildImagePicker() {
    return ImagePickerFieldWidget(
      selectedImage: _image,
      onImagePicked: (file) => setState(() => _image = file),
    );
  }

  Widget _buildContentField(BuildContext context) {
    return Expanded(
      child: TextField(
        controller: _contentController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: const InputDecoration(
          hintText: 'Escribe tu artículo aquí...',
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  

  Widget _buildSubmitBar(BuildContext context, UploadUserArticleState state) {
    final isLoading = state is UploadUserArticleLoading;
    final canSubmit = _isFormValid && !isLoading;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: canSubmit ? () => _submit(context) : null,
            style: _buildSubmitButtonStyle(context),
            child: _buildSubmitButtonContent(context, isLoading),
          ),
        ),
      ),
    );
  }

  ButtonStyle _buildSubmitButtonStyle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = _isFormValid ? colorScheme.secondary : GlobalTheme.kRule;
    final foregroundColor = _isFormValid ? colorScheme.onSecondary : GlobalTheme.kInkMuted;

    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: backgroundColor,
      disabledForegroundColor: foregroundColor,
    );
  }

  Widget _buildSubmitButtonContent(BuildContext context, bool isLoading) {
    final colorScheme = Theme.of(context).colorScheme;
    if (isLoading) {
      return PressLoadingIndicatorWidget(color: colorScheme.onSecondary, size: 8);
    }
    final contentColor = _isFormValid ? colorScheme.onSecondary : GlobalTheme.kInkMuted;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.approval_outlined, size: 18, color: contentColor),
        const SizedBox(width: 10),
        const Text('PUBLICAR ARTÍCULO'),
      ],
    );
  }

 

  void _submit(BuildContext context) {
    context.read<UploadUserArticleBloc>().add(SubmitUserArticle(
          title: _titleController.text,
          content: _contentController.text,
          image: _image!,
        ));
  }
}