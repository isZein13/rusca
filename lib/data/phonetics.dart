class RussianToTurkishPhonetics {
  static const _map = <String, String>{
    'А': 'A',
    'а': 'a',
    'Б': 'B',
    'б': 'b',
    'В': 'V',
    'в': 'v',
    'Г': 'G',
    'г': 'g',
    'Д': 'D',
    'д': 'd',
    'Е': 'Ye',
    'е': 'e',
    'Ё': 'Yo',
    'ё': 'yo',
    'Ж': 'J',
    'ж': 'j',
    'З': 'Z',
    'з': 'z',
    'И': 'İ',
    'и': 'i',
    'Й': 'Y',
    'й': 'y',
    'К': 'K',
    'к': 'k',
    'Л': 'L',
    'л': 'l',
    'М': 'M',
    'м': 'm',
    'Н': 'N',
    'н': 'n',
    'О': 'O',
    'о': 'o',
    'П': 'P',
    'п': 'p',
    'Р': 'R',
    'р': 'r',
    'С': 'S',
    'с': 's',
    'Т': 'T',
    'т': 't',
    'У': 'U',
    'у': 'u',
    'Ф': 'F',
    'ф': 'f',
    'Х': 'H',
    'х': 'h',
    'Ц': 'Ts',
    'ц': 'ts',
    'Ч': 'Ç',
    'ч': 'ç',
    'Ш': 'Ş',
    'ш': 'ş',
    'Щ': 'Şç',
    'щ': 'şç',
    'Ъ': '',
    'ъ': '',
    'Ы': 'I',
    'ы': 'ı',
    'Ь': '',
    'ь': '',
    'Э': 'E',
    'э': 'e',
    'Ю': 'Yu',
    'ю': 'yu',
    'Я': 'Ya',
    'я': 'ya',
  };

  static String transcribe(String ru) {
    final buf = StringBuffer();
    for (var i = 0; i < ru.length; i++) {
      final ch = ru[i];
      if (ch == 'е' && (i == 0 || !_isCyrillicLetter(ru[i - 1]))) {
        buf.write('ye');
        continue;
      }
      if (ch == 'Е' && (i == 0 || !_isCyrillicLetter(ru[i - 1]))) {
        buf.write('Ye');
        continue;
      }
      buf.write(_map[ch] ?? ch);
    }
    return buf.toString();
  }

  static bool _isCyrillicLetter(String ch) {
    final code = ch.codeUnitAt(0);
    return code >= 0x0400 && code <= 0x04FF;
  }
}
