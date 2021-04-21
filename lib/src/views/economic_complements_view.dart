import 'package:flutter/material.dart';
import 'package:muserpol_app/src/views/economic_complement_list_view.dart';
import 'package:muserpol_app/src/views/economic_complements_current_view.dart';

class EconomicComplementsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Complemento Económico'),
          bottom: TabBar(
            tabs: [
              Tab(
                text: 'Vigentes',
              ),
              Tab(
                text: 'Histórico',
              )
            ],
          ),
        ),
        body: TabBarView(
          children: [
            EconomicComplementsCurrentView(),
            EconomicComplementListView(
              current: false,
            ),
          ],
        ),
      ),
    );
  }
}
