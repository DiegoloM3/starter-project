import 'package:flutter/material.dart';

typedef LengthValidator = String? Function(
  String? value, {
  required int min,
  required int max,
  required String label,
});

class PublishForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController contentController;
  final LengthValidator validateLength;

  const PublishForm({
    Key? key,
    required this.titleController,
    required this.descriptionController,
    required this.contentController,
    required this.validateLength,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Title'),
          validator: (v) =>
              validateLength(v, min: 1, max: 120, label: 'Title'),
          maxLength: 120,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(labelText: 'Description'),
          validator: (v) =>
              validateLength(v, min: 1, max: 280, label: 'Description'),
          maxLength: 280,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: contentController,
          decoration: const InputDecoration(labelText: 'Content'),
          validator: (v) =>
              validateLength(v, min: 1, max: 5000, label: 'Content'),
          maxLength: 5000,
          minLines: 6,
          maxLines: 12,
        ),
      ],
    );
  }
}
