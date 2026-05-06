import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../api/api_request.dart';
import '../api/api_response.dart';
import '../l10n/app_localizations.dart';

class NotesScreen extends StatefulWidget {
  final int cropId;
  final String cropName;

  const NotesScreen({super.key, required this.cropId, required this.cropName});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final CropNoteService _noteService = CropNoteService();
  List<CropNoteResponse> _notes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await _noteService.listNotes(widget.cropId);
      if (response.status) {
        setState(() => _notes = response.data);
      } else {
        setState(() => _error = AppLocalizations.of(context)!.failedToLoadNotes);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ----------------------------------------------------------------------
  // Modal bottom sheet with FIXED date picker (no form rebuild)
  // and correct API handling for create/update (no .status check)
  // ----------------------------------------------------------------------
  void _showNoteForm({CropNoteResponse? existingNote}) {
    final isEditing = existingNote != null;
    final titleCtrl = TextEditingController(text: existingNote?.title ?? '');
    final descCtrl = TextEditingController(text: existingNote?.description ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          // Local mutable date – will be updated without closing the sheet
          DateTime selectedDate = existingNote != null
              ? DateTime.parse(existingNote.noteDate)
              : DateTime.now();

          return StatefulBuilder(
            builder: (context, setState) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Drag handle + close button (unchanged)
                  Padding(
                    padding: const EdgeInsets.only(top: 12, right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        Text(
                          isEditing
                              ? AppLocalizations.of(context)!.editNoteTitle
                              : AppLocalizations.of(context)!.addNoteTitle,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Title field
                        TextFormField(
                          controller: titleCtrl,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.titleLabel,
                            hintText: AppLocalizations.of(context)!.titleHint,
                            prefixIcon: const Icon(Icons.title, color: Color(0xFF4CAF50)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Description field
                        TextFormField(
                          controller: descCtrl,
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.descriptionLabel,
                            hintText: AppLocalizations.of(context)!.descriptionHint,
                            prefixIcon: const Icon(Icons.description, color: Color(0xFF4CAF50)),
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Date picker (now works without closing the form)
                        TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: _formatDateForDisplay(context, selectedDate),
                          ),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.noteDateLabel,
                            prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF4CAF50)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                            ),
                          ),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                              builder: (context, child) => Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: const ColorScheme.light(primary: Color(0xFF4CAF50)),
                                ),
                                child: child!,
                              ),
                            );
                            if (picked != null && mounted) {
                              // Update only the local date, form stays open
                              setState(() => selectedDate = picked);
                            }
                          },
                        ),
                        const SizedBox(height: 32),
                        // Submit button – correctly handles create/update responses
                        ElevatedButton(
                          onPressed: () async {
                            if (titleCtrl.text.trim().isEmpty ||
                                descCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context)!.pleaseFillAllFields)),
                              );
                              return;
                            }
                            final dateStr = selectedDate.toIso8601String().split('T').first;

                            // Close bottom sheet before network call
                            Navigator.pop(context);

                            try {
                              if (!isEditing) {
                                final request = CropNoteCreateRequest(
                                  crop: widget.cropId,
                                  title: titleCtrl.text.trim(),
                                  description: descCtrl.text.trim(),
                                  noteDate: dateStr,
                                );
                                await _noteService.createNote(request);
                                // Success – no status to check, just show message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(AppLocalizations.of(context)!.noteCreatedSuccess)),
                                );
                              } else {
                                final request = CropNoteUpdateRequest(
                                  id: existingNote.id,
                                  title: titleCtrl.text.trim(),
                                  description: descCtrl.text.trim(),
                                  noteDate: dateStr,
                                );
                                await _noteService.updateNote(request);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(AppLocalizations.of(context)!.noteUpdatedSuccess)),
                                );
                              }
                              // Refresh the list after successful operation
                              _loadNotes();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${AppLocalizations.of(context)!.errorPrefix}$e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 2,
                          ),
                          child: Text(
                            isEditing
                                ? AppLocalizations.of(context)!.updateNoteButton
                                : AppLocalizations.of(context)!.createNoteButton,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDateForDisplay(BuildContext context, DateTime date) {
    final months = [
      AppLocalizations.of(context)!.monthJanuary,
      AppLocalizations.of(context)!.monthFebruary,
      AppLocalizations.of(context)!.monthMarch,
      AppLocalizations.of(context)!.monthApril,
      AppLocalizations.of(context)!.monthMay,
      AppLocalizations.of(context)!.monthJune,
      AppLocalizations.of(context)!.monthJuly,
      AppLocalizations.of(context)!.monthAugust,
      AppLocalizations.of(context)!.monthSeptember,
      AppLocalizations.of(context)!.monthOctober,
      AppLocalizations.of(context)!.monthNovember,
      AppLocalizations.of(context)!.monthDecember,
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _addNote() async => _showNoteForm();
  Future<void> _editNote(CropNoteResponse note) async => _showNoteForm(existingNote: note);

  Future<void> _deleteNote(CropNoteResponse note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppLocalizations.of(context)!.deleteNoteTitle),
        content: Text(AppLocalizations.of(context)!.deleteConfirmationMessage(note.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.deletingNote), duration: const Duration(seconds: 1)),
    );
    try {
      final deleteResponse = await _noteService.deleteNote(note.id);
      if (deleteResponse.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(deleteResponse.message)),
        );
        _loadNotes();
      } else {
        throw Exception(deleteResponse.message);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.errorPrefix}$e'), backgroundColor: Colors.red),
      );
    }
  }

  String _formatShortDate(BuildContext context, String dateStr) {
    final date = DateTime.parse(dateStr);
    final months = [
      AppLocalizations.of(context)!.monthJan,
      AppLocalizations.of(context)!.monthFeb,
      AppLocalizations.of(context)!.monthMar,
      AppLocalizations.of(context)!.monthApr,
      AppLocalizations.of(context)!.monthMay,
      AppLocalizations.of(context)!.monthJun,
      AppLocalizations.of(context)!.monthJul,
      AppLocalizations.of(context)!.monthAug,
      AppLocalizations.of(context)!.monthSep,
      AppLocalizations.of(context)!.monthOct,
      AppLocalizations.of(context)!.monthNov,
      AppLocalizations.of(context)!.monthDec,
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.notesForCrop(widget.cropName),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNotes,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      )
          : _notes.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: () async => _loadNotes(),
        color: const Color(0xFF4CAF50),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _notes.length,
          itemBuilder: (context, index) => _buildNoteCard(_notes[index]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildNoteCard(CropNoteResponse note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _editNote(note),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey.shade50],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.sticky_note_2, color: Color(0xFF4CAF50), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 12, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Text(
                                _formatShortDate(context, note.noteDate),
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.black, size: 22),
                          onPressed: () => _editNote(note),
                          tooltip: AppLocalizations.of(context)!.editTooltip,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.black, size: 22),
                          onPressed: () => _deleteNote(note),
                          tooltip: AppLocalizations.of(context)!.deleteTooltip,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  note.description,
                  style: TextStyle(fontSize: 14, height: 1.4, color: Colors.grey[800]),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.note_add, size: 64, color: Color(0xFF4CAF50)),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.noNotesYet,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.tapToAddNoteHint,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }
}