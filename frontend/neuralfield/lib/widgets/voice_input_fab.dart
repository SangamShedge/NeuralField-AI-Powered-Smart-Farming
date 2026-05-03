// lib/widgets/voice_input_fab.dart
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../api/api_service.dart';
import '../api/api_request.dart';
import '../api/api_response.dart';
import '../services/cache_manager.dart';   // ✅ added

// ---------------------------------------------------------------------
// Supported languages and localizations (unchanged)
// ---------------------------------------------------------------------
enum AppLanguage { english, hindi, marathi }

extension AppLanguageExtension on AppLanguage {
  String get displayName {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.hindi:
        return 'हिंदी';
      case AppLanguage.marathi:
        return 'मराठी';
    }
  }

  String get ttsCode {
    switch (this) {
      case AppLanguage.english:
        return 'en-US';
      case AppLanguage.hindi:
        return 'hi-IN';
      case AppLanguage.marathi:
        return 'mr-IN';
    }
  }

  String get promptInstruction {
    switch (this) {
      case AppLanguage.english:
        return 'Please respond in English.';
      case AppLanguage.hindi:
        return 'कृपया हिंदी में जवाब दें।';
      case AppLanguage.marathi:
        return 'कृपया मराठीत उत्तर द्या.';
    }
  }
}

// Localization map (unchanged)
final Map<String, Map<AppLanguage, String>> localizations = {
  'typing': {
    AppLanguage.english: "NeuralField AI is typing...",
    AppLanguage.hindi: "न्यूरलफील्ड एआई टाइप कर रहा है...",
    AppLanguage.marathi: "न्यूरलफील्ड एआय टाइप करत आहे...",
  },
  'thinking': {
    AppLanguage.english: "Thinking...",
    AppLanguage.hindi: "सोच रहा हूँ...",
    AppLanguage.marathi: "विचार करत आहे...",
  },
  'error_unknown': {
    AppLanguage.english: "❌ Error: Unknown error",
    AppLanguage.hindi: "❌ त्रुटि: अज्ञात त्रुटि",
    AppLanguage.marathi: "❌ त्रुटी: अज्ञात त्रुटी",
  },
  'connection_failed': {
    AppLanguage.english: "❌ Connection failed. Please check your internet.",
    AppLanguage.hindi: "❌ कनेक्शन विफल। कृपया अपना इंटरनेट जांचें।",
    AppLanguage.marathi: "❌ कनेक्शन अयशस्वी. कृपया तुमचे इंटरनेट तपासा.",
  },
  'mic_permission_required': {
    AppLanguage.english: "Microphone permission is required",
    AppLanguage.hindi: "माइक्रोफोन अनुमति आवश्यक है",
    AppLanguage.marathi: "मायक्रोफोन परवानगी आवश्यक आहे",
  },
  'mic_permission_denied': {
    AppLanguage.english: "Microphone permission denied",
    AppLanguage.hindi: "माइक्रोफोन अनुमति अस्वीकृत",
    AppLanguage.marathi: "मायक्रोफोन परवानगी नाकारली",
  },
  'speech_unavailable': {
    AppLanguage.english: "Speech not available",
    AppLanguage.hindi: "स्पीच उपलब्ध नहीं",
    AppLanguage.marathi: "भाषण उपलब्ध नाही",
  },
  'please_enter_message': {
    AppLanguage.english: "Please enter a message",
    AppLanguage.hindi: "कृपया एक संदेश दर्ज करें",
    AppLanguage.marathi: "कृपया एक संदेश प्रविष्ट करा",
  },
  'listening_hint': {
    AppLanguage.english: "🎤 Listening... Tap pause to stop",
    AppLanguage.hindi: "🎤 सुन रहा हूँ... रोकने के लिए टैप करें",
    AppLanguage.marathi: "🎤 ऐकत आहे... थांबवण्यासाठी टॅप करा",
  },
  'sending': {
    AppLanguage.english: "Sending...",
    AppLanguage.hindi: "भेज रहा हूँ...",
    AppLanguage.marathi: "पाठवत आहे...",
  },
  'type_hint': {
    AppLanguage.english: "Type your farming problem...",
    AppLanguage.hindi: "अपनी कृषि समस्या लिखें...",
    AppLanguage.marathi: "तुमची शेतीची समस्या टाईप करा...",
  },
  'listening_hint_field': {
    AppLanguage.english: "Listening...",
    AppLanguage.hindi: "सुन रहा हूँ...",
    AppLanguage.marathi: "ऐकत आहे...",
  },
  'tts_error': {
    AppLanguage.english: "Could not speak text",
    AppLanguage.hindi: "पाठ बोल नहीं सकता",
    AppLanguage.marathi: "मजकूर बोलू शकत नाही",
  },
  'speech_error': {
    AppLanguage.english: "Error: ",
    AppLanguage.hindi: "त्रुटि: ",
    AppLanguage.marathi: "त्रुटी: ",
  },
};

