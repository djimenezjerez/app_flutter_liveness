import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:muserpol_app/src/services/media_app.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactsView extends StatefulWidget {
  @override
  _ContactsViewState createState() => _ContactsViewState();
}

class _ContactsViewState extends State<ContactsView> {
  List<Contact> _contacts = List.from([
    Contact(
      city: 'LA PAZ',
      address: 'Zona Sopocachi - Av. 6 de Agosto N° 2354',
      coordinates: [
        -16.5086,
        -68.12653,
      ],
      prefix: 2,
      phones: [
        2442270,
        2445101,
        2443506,
      ],
      cellphones: [],
    ),
    Contact(
      city: 'COCHABAMBA',
      address: 'Av. Melchor Urquidi - Zona Queru Queru Nº 1985',
      coordinates: [
        -17.369605,
        -66.149686,
      ],
      prefix: 4,
      phones: [
        4458935,
        4242210,
      ],
      cellphones: [
        71782067,
      ],
    ),
    Contact(
      city: 'SANTA CRUZ',
      address: 'Calle Ballivian Zona Este Nº 1229',
      coordinates: [
        -16.508697,
        -68.126546,
      ],
      prefix: 3,
      phones: [
        3337570,
      ],
      cellphones: [
        72134627,
      ],
    ),
    Contact(
      city: 'SUCRE',
      address: 'Calle Loa - Zona San Roque Nº 1070',
      coordinates: [
        -19.050645,
        -65.26576,
      ],
      prefix: 4,
      phones: [
        6452587,
      ],
      cellphones: [
        72875480,
      ],
    ),
    Contact(
      city: 'ORURO',
      address: 'Av. 6 de Octubre entre oblitas y Belzu Zona Central Nº 4836',
      coordinates: [
        -17.959307,
        -67.109766,
      ],
      prefix: 5,
      phones: [
        246509,
      ],
      cellphones: [
        67200819,
      ],
    ),
    Contact(
      city: 'POTOSI',
      address: 'Calle 1º de Abril - Zona Central Nº 615',
      coordinates: [
        -19.582756,
        -65.752783,
      ],
      prefix: 2,
      phones: [
        6226428,
      ],
      cellphones: [
        72405059,
      ],
    ),
    Contact(
      city: 'TRINIDAD',
      address: 'Av. Cipriano Barece - Zona San Jose',
      coordinates: [
        -15.671311,
        -66.5176,
      ],
      prefix: 3,
      phones: [
        4622030,
      ],
      cellphones: [
        71133639,
      ],
    ),
    Contact(
      city: 'TARIJA',
      address: 'Av Los Ceibos Esq. Cosio',
      coordinates: [
        -21.539301,
        -64.745244,
      ],
      prefix: 4,
      phones: [
        6644229,
      ],
      cellphones: [
        71862987,
      ],
    ),
    Contact(
      city: 'COBIJA',
      address: 'Av. 9 de Febrero ex SEGIP, 2do. Piso',
      coordinates: [
        -11.028398,
        -68.761157,
      ],
      prefix: 4,
      phones: [],
      cellphones: [
        67669749,
      ],
    ),
  ]);

  @override
  Widget build(BuildContext context) {
    MediaApp _media = MediaApp(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contactos',
        ),
      ),
      body: Container(
        margin: _media.isPortrait
            ? const EdgeInsets.all(10)
            : EdgeInsets.symmetric(
                horizontal: _media.screenWidth * 0.3,
              ),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 15,
        ),
        child: ListView.builder(
          itemCount: _contacts.length,
          itemBuilder: (BuildContext lstContext, int index) {
            return contact(_contacts[index]);
          },
        ),
      ),
    );
  }

  Card contact(Contact contact) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          15,
        ),
      ),
      elevation: 5,
      color: Colors.lightGreen[100],
      margin: const EdgeInsets.symmetric(
        vertical: 9,
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
            contact.city.toUpperCase(),
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
                        if (contact.coordinates.length == 2) {
                          MapsLauncher.launchCoordinates(contact.coordinates[0],
                              contact.coordinates[1], contact.address);
                        }
                      },
                      label: Flexible(
                        child: Text(
                          contact.address,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (contact.phones.length > 0)
              SizedBox(
                height: 5,
              ),
            if (contact.phones.length > 0)
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
                        children: contact.phones
                            .map((item) => phoneButton(contact.prefix, item))
                            .toList(),
                      ),
                    ),
                  )
                ],
              ),
            if (contact.cellphones.length > 0 && contact.phones.length == 0)
              SizedBox(
                height: 5,
              ),
            if (contact.cellphones.length > 0 && contact.phones.length > 0)
              SizedBox(
                height: 10,
              ),
            if (contact.cellphones.length > 0)
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
                        children: contact.cellphones
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
      onPressed: () => setState(() {
        _makePhoneCall(_prefix + _phone);
      }),
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
      onPressed: () => setState(() {
        _makePhoneCall(_phone);
      }),
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
}

class Contact {
  String city;
  String address;
  List<double> coordinates;
  int prefix;
  List<int> phones;
  List<int> cellphones;

  Contact(
      {this.city,
      this.address,
      this.coordinates,
      this.prefix,
      this.phones,
      this.cellphones});
}
