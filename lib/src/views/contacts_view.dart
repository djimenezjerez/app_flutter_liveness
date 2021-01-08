import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:muserpol_app/src/models/contact.dart';
import 'package:muserpol_app/src/services/contact_service.dart';
import 'package:muserpol_app/src/services/media_app.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactsView extends StatefulWidget {
  @override
  _ContactsViewState createState() => _ContactsViewState();
}

class _ContactsViewState extends State<ContactsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contactos',
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: FutureBuilder(
          future: ContactService.getContacts(),
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
                  return contactsList(context, snapshot);
            }
          },
        ),
      ),
    );
  }

  Card contactCard(BuildContext context, Contact contact) {
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

  Widget contactsList(BuildContext context, AsyncSnapshot snapshot) {
    List<Contact> contacts = snapshot.data;
    return ListView.builder(
      itemCount: contacts.length == 0 ? 0 : contacts.length,
      itemBuilder: (BuildContext context, int index) {
        Contact contact = contacts[index];
        return contactCard(context, contact);
      },
    );
  }
}
