import 'package:flutter/material.dart';

class NoteEditor extends StatelessWidget {
  const NoteEditor({
    required this.controller,
    required this.onSubmit,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Note',
              hintText: 'Write a note',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: onSubmit,
          child: const Text('Add note'),
        ),
      ],
    );
  }
}
