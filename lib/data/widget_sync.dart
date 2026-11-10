import 'package:home_widget/home_widget.dart';

import '../models/word_item.dart';

const androidWidgetName = 'WordOfDayWidgetProvider';
const iosWidgetName = 'RuscaWidget';
const androidQualifiedName = 'com.rusca.app.WordOfDayWidgetProvider';
const iosAppGroup = 'group.com.rusca.app';

Future<void> syncWordOfDayWidget(WordItem word) async {
  try {
    await HomeWidget.setAppGroupId(iosAppGroup);
    await HomeWidget.saveWidgetData<String>('trPron', word.trPron);
    await HomeWidget.saveWidgetData<String>('ru', word.ru);
    await HomeWidget.saveWidgetData<String>('tr', word.tr);
    await HomeWidget.updateWidget(
      name: androidWidgetName,
      androidName: androidWidgetName,
      iOSName: iosWidgetName,
      qualifiedAndroidName: androidQualifiedName,
    );
  } catch (_) {
    // Widgets are unavailable on some desktops / before native setup.
  }
}
