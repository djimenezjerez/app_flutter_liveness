import 'package:flutter/material.dart';
import 'package:disk_space/disk_space.dart';
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
  String _message;
  dynamic _affiliate;

  @override
  void initState() {
    _message = '';
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
                color: Colors.green[100],
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (_message != '')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                        ),
                        color: _enabled
                            ? Colors.blueGrey[100]
                            : Colors.yellow[200],
                        width: double.infinity,
                        child: Text(
                          _message,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.all(0),
                      margin: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          elevation: 0,
                          padding: const EdgeInsets.all(0),
                        ),
                        onPressed: (!_enabled || _loading)
                            ? null
                            : () {
                                _getAffiliateEnabled();
                              },
                        icon: Icon(Icons.add),
                        label: Flexible(
                          child: Text(
                            'CREAR NUEVO TRÁMITE',
                            style: TextStyle(
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
  }

  void _getAffiliateObservations() async {
    try {
      ApiResponse response = await AffiliateService.getObservations(context);
      setState(() {
        _affiliate = response.data;
        _enabled = response.data['enabled'];
        _message = response.message;
      });
    } catch (e) {
      print(e);
    } finally {
      _loading = false;
    }
  }

  void _getAffiliateEnabled() async {
    try {
      double diskSpace = 0;
      diskSpace = await DiskSpace.getFreeDiskSpace;
      // Al menos debe tener 3 MB de espacio disponible
      if (diskSpace < 3) {
        setState(() {
          _message = 'Debe liberar espacio de memoria';
          _enabled = false;
        });
      } else {
        _loading = true;
        ApiResponse response =
            await LivenessService.getAffiliateEnabled(context);
        if (response.data['liveness_success']) {
          Navigator.of(context)
              .pushNamed(Config.routes['economic_complement_create']);
        } else {
          Navigator.of(context).pushNamed(Config.routes['camera_view']);
        }
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
