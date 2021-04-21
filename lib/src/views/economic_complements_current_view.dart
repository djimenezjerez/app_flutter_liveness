import 'package:flutter/material.dart';
import 'package:muserpol_app/src/views/economic_complement_list_view.dart';

class EconomicComplementsCurrentView extends StatefulWidget {
  @override
  _EconomicComplementsCurrentViewState createState() =>
      _EconomicComplementsCurrentViewState();
}

class _EconomicComplementsCurrentViewState
    extends State<EconomicComplementsCurrentView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: EconomicComplementListView(current: true),
        ),
      ],
    );
  }
}
