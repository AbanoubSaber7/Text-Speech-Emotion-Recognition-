import 'package:flutter/material.dart';
import 'package:mood_app/services/text_analysis_service.dart';

class TextAnalysisScreen extends StatefulWidget {
  const TextAnalysisScreen({super.key});

  @override
  State<TextAnalysisScreen> createState() => _TextAnalysisScreenState();
}

class _TextAnalysisScreenState extends State<TextAnalysisScreen> {
  static const _accentColor = Color(0xFFC05A4E);
  static const _inkColor = Color(0xFF282424);
  static const _maxTextLength = 2000;

  final _textController = TextEditingController();
  final _service = TextAnalysisService();

  TextAnalysisResult? _result;
  String? _errorMessage;
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _textController.dispose();
    _service.close();
    super.dispose();
  }

  Future<void> _analyze() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isAnalyzing) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final result = await _service.analyze(
        baseUrl: TextAnalysisService.defaultBaseUrl,
        text: text,
      );
      if (!mounted) return;
      setState(() => _result = result);
    } on TextAnalysisException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message);
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F4),
      appBar: AppBar(
        title: const Text(
          'Text Analysis',
          style: TextStyle(
            color: _inkColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F6F4),
        foregroundColor: _inkColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 22),
                  _buildInputCard(),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 56,
                    child: FilledButton(
                      onPressed:
                          _isAnalyzing || _textController.text.trim().isEmpty
                          ? null
                          : _analyze,
                      style: FilledButton.styleFrom(
                        backgroundColor: _accentColor,
                        disabledBackgroundColor: const Color(0xFFE2DAD7),
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isAnalyzing
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Analyzing your text...',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome_rounded, size: 20),
                                SizedBox(width: 9),
                                Text(
                                  'Analyze text',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _buildErrorCard(_errorMessage!),
                  ],
                  if (_result != null) ...[
                    const SizedBox(height: 22),
                    _buildResult(_result!),
                  ],
                  const SizedBox(height: 18),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 15,
                        color: Color(0xFF827B78),
                      ),
                      SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          'Emotion estimates only — not a mental-health diagnosis.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF827B78),
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFC05A4E), Color(0xFF9E4740)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UNDERSTAND YOURSELF',
            style: TextStyle(
              color: Color(0xFFFFDDD7),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Put your feelings into words.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              height: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Write in English and discover the emotions your text may express.',
            style: TextStyle(
              color: Color(0xFFFFEFED),
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 15, 17, 11),
      decoration: _cardDecoration(
        border: Border.all(color: const Color(0xFFECE6E3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'YOUR TEXT',
                  style: TextStyle(
                    color: Color(0xFF6D6561),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              if (_textController.text.isNotEmpty)
                IconButton(
                  onPressed: () {
                    _textController.clear();
                    setState(() {
                      _result = null;
                      _errorMessage = null;
                    });
                  },
                  tooltip: 'Clear text',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close_rounded, size: 19),
                  color: const Color(0xFF827B78),
                ),
            ],
          ),
          TextField(
            controller: _textController,
            minLines: 5,
            maxLines: 8,
            maxLength: _maxTextLength,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(
              color: _inkColor,
              fontSize: 15,
              height: 1.55,
            ),
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'For example: I am very happy today!',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintStyle: TextStyle(color: Color(0xFFAAA19D), fontSize: 14),
              counterText: '',
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_textController.text.length}/$_maxTextLength',
              style: const TextStyle(
                color: Color(0xFF948C88),
                fontSize: 11,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFF9B1C1C), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(TextAnalysisResult result) {
    final sortedEmotions = [...result.allEmotions]
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
    final dominantColor = _emotionColor(result.emotion);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'ANALYSIS RESULT',
            style: TextStyle(
              color: Color(0xFF827B78),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: dominantColor.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: dominantColor.withValues(alpha: 0.16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _emotionIcon(result.emotion),
                    color: dominantColor,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _capitalize(result.emotion),
                        style: TextStyle(
                          color: dominantColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Most expressed emotion',
                        style: TextStyle(
                          color: Color(0xFF746C68),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${result.confidence.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: dominantColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Emotion breakdown',
                  style: TextStyle(
                    color: _inkColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${sortedEmotions.length} emotions',
                style: const TextStyle(color: Color(0xFF948C88), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final emotion in sortedEmotions) _buildEmotionBar(emotion),
        ],
      ),
    );
  }

  Widget _buildEmotionBar(EmotionScore emotion) {
    final value = (emotion.confidence / 100).clamp(0.0, 1.0);
    final color = _emotionColor(emotion.label);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _capitalize(emotion.label),
                  style: const TextStyle(
                    color: Color(0xFF4A4441),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${emotion.confidence.toStringAsFixed(2)}%',
                style: const TextStyle(
                  color: Color(0xFF4A4441),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: value,
            minHeight: 6,
            borderRadius: BorderRadius.circular(6),
            color: color,
            backgroundColor: const Color(0xFFF0ECEA),
          ),
        ],
      ),
    );
  }

  Color _emotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'anger':
        return const Color(0xFFC6534B);
      case 'disgust':
        return const Color(0xFF66845B);
      case 'fear':
        return const Color(0xFF7771A8);
      case 'joy':
        return const Color(0xFFD49A35);
      case 'neutral':
        return const Color(0xFF6D858A);
      case 'sadness':
        return const Color(0xFF5C7FA5);
      case 'surprise':
        return const Color(0xFFCA7950);
      default:
        return _accentColor;
    }
  }

  IconData _emotionIcon(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'anger':
        return Icons.sentiment_very_dissatisfied_rounded;
      case 'disgust':
        return Icons.sick_rounded;
      case 'fear':
        return Icons.warning_amber_rounded;
      case 'joy':
        return Icons.sentiment_very_satisfied_rounded;
      case 'neutral':
        return Icons.sentiment_neutral_rounded;
      case 'sadness':
        return Icons.sentiment_dissatisfied_rounded;
      case 'surprise':
        return Icons.sentiment_satisfied_alt_rounded;
      default:
        return Icons.mood_rounded;
    }
  }

  BoxDecoration _cardDecoration({Border? border}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: border,
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF39251F).withValues(alpha: 0.045),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  String _capitalize(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
}
