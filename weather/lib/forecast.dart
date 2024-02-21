import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'location.dart';
import 'weather.dart';

Future<Weather> forecast() async {
  const url = 'https://data.tmd.go.th/nwpapi/v1/forecast/location/hourly/at';
  const token =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6ImViOWYyZTA1YzUzYzMxNGQyYzY3OWFhNzg3OGEwYjE4MDk0YjlhMDAzYjliYjU3NmJlNGM3YWU3MzNkODQ1ZTU3ZmQ1ZmUzM2ZmNjU4ZWRiIn0.eyJhdWQiOiIyIiwianRpIjoiZWI5ZjJlMDVjNTNjMzE0ZDJjNjc5YWE3ODc4YTBiMTgwOTRiOWEwMDNiOWJiNTc2YmU0YzdhZTczM2Q4NDVlNTdmZDVmZTMzZmY2NThlZGIiLCJpYXQiOjE3MDc4ODIyMjAsIm5iZiI6MTcwNzg4MjIyMCwiZXhwIjoxNzM5NTA0NjIwLCJzdWIiOiIzMDA3Iiwic2NvcGVzIjpbXX0.Nj5Q4UgD98LJPu6I0XSIy4tAAbvqmmpGaK4pzEv0L-5XnB4g85u81JVepIQUB6GZqRfQA-PZYWCo1-XNZbZDslUDq-oNo1AVPLyWhFzVY5bytXqGs5X-iNLyeTtamJ_Bc-fUr7g1mXugyCLrVWC7gb4-XPKBirUsfgYlSvvHquVVH_oqmGOj9Rbjogum41E3S-mLXMKIJijgazNOIoG0IQq6atq5vydDgXC3bG1gS17V1JX2BX6QC2hhKioR_6l-gnhY6frAeKVxbRe_7QXmNDSmOVvwJA1vWdeWwo05VlF-mJV_GsSNEP4ZwvL2Vmcgcys42hblSkOBdYjHv2UZCDoE_lYkn0f1YvH620eKrewOsIkUEykiIlInhrT4jf987frKnRquJwd2h89VOF_FapGRMQj6h68o01JLX4CwVMXl8KJuhDKqA2ioe7y_OBa6xLnQ6Op7kVrKq6srF5P_Fl9ugd0R0pvLQPCIAYYZHqkoqORpd3ZbfKYNrebNO9317fEVFpFOXDVUSNT60225N4eJJJUPYTQCOlhoNTGeV-sXgQFwr-rL7Q7DIR8ZoBDydFlHCAuizmoSbFWRm-xZ-PQ_Ad7my7WpXixa2qGZEnySy4FvSLgG3P8ol_T5ZHHXLtPXZOP_Q4JW1hnj_zote9ocA026N5qZf7QJHLldvzY';

  try {
    Position location = await getCurrentLocation();
    http.Response response = await http.get(
        Uri.parse(
            '$url?lat=${location.latitude}&lon=${location.longitude}&fields=tc,cond'),
        headers: {
          'accept': 'application/json',
          'authorization': 'Bearer $token',
        });
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body)['WeatherForecasts'][0]['forecasts']
          [0]['data'];
      Placemark address = (await placemarkFromCoordinates(
              location.latitude, location.longitude))
          .first;
      return Weather(
        address: '${address.subLocality}\n${address.administrativeArea}',
        temperature: result['tc'],
        cond: result['cond'],
      );
    } else {
      return Future.error(response.statusCode);
    }
  } catch (e) {
    return Future.error(e);
  }
}