// ---------------------------------------------------------------------
// Floating Action Button (unchanged)
// ---------------------------------------------------------------------
class VoiceInputFAB extends StatelessWidget {
  const VoiceInputFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        );
      },
      backgroundColor: const Color(0xFF4CAF50),
      child: const Icon(Icons.mic, color: Colors.white),
    );
  }
}

// ---------------------------------------------------------------------
// Full screen AI Chatbot – now using CacheManager
// ---------------------------------------------------------------------
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();
  final GeminiAiService _geminiAiService = GeminiAiService();
  final CacheManager _cache = CacheManager();   // ✅ cache manager

  bool _isListening = false;
  bool _isProcessing = false;

  // TTS state
  String? _currentlySpeakingMessageId;
  bool _isSpeaking = false;

  // Language state
  AppLanguage _selectedLanguage = AppLanguage.english;

  // Local list of messages (loaded from cache)
  List<ChatMessage> _messages = [];

  // Scroll controller
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initSpeech();
    _initTts();
    _restoreOrInitMessages();
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFieldFocusNode.dispose();
    _scrollController.dispose();
    _speech.stop();
    _flutterTts.stop();
    _geminiAiService.dispose();
    super.dispose();
  }

  void _restoreOrInitMessages() {
    if (_cache.cachedChatMessages.isNotEmpty && _cache.chatInitialized) {
      _messages = List.from(_cache.cachedChatMessages);
      setState(() {});
    } else {
      _startDynamicGreeting();
    }
    _cache.chatInitialized = true;
  }

  void _changeLanguage(AppLanguage newLang) {
    if (_selectedLanguage == newLang) return;
    setState(() {
      _selectedLanguage = newLang;
    });
    _flutterTts.setLanguage(newLang.ttsCode);
    // Do NOT clear messages – keep history.
  }

  void _startDynamicGreeting() async {
    final typingId = DateTime.now().toString();
    final typingMessage = ChatMessage(
      id: typingId,
      text: localizations['typing']![_selectedLanguage]!,
      isUser: false,
      isTyping: true,
      timestamp: DateTime.now(),
    );
    _addMessageToCache(typingMessage);

    await Future.delayed(const Duration(milliseconds: 1600));

    setState(() {
      _messages.removeWhere((m) => m.id == typingId);
      _cache.cachedChatMessages = List.from(_messages);
    });

    const String englishGreeting = "Namaste! I'm NeuralField AI, your AI farming assistant! How can I help you with your crops today?";
    final greeting = ChatMessage(
      id: DateTime.now().toString(),
      text: englishGreeting,
      isUser: false,
      timestamp: DateTime.now(),
    );
    _addMessageToCache(greeting);
  }

  void _addMessageToCache(ChatMessage message) {
    setState(() {
      _messages.add(message);
      _cache.cachedChatMessages = List.from(_messages);
    });
    _scrollToBottom();
  }

  void _updateMessagesCache() {
    _cache.cachedChatMessages = List.from(_messages);
  }

  void _scrollToBottom({bool animated = true, int delayMs = 100}) {
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (_scrollController.hasClients &&
          _scrollController.position.hasContentDimensions) {
        final maxExtent = _scrollController.position.maxScrollExtent;
        if (animated && maxExtent > 0) {
          _scrollController.animateTo(
            maxExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        } else if (maxExtent > 0) {
          _scrollController.jumpTo(maxExtent);
        }
      }
    });
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      _showErrorSnackBar(localizations['mic_permission_required']![_selectedLanguage]!);
    }
  }

  void _initSpeech() async {
    await _speech.initialize(
      onError: (error) {
        setState(() => _isListening = false);
        _showErrorSnackBar('${localizations['speech_error']![_selectedLanguage]}${error.errorMsg}');
      },
    );
  }

  void _initTts() async {
    await _flutterTts.setLanguage(_selectedLanguage.ttsCode);
    await _flutterTts.setSpeechRate(0.5);
    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _currentlySpeakingMessageId = null;
          _isSpeaking = false;
        });
      }
    });
    _flutterTts.setErrorHandler((msg) {
      if (mounted) {
        setState(() {
          _currentlySpeakingMessageId = null;
          _isSpeaking = false;
        });
        _showErrorSnackBar('TTS error: $msg');
      }
    });
  }

  Future<void> _speakText(String messageId, String text) async {
    if (_currentlySpeakingMessageId == messageId && _isSpeaking) {
      await _stopSpeaking();
      return;
    }

    await _stopSpeaking(resetState: false);
    await _flutterTts.setLanguage(_selectedLanguage.ttsCode);

    setState(() {
      _currentlySpeakingMessageId = messageId;
      _isSpeaking = true;
    });
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      setState(() {
        _currentlySpeakingMessageId = null;
        _isSpeaking = false;
      });
      _showErrorSnackBar(localizations['tts_error']![_selectedLanguage]!);
    }
  }

  Future<void> _stopSpeaking({bool resetState = true}) async {
    await _flutterTts.stop();
    if (resetState && mounted) {
      setState(() {
        _currentlySpeakingMessageId = null;
        _isSpeaking = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _startListening() async {
    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      _showErrorSnackBar(localizations['mic_permission_denied']![_selectedLanguage]!);
      return;
    }
    if (!_speech.isAvailable) {
      _showErrorSnackBar(localizations['speech_unavailable']![_selectedLanguage]!);
      return;
    }

    _textFieldFocusNode.requestFocus();
    setState(() => _isListening = true);

    _speech.listen(
      onResult: (result) {
        setState(() {
          _textController.text = result.recognizedWords;
          _textController.selection = TextSelection.fromPosition(
            TextPosition(offset: _textController.text.length),
          );
        });
      },
      partialResults: true,
      listenFor: const Duration(seconds: 30),
    );
  }

  Future<void> _stopListening() async {
    if (_speech.isListening) await _speech.stop();
    if (mounted) setState(() => _isListening = false);
  }

  void _submitMessage() async {
    final messageText = _textController.text.trim();
    if (_isProcessing || messageText.isEmpty) {
      if (messageText.isEmpty) _showErrorSnackBar(localizations['please_enter_message']![_selectedLanguage]!);
      return;
    }

    FocusScope.of(context).unfocus();
    await _stopSpeaking();
    if (_isListening) await _stopListening();

    setState(() => _isProcessing = true);

    final userMessage = ChatMessage(
      id: DateTime.now().toString(),
      text: messageText,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _addMessageToCache(userMessage);
    _textController.clear();
    _scrollToBottom(delayMs: 200);

    await _processWithApi(messageText);
  }

  Future<void> _processWithApi(String text) async {
    final loadingId = DateTime.now().toString();
    final loadingMessage = ChatMessage(
      id: loadingId,
      text: localizations['thinking']![_selectedLanguage]!,
      isUser: false,
      isTyping: true,
      timestamp: DateTime.now(),
    );
    _addMessageToCache(loadingMessage);

    try {
      final languageInstruction = _selectedLanguage.promptInstruction;
      final augmentedMessage = '$languageInstruction\n\nUser: $text';
      final request = ChatRequest(message: augmentedMessage);
      final response = await _geminiAiService.sendChatMessage(request);

      setState(() {
        _messages.removeWhere((m) => m.id == loadingId);
        _updateMessagesCache();
      });

      if (response.isSuccess && response.aiResponse.isNotEmpty) {
        String cleanedText = response.aiResponse;
        if (cleanedText.isNotEmpty) {
          cleanedText = cleanedText[0].toUpperCase() + cleanedText.substring(1);
        }
        final aiMessage = ChatMessage(
          id: DateTime.now().toString(),
          text: cleanedText,
          isUser: false,
          timestamp: DateTime.now(),
        );
        _addMessageToCache(aiMessage);
      } else {
        final errorMessage = ChatMessage(
          id: DateTime.now().toString(),
          text: '❌ Error: ${response.errorMessage ?? localizations['error_unknown']![_selectedLanguage]!}',
          isUser: false,
          timestamp: DateTime.now(),
        );
        _addMessageToCache(errorMessage);
      }
    } catch (e) {
      setState(() {
        _messages.removeWhere((m) => m.id == loadingId);
        _updateMessagesCache();
      });
      final errorMessage = ChatMessage(
        id: DateTime.now().toString(),
        text: localizations['connection_failed']![_selectedLanguage]!,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _addMessageToCache(errorMessage);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCurrentlySpeaking =
        !isUser && _currentlySpeakingMessageId == message.id && _isSpeaking;

    if (message.isTyping == true) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(message.text, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: AnimatedContainer(
        duration: const Duration(microseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(maxWidth: screenWidth * 0.75),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(colors: [Color(0xFF43A047), Color(0xFF2E7D32)], begin: Alignment.topLeft, end: Alignment.bottomRight)
              : null,
          color: !isUser && isCurrentlySpeaking ? const Color(0xFFCCFFCC) : (!isUser ? Colors.white : null),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.text, style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 14, height: 1.3)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatTime(message.timestamp), style: TextStyle(color: isUser ? Colors.white70 : Colors.grey.shade500, fontSize: 10)),
                if (!isUser && message.text.isNotEmpty)
                  IconButton(
                    onPressed: () => _speakText(message.id, message.text),
                    icon: Icon((isCurrentlySpeaking) ? Icons.volume_off : Icons.volume_up, size: 16, color: Colors.grey.shade600),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.auto_awesome, size: 20, color: Colors.white),
            SizedBox(width: 8),
            Text('NeuralField AI', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          PopupMenuButton<AppLanguage>(
            icon: const Icon(Icons.language, color: Colors.white),
            onSelected: _changeLanguage,
            initialValue: _selectedLanguage,
            itemBuilder: (context) => AppLanguage.values.map((lang) {
              return PopupMenuItem<AppLanguage>(
                value: lang,
                child: Row(
                  children: [
                    if (lang == _selectedLanguage) const Icon(Icons.check, size: 18, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(lang.displayName),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFF1F8E9), Color(0xFFDCEDC8)]),
        ),
        child: Column(
          children: [
            if (_isListening)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.redAccent, Colors.red], begin: Alignment.centerLeft, end: Alignment.centerRight)),
                child: Center(child: Text(localizations['listening_hint']![_selectedLanguage]!, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))),
              ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, -4))],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: _isListening ? _stopListening : _startListening,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: _isListening
                              ? const LinearGradient(colors: [Colors.red, Colors.redAccent])
                              : const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)]),
                        ),
                        child: Icon(_isListening ? Icons.pause : Icons.mic, color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: _isListening ? Colors.red.shade300 : Colors.grey.shade300, width: 1.5),
                        ),
                        child: TextField(
                          controller: _textController,
                          focusNode: _textFieldFocusNode,
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          enabled: !_isProcessing,
                          decoration: InputDecoration(
                            hintText: _isProcessing
                                ? localizations['sending']![_selectedLanguage]!
                                : (_isListening
                                ? localizations['listening_hint_field']![_selectedLanguage]!
                                : localizations['type_hint']![_selectedLanguage]!),
                            hintStyle: TextStyle(
                              color: _isProcessing
                                  ? Colors.grey.shade400
                                  : (_isListening ? Colors.red.shade400 : Colors.grey.shade400),
                              fontStyle: FontStyle.italic,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onSubmitted: (_) => _submitMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)])),
                      child: Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: _isProcessing ? null : _submitMessage,
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            child: _isProcessing
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                                : const Icon(Icons.send, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Data model (unchanged)
// ---------------------------------------------------------------------
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final bool? isTyping;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    this.isTyping,
    required this.timestamp,
  });
}