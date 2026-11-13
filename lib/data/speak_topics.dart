class SpeakTopic {
  const SpeakTopic(this.id, this.label, this.brief);

  final String id;
  final String label;
  final String brief;
}

const speakTopics = <SpeakTopic>[
  SpeakTopic(
    'tanisma',
    'Tanışma',
    'introducing yourself: name, where you are from, nice to meet you, what you do',
  ),
  SpeakTopic(
    'anlama',
    'Anlamadım',
    'saying you do not understand, asking to repeat slowly, asking what a word means',
  ),
  SpeakTopic(
    'kafe',
    'Kafe',
    'ordering food and drink, asking for the menu and the bill, saying it is tasty or too much',
  ),
  SpeakTopic(
    'market',
    'Market',
    'asking the price, saying you will take it, paying by cash or card, asking for a bag',
  ),
  SpeakTopic(
    'yol',
    'Yol sorma',
    'asking where a place is, left right and straight, how far, thanking for directions',
  ),
  SpeakTopic(
    'ulasim',
    'Ulaşım',
    'buying a ticket, asking which stop to get off, asking a taxi to go to an address',
  ),
  SpeakTopic(
    'otel',
    'Otel',
    'check-in, asking for the key, breakfast time, wifi password, a quiet room',
  ),
  SpeakTopic(
    'tepki',
    'Tepki',
    'agreeing, asking someone to wait, saying you are tired or glad, apologizing, saying it is fine',
  ),
  SpeakTopic(
    'plan',
    'Plan',
    'talking about today and tomorrow, suggesting to go, saying you want or cannot, asking the time',
  ),
  SpeakTopic(
    'yardim',
    'Yardım',
    'asking for help, saying you are lost, asking for a doctor or a pharmacy',
  ),
];

SpeakTopic? speakTopicById(String id) {
  for (final topic in speakTopics) {
    if (topic.id == id) return topic;
  }
  return null;
}

String suggestSpeakTopic(Iterable<String> usedCategories) {
  final counts = {for (final topic in speakTopics) topic.id: 0};
  for (final category in usedCategories) {
    if (counts.containsKey(category)) {
      counts[category] = counts[category]! + 1;
    }
  }
  var best = speakTopics.first.id;
  var bestCount = 1 << 30;
  for (final topic in speakTopics) {
    final count = counts[topic.id]!;
    if (count < bestCount) {
      bestCount = count;
      best = topic.id;
    }
  }
  return best;
}
