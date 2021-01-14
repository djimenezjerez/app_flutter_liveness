import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:muserpol_app/src/models/city.dart';
import 'package:muserpol_app/src/services/city_service.dart';
import 'package:muserpol_app/src/services/media_app.dart';
import 'package:url_launcher/url_launcher.dart';

class CitiesView extends StatefulWidget {
  @override
  _CitiesViewState createState() => _CitiesViewState();
}

class _CitiesViewState extends State<CitiesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contactos a nivel nacional',
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: FutureBuilder(
          future: CityService.getCities(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
              default:
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                else
                  return citiesList(context, snapshot);
            }
          },
        ),
      ),
    );
  }

  Card cityCard(BuildContext context, City city) {
    MediaApp _media = MediaApp(context);
    double _horizontalMargin =
        _media.isPortrait ? 10 : _media.screenWidth * 0.3;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      elevation: 5,
      color: Colors.lightGreen[100],
      margin: EdgeInsets.symmetric(
        vertical: 9,
        horizontal: _horizontalMargin,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(
          15,
        ),
        title: Container(
          margin: const EdgeInsets.only(
            bottom: 5,
          ),
          child: Text(
            city.name.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(
                bottom: 5,
              ),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      right: 8,
                    ),
                    child: Text(
                      'Dirección: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Flexible(
                    child: FlatButton.icon(
                      icon: Icon(
                        Icons.location_pin,
                        color: Colors.red[300],
                      ),
                      padding: const EdgeInsets.all(0),
                      height: 0,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onPressed: () {
                        if (city.latitude != null && city.longitude != null) {
                          MapsLauncher.launchCoordinates(city.latitude,
                              city.longitude, city.companyAddress);
                        }
                      },
                      label: Flexible(
                        child: Text(
                          city.companyAddress,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (city.companyPhones.length > 0)
              SizedBox(
                height: 5,
              ),
            if (city.companyPhones.length > 0)
              Row(
                children: [
                  Text(
                    'Teléfonos: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: city.companyPhones
                            .map((item) => phoneButton(city.phonePrefix, item))
                            .toList(),
                      ),
                    ),
                  )
                ],
              ),
            if (city.companyCellphones.length > 0 &&
                city.companyPhones.length == 0)
              SizedBox(
                height: 5,
              ),
            if (city.companyCellphones.length > 0 &&
                city.companyPhones.length > 0)
              SizedBox(
                height: 10,
              ),
            if (city.companyCellphones.length > 0)
              Row(
                children: [
                  Text(
                    'Celulares: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: city.companyCellphones
                            .map((item) => cellphoneButton(item))
                            .toList(),
                      ),
                    ),
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }

  FlatButton phoneButton(int prefix, int phone) {
    final _prefix = prefix.toString();
    final _phone = phone.toString();

    return FlatButton(
      padding: const EdgeInsets.all(0),
      height: 0,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: () => setState(() => _makePhoneCall(_prefix + _phone)),
      child: Text(
        '($_prefix) $_phone',
      ),
    );
  }

  FlatButton cellphoneButton(int phone) {
    final _phone = phone.toString();

    return FlatButton(
      padding: const EdgeInsets.all(0),
      height: 0,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: () => setState(() => _makePhoneCall(_phone)),
      child: Text(
        '$_phone',
      ),
    );
  }

  Future<void> _makePhoneCall(String phone) async {
    String url = 'tel:$phone';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  Widget citiesList(BuildContext context, AsyncSnapshot snapshot) {
    List<City> cities = snapshot.data;
    return ListView.builder(
      itemCount: cities.length == 0 ? 0 : cities.length,
      itemBuilder: (BuildContext context, int index) {
        City city = cities[index];
        return cityCard(context, city);
      },
    );
  }
}
