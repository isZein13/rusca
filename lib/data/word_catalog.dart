import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/word_item.dart';
import 'phonetics.dart';

class WordCatalog {
  WordCatalog._(this.words);

  final List<WordItem> words;

  static Future<WordCatalog> load() async {
    final raw = await rootBundle.loadString('assets/words.json');
    final list = jsonDecode(raw) as List<dynamic>;
    final words = list.map((item) {
      final map = item as Map<String, dynamic>;
      final ru = map['ru'] as String;
      final trPron = (map['trPron'] as String?)?.trim();
      return WordItem(
        id: map['id'] as String,
        ru: ru,
        tr: map['tr'] as String,
        trPron: (trPron == null || trPron.isEmpty)
            ? RussianToTurkishPhonetics.transcribe(ru)
            : trPron,
        category: map['category'] as String,
      );
    }).toList();
    return WordCatalog._(words);
  }

  WordItem? byId(String id) {
    for (final word in words) {
      if (word.id == id) return word;
    }
    return null;
  }
}
