import 'package:flutter/material.dart';
import 'package:muserpol_app/src/models/api_response.dart';
import 'package:muserpol_app/src/services/economic_complement_service.dart';
import 'package:muserpol_app/src/views/card_view.dart';

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
  ScrollController _scrollController = ScrollController();
  int _page = 1;
  int _lastPage = 0;
  int _totalItems = 0;

  @override
  void initState() {
    _loading = true;
    _procedures = [];
    super.initState();
    _getEconomicComplements(widget.current);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if ((_totalItems > _procedures.length || _lastPage == 0) && !_loading) {
          _getEconomicComplements(widget.current);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: (_procedures.length == 0 && !_loading)
          ? Center(
              child: Text(
                'No se encontraron trámites',
              ),
            )
          : ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: _procedures.length + 1,
              itemBuilder: (context, index) {
                if (index >= _procedures.length) {
                  if (_totalItems > _procedures.length || _lastPage == 0) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Container();
                  }
                } else {
                  return CardView(
                    data: _procedures[index],
                    setLoading: setLoading,
                  );
                }
              },
            ),
    );
  }

  void _getEconomicComplements(bool current) async {
    try {
      _loading = true;
      ApiResponse response =
          await EconomicComplementService.getEconomicComplements(
              _page, current);
      setState(() {
        _procedures.addAll(response.data['data']);
        _lastPage = response.data['last_page'];
        _totalItems = response.data['total'];
        if (_lastPage > _page && _totalItems > _procedures.length) {
          _page++;
        }
      });
    } catch (e) {
      print(e);
    } finally {
      _loading = false;
    }
  }

  void setLoading(bool value) {
    setState(() {
      _loading = value;
    });
  }
}
