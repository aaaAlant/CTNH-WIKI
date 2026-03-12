import 'package:flutter_test/flutter_test.dart';

import 'package:ctnh_wiki/main.dart';

void main() {
  testWidgets('wiki home renders core sections', (WidgetTester tester) async {
    await tester.pumpWidget(const CtnhWikiApp());

    expect(find.text('CTNH WIKI'), findsWidgets);
    expect(find.text('最近更新'), findsOneWidget);
    expect(find.text('任务书导览'), findsOneWidget);
  });
}
