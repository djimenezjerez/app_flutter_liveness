import 'package:flutter/material.dart';
import 'package:muserpol_app/src/models/api_response.dart';
import 'package:muserpol_app/src/services/eco_com_procedure_service.dart';
import 'package:muserpol_app/src/services/liveness_service.dart';
import 'package:muserpol_app/src/views/card_view.dart';

class EconomicComplementCreateView extends StatefulWidget {
  @override
  _EconomicComplementCreateViewState createState() =>
      _EconomicComplementCreateViewState();
}

class _EconomicComplementCreateViewState
    extends State<EconomicComplementCreateView> {
  bool _loading;
  bool _validate;
  int _ecoComProcedureId;
  dynamic _procedure;

  @override
  void initState() {
    _loading = true;
    _validate = false;
    _getAffiliateEnabled();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complemento Económico'),
      ),
      body: Container(
        child: _loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CardView(
                    data: _procedure,
                    color: Colors.green[100],
                  ),
                ],
              ),
      ),
    );
  }

  void _getAffiliateEnabled() async {
    try {
      ApiResponse response = await LivenessService.getAffiliateEnabled();
      setState(() {
        _validate = response.data['validate'];
        _ecoComProcedureId = response.data['procedure_id'];
      });
      _getEcoComProcedure(response.data['procedure_id']);
    } catch (e) {
      print(e);
      _loading = false;
    }
  }

  void _getEcoComProcedure(ecoComProcedureId) async {
    try {
      ApiResponse response =
          await EcoComProcedureService.getEcoComProcedure(ecoComProcedureId);
      setState(() {
        _procedure = response.data;
      });
    } catch (e) {
      print(e);
    } finally {
      _loading = false;
    }
  }
}
