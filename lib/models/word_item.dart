class WordItem {
  const WordItem({
    required this.id,
    required this.ru,
    required this.tr,
    required this.trPron,
    required this.category,
  });

  final String id;
  final String ru;
  final String tr;
  final String trPron;
  final String category;

  factory WordItem.fromJson(Map<String, dynamic> json) {
    return WordItem(
      id: json['id'] as String,
      ru: json['ru'] as String,
      tr: json['tr'] as String,
      trPron: json['trPron'] as String,
      category: json['category'] as String,
    );
  }
}

enum WordStatus { neu, toLearn, learned }
