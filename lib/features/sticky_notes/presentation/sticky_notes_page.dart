import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/note_editor.dart';
import 'sticky_notes_view_model.dart';

class StickyNotesPage extends StatefulWidget {
  const StickyNotesPage({super.key});

  @override
  State<StickyNotesPage> createState() => _StickyNotesPageState();
}

class _StickyNotesPageState extends State<StickyNotesPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StickyNotesViewModel>();
    final showError = viewModel.errorMessage != null &&
        viewModel.status != StickyNotesStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Sticky Notes')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NoteEditor(
              controller: _controller,
              onSubmit: () async {
                final viewModel = context.read<StickyNotesViewModel>();
                await viewModel.createNote(_controller.text);
                if (!mounted) {
                  return;
                }
                if (viewModel.status ==
                    StickyNotesStatus.ready) {
                  _controller.clear();
                }
              },
            ),
            if (showError) ...[
              const SizedBox(height: 12),
              Text(
                viewModel.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            Expanded(
              child: viewModel.status == StickyNotesStatus.loading
                  ? const Center(child: CircularProgressIndicator())
                  : viewModel.notes.isEmpty
                      ? const Center(child: Text('No notes yet.'))
                      : ListView.separated(
                          itemCount: viewModel.notes.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) => ListTile(
                            title: Text(viewModel.notes[index].content),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
