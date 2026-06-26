import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:adeen/features/quiz/domain/quiz_question.dart';

class QuizTranslator {
  static const String boxName = 'quiz_translations';

  static Future<String> translateText(String text, String targetLang) async {
    final cleanText = text.trim();
    if (targetLang == 'en' || cleanText.isEmpty) return cleanText;
    
    final box = Hive.box(boxName);
    final cacheKey = '${targetLang}_${cleanText.hashCode}';
    
    if (box.containsKey(cacheKey)) {
      final cached = box.get(cacheKey) as String?;
      if (cached != null && cached.trim().isNotEmpty && cached.trim().toLowerCase() != 'null') {
        return cached;
      } else {
        // Clean up corrupt or empty cache entry on the fly
        await box.delete(cacheKey);
      }
    }
    
    try {
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=$targetLang&dt=t&q=${Uri.encodeComponent(cleanText)}'
      );
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as List<dynamic>;
        if (decoded.isNotEmpty && decoded[0] != null) {
          final translatedParts = decoded[0] as List<dynamic>;
          final buffer = StringBuffer();
          for (var part in translatedParts) {
            if (part is List && part.isNotEmpty && part[0] is String) {
              buffer.write(part[0] as String);
            }
          }
          final translated = buffer.toString().trim();
          if (translated.isNotEmpty && translated.toLowerCase() != 'null') {
            await box.put(cacheKey, translated);
            return translated;
          }
        }
      }
    } catch (e) {
      // Fallback silently to English on network/timeout errors
      // to ensure robust offline capability
    }
    return text;
  }

  static Future<QuizQuestion> translateQuestion(QuizQuestion q, String targetLang) async {
    if (targetLang == 'en') return q;

    final translatedCategory = await translateText(q.category, targetLang);
    final translatedQuestion = await translateText(q.question, targetLang);
    final translatedTafsir = await translateText(q.tafsirInsight, targetLang);
    
    final List<String> translatedOptions = [];
    for (var opt in q.options) {
      final transOpt = await translateText(opt, targetLang);
      translatedOptions.add(transOpt);
    }

    return QuizQuestion(
      id: q.id,
      category: translatedCategory,
      difficulty: q.difficulty,
      points: q.points,
      question: translatedQuestion,
      options: translatedOptions,
      correctOptionIndex: q.correctOptionIndex,
      tafsirInsight: translatedTafsir,
    );
  }
}
