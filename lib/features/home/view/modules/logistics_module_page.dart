import 'package:ctnh_wiki/app/responsive.dart';
import 'package:ctnh_wiki/features/guides/data/wiki_content_data.dart';
import 'package:ctnh_wiki/features/guides/view/widgets/formal_wiki_sections.dart';
import 'package:flutter/material.dart';

class LogisticsModulePage extends StatelessWidget {
  const LogisticsModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FormalWikiModulePanel(
      module: wikiModuleSections[2],
      responsive: ResponsiveLayout.of(context),
      wrapWithContentPanel: false,
    );
  }
}
