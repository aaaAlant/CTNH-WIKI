import 'package:ctnh_wiki/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('wiki home renders navigation tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const CtnhWikiApp());

    expect(find.text('CTNH WIKI'), findsWidgets);
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('图鉴'), findsOneWidget);
    expect(find.text('任务概览'), findsOneWidget);
  });
}
