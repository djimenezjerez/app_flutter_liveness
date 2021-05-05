import 'package:flutter/material.dart';
import 'package:muserpol_app/src/models/api_response.dart';
import 'package:muserpol_app/src/services/affiliate_service.dart';
import 'package:muserpol_app/src/services/config.dart';
import 'package:muserpol_app/src/services/liveness_service.dart';
import 'package:muserpol_app/src/views/card_view.dart';
import 'package:muserpol_app/src/views/economic_complement_list_view.dart';

class EconomicComplementsCurrentView extends StatefulWidget {
  @override
  _EconomicComplementsCurrentViewState createState() =>
      _EconomicComplementsCurrentViewState();
}

class _EconomicComplementsCurrentViewState
    extends State<EconomicComplementsCurrentView> {
  bool _loading;
  bool _enabled;
  dynamic _affiliate;

  @override
  void initState() {
    _loading = true;
    _enabled = true;
    _getAffiliateObservations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CardView(
                data: _affiliate,
                setLoading: setLoading,
                color: _enabled ? Colors.green[100] : Colors.red[100],
              ),
              Divider(
                height: 10,
                thickness: 2,
                indent: 10,
                endIndent: 10,
              ),
              Flexible(
                child: EconomicComplementListView(current: true),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(0),
                padding: const EdgeInsets.all(0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: const EdgeInsets.all(0),
                  ),
                  onPressed: (!_enabled || _loading)
                      ? null
                      : () {
                          _getAffiliateEnabled();
                        },
                  icon: Icon(Icons.add),
                  label: Text('Nuevo Trámite'),
                ),
              )
            ],
          );
  }

  void _getAffiliateObservations() async {
    try {
      ApiResponse response = await AffiliateService.getObservations();
      setState(() {
        _affiliate = response.data;
        _enabled = response.data['enabled'];
      });
    } catch (e) {
      print(e);
    } finally {
      _loading = false;
    }
  }

  void _getAffiliateEnabled() async {
    try {
      _loading = true;
      ApiResponse response = await LivenessService.getAffiliateEnabled();
      if (response.data['liveness_success']) {
        Navigator.of(context)
            .pushNamed(Config.routes['economic_complement_create']);
      } else {
        Navigator.of(context).pushNamed(Config.routes['camera_view']);
      }
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
