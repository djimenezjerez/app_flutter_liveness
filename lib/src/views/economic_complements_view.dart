import 'package:flutter/material.dart';
import 'package:muserpol_app/src/views/economic_complement_list_view.dart';
import 'package:muserpol_app/src/views/economic_complements_current_view.dart';

class EconomicComplementsView extends StatefulWidget {
  final String dialogMessage;

  const EconomicComplementsView({
    Key key,
    this.dialogMessage = '',
  }) : super(key: key);

  @override
  _EconomicComplementsViewState createState() =>
      _EconomicComplementsViewState();
}

class _EconomicComplementsViewState extends State<EconomicComplementsView> {
  @override
  void initState() {
    super.initState();
    _showDialog();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Complemento Económico'),
          bottom: TabBar(
            indicator: BoxDecoration(
              color: Colors.green[600],
              border: Border(
                bottom: BorderSide(
                  color: Colors.blueGrey,
                  width: 3,
                ),
              ),
            ),
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

  void _showDialog() async {
    if (widget.dialogMessage != '') {
      await Future.delayed(Duration(
        milliseconds: 100,
      ));
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Proceso completado'),
            content: Text(widget.dialogMessage),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
