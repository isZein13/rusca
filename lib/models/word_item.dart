class WordItem {
  const WordItem({
    required this.id,
    required this.ru,
    required this.tr,
    required this.trPron,
    required this.category,
    this.tip = '',
  });

  final String id;
  final String ru;
  final String tr;
  final String trPron;
  final String category;
  final String tip;

  factory WordItem.fromJson(Map<String, dynamic> json) {
    return WordItem(
      id: json['id'] as String,
      ru: json['ru'] as String,
      tr: json['tr'] as String,
      trPron: json['trPron'] as String,
      category: json['category'] as String,
      tip: json['tip'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ru': ru,
        'tr': tr,
        'trPron': trPron,
        'category': category,
        'tip': tip,
      };
}

enum WordStatus { neu, toLearn, learned }
