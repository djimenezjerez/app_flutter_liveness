import 'package:flutter/material.dart';
import 'package:muserpol_app/src/models/api_response.dart';
import 'package:muserpol_app/src/services/economic_complement_service.dart';
import 'package:muserpol_app/src/views/economic_complement_card_view.dart';

class EconomicComplementListView extends StatefulWidget {
  final bool current;

  const EconomicComplementListView({
    Key key,
    @required this.current,
  }) : super(key: key);

  @override
  _EconomicComplementListViewState createState() =>
      _EconomicComplementListViewState();
}

class _EconomicComplementListViewState
    extends State<EconomicComplementListView> {
  bool _loading;
  List<dynamic> _procedures;

  @override
  void initState() {
    _loading = true;
    _procedures = [];
    _getEconomicComplements(widget.current);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: _procedures.length,
              itemBuilder: (context, index) {
                return EconomicComplementCardView(
                  procedure: _procedures[index],
                );
              },
            ),
    );
  }

  void _getEconomicComplements(bool current) async {
    try {
      ApiResponse response =
          await EconomicComplementService.getEconomicComplements(1, current);
      setState(() {
        _procedures = response.data['data'];
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
}
