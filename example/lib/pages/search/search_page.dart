import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    if (kDebugMode) {
      print("search initState");
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(title: 'Search'),

      body: Center(child: Text("Search Page")),
    );
  }
}
