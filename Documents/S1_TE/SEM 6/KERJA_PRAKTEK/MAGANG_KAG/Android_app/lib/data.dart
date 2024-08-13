import 'package:MONITORING_SUHU/get_csv.dart';
import 'fetchdata.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Data extends StatefulWidget {
  const Data({super.key});

  @override
  _DataState createState() => _DataState();
}

class _DataState extends State<Data> {
  late List<fetch> fetchlist;
  late String abc = '';

  @override
  void initState() {
    super.initState();
    fetchlist = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      abc = ModalRoute.of(context)!.settings.arguments as String;
      retrievefetchData();
    });
  }

  void retrievefetchData() {
    DatabaseReference db = FirebaseDatabase.instance.ref();

    db.child(abc).onValue.listen((event) {
      fetchlist.clear();

      if (event.snapshot.value == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No data available.')),
          );
        }
        return;
      }

      Map<dynamic, dynamic> cekDataValues = event.snapshot.value as Map<dynamic, dynamic>;

      setState(() {
        cekDataValues.forEach((key, value) {
          double temp = double.parse(value["Temp"].toString());

          // Apply calibration based on the channel
          if (key == "CS 1") {
            temp += 4; // Add 4 for CS 1
          } else if (key == "CH 5") {
            temp += 1.2; // Add 1.2 for CH 5
          }
          String tempp = temp.toStringAsFixed(2);
          fetchlist.add(fetch(
            key: key,
            Temp: tempp.toString(),
            Hum: value["Hum"].toString(),
            CO2: value["CO2"].toString(),
          ));
        });
        fetchlist.sort((a, b) => a.key.compareTo(b.key));
      });
    }, onError: (error) {
      print("Error retrieving data: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error retrieving data: $error')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CH & CS Monitoring'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              try {
                // Call the CSV download function
                await CSVExporter.downloadCSV(context);
              } catch (e) {
                // Handle errors related to CSV export here if needed
                print('Download error: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Download error: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Divider(
            height: 1,
            color: Colors.black,
            thickness: 1,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: fetchlist.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ListTile(
                          title: Text(fetchlist[index].key),
                        ),
                      ),
                      const SizedBox(
                        height: 60,
                        child: VerticalDivider(
                            width: 1, thickness: 1, color: Colors.black),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAlignedText('Temperature', fetchlist[index].Temp, '°C'),
                              _buildAlignedText('Humidity', fetchlist[index].Hum, '%'),
                              // Text('CO₂: ${fetchlist[index].CO2}'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildAlignedText(String label, String value, String unit) {
  return Row(
    children: [
      SizedBox(
        width: 90, // Fixed width for the label to ensure alignment
        child: Text(
          label,
          textAlign: TextAlign.left,
        ),
      ),
      const SizedBox(
        width: 10, // Fixed width for the colon to ensure alignment
        child: Text(
          ':',
          textAlign: TextAlign.left,
        ),
      ),
      Text(
        ' $value$unit',
        textAlign: TextAlign.left,
      ),
    ],
  );
}
