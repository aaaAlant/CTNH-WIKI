import 'package:ctnh_wiki/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('wiki home renders navigation tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const CtnhWikiApp());
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('CTNH WIKI'), findsWidgets);
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('攻略教程'), findsOneWidget);
    expect(find.text('多方块预览'), findsOneWidget);
  });
}
