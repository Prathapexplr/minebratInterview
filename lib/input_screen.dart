import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:minebrat/splash_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({Key? key}) : super(key: key);

  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _gender = 'Male';

  final String statesEndpoint = 'http://api.minebrat.com/api/v1/states';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          'INPUT SCREEN',
          style: TextStyle(
              fontWeight: FontWeight.w800, color: Colors.black.withOpacity(.5)),
        )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  fillColor: Colors.white,
                  // Add box shadow
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Text(
                    "Gender :   ",
                    style: TextStyle(
                        color: Colors.black.withOpacity(.5),
                        fontWeight: FontWeight.w900,
                        fontSize: 18),
                  ),
                  Row(
                    children: [
                      Radio(
                        value: 'Male',
                        groupValue: _gender,
                        onChanged: (value) {
                          setState(() {
                            _gender = value.toString();
                          });
                        },
                      ),
                      const Text('Male'),
                      Radio(
                        value: 'Female',
                        groupValue: _gender,
                        onChanged: (value) {
                          setState(() {
                            _gender = value.toString();
                          });
                        },
                      ),
                      const Text('Female'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _fetchStates();
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchStates() async {
    final response = await http.get(Uri.parse(statesEndpoint));

    if (response.statusCode == 200) {
      final List<dynamic> statesData = jsonDecode(response.body);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StatesListScreen(
            statesData: statesData,
            name: _nameController.text,
            gender: _gender,
          ),
        ),
      );
    } else {
      print('Failed to fetch states. Status code: ${response.statusCode}');
    }
  }
}

class StatesListScreen extends StatelessWidget {
  final List<dynamic> statesData;
  final String name;
  final String gender;

  const StatesListScreen({
    Key? key,
    required this.statesData,
    required this.name,
    required this.gender,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('States List'),
      ),
      body: FutureBuilder(
        future: _fetchCitiesData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return StateListView(
              data: snapshot.data ?? [],
              onTap: (stateId) {
                _navigateToCitiesList(context, stateId, name, gender);
              },
            );
          }
        },
      ),
    );
  }

  Future<List<dynamic>> _fetchCitiesData() async {
    await Future.delayed(const Duration(seconds: 2));

    return statesData;
  }

  Future<void> _navigateToCitiesList(
      BuildContext context, String stateId, String name, String gender) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CitiesListScreen(
          citiesData: [],
          name: name,
          state: stateId,
          gender: gender,
        ),
      ),
    );
  }
}

class CitiesListScreen extends StatelessWidget {
  final List<dynamic> citiesData;
  String name;
  String state;
  final String gender;

  CitiesListScreen({
    Key? key,
    required this.citiesData,
    required this.name,
    required this.state,
    required this.gender,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cities List'),
      ),
      body: FutureBuilder(
        future: _fetchCitiesData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return CityListView(
              data: snapshot.data ?? [],
              onTap: (city) {
                _showConfirmationDialog(context, city);
              },
            );
          }
        },
      ),
    );
  }

  Future<List<dynamic>> _fetchCitiesData() async {
    try {
      final citiesEndpoint =
          'http://api.minebrat.com/api/v1/states/cities/$state';
      final response = await http.get(Uri.parse(citiesEndpoint));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to fetch cities. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }

  Future<void> _showConfirmationDialog(
      BuildContext context, String city) async {
    String salutation = gender == 'Male' ? 'Mr' : 'Ms';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text('Dear $salutation $name, you are from $city in India.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SplashScreen(),
                ),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class StateListView extends StatefulWidget {
  final List<dynamic> data;
  final Function(String) onTap;

  const StateListView({
    Key? key,
    required this.data,
    required this.onTap,
  }) : super(key: key);

  @override
  _StateListViewState createState() => _StateListViewState();
}

class _StateListViewState extends State<StateListView> {
  List<dynamic> filteredData = [];

  @override
  void initState() {
    super.initState();
    filteredData = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              setState(() {
                filteredData = widget.data
                    .where((element) => element['stateName']
                        .toString()
                        .toLowerCase()
                        .contains(value.toLowerCase()))
                    .toList();
              });
            },
            decoration: const InputDecoration(
              labelText: 'Search State',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredData.length,
            itemBuilder: (context, index) {
              final state = filteredData[index]['stateName'];
              return ListTile(
                title: Text(state),
                onTap: () {
                  widget.onTap(filteredData[index]['stateId']);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class CityListView extends StatefulWidget {
  final List<dynamic> data;
  final Function(String) onTap;

  const CityListView({
    Key? key,
    required this.data,
    required this.onTap,
  }) : super(key: key);

  @override
  _CityListViewState createState() => _CityListViewState();
}

class _CityListViewState extends State<CityListView> {
  List<dynamic> filteredData = [];

  @override
  void initState() {
    super.initState();
    filteredData = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              setState(() {
                filteredData = widget.data
                    .where((element) => element['cityName']
                        .toString()
                        .toLowerCase()
                        .contains(value.toLowerCase()))
                    .toList();
              });
            },
            decoration: const InputDecoration(
              labelText: 'Search City',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredData.length,
            itemBuilder: (context, index) {
              final city = filteredData[index]['cityName'];
              return ListTile(
                title: Text(city),
                onTap: () {
                  widget.onTap(city);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: StatesListScreen(
      statesData: [],
      name: '',
      gender: '',
    ),
  ));
}
