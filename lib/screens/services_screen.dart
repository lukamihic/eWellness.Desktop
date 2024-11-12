import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart' as config show apiUri;

class ServicesScreen extends StatefulWidget {
  @override
  _ServicesScreenState createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  List<Service> services = [];
  late ServiceDataSource serviceDataSource;
  List<ServiceCategory> serviceCategories = [];
  String token = "";

static const apiUrl =
      String.fromEnvironment('API_URI', defaultValue: config.apiUri);
  @override
  void initState() {
    super.initState();
    fetchServices();
    fetchServiceCategories();
  }

  fetchServices() async {
    final Uri fullApiUrl = Uri.parse(apiUrl + '/users/login');

    final Map<String, String> body = {
      'email': 'desktop',
      'password': 'test',
    };

    final responseLogin = await http.post(
      fullApiUrl,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(body),
    );

    if (responseLogin.statusCode == 200) {
      token = responseLogin.body.toString();
    } else {
      throw Exception('Failed to fetch user.');
    }

    final response =
        await http.get(Uri.parse(apiUrl + '/services'), headers: {HttpHeaders.authorizationHeader: 'Bearer ' + token});
    if (response.statusCode == 200) {
      setState(() {
        services = (json.decode(response.body) as List)
            .map((data) => Service.fromJson(data))
            .toList();
        serviceDataSource = ServiceDataSource(
          services: services,
          onEdit: _editService,
          onDelete: _deleteService,
        );
      });
    } else {
      throw Exception('Failed to load services');
    }
  }

  fetchServiceCategories() async {
    final response = await http
        .get(Uri.parse(apiUrl + '/servicecategories'), headers: {HttpHeaders.authorizationHeader: 'Bearer ' + token});
    if (response.statusCode == 200) {
      setState(() {
        serviceCategories = (json.decode(response.body) as List)
            .map((data) => ServiceCategory.fromJson(data))
            .toList();
      });
    } else {
      throw Exception('Failed to load service categories');
    }
  }

  void _addService() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ServiceForm(
          serviceCategories: serviceCategories,
          onSubmit: (service) async {
            final response = await http.post(
              Uri.parse(apiUrl + '/services'),
              headers: {'Content-Type': 'application/json', HttpHeaders.authorizationHeader: 'Bearer ' + token},
              body: jsonEncode(service.toJson()),
            );
            if (response.statusCode.toString().startsWith('2')) {
              fetchServices();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Service added successfully!'),
                  duration: Duration(seconds: 2),
                ),
              );
            } else {
              throw Exception('Failed to add service');
            }
          },
        );
      },
    );
  }

  void _editService(Service service) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ServiceForm(
          serviceCategories: serviceCategories,
          service: service,
          onSubmit: (updatedService) async {
            final response = await http.put(
              Uri.parse(
                  apiUrl + '/services/${updatedService.id}'),
              headers: {'Content-Type': 'application/json', HttpHeaders.authorizationHeader: 'Bearer ' + token},
              body: jsonEncode(updatedService.toJson()),
            );
            if (response.statusCode == 200) {
              fetchServices();
              Navigator.pop(context);
            } else {
              throw Exception('Failed to update service');
            }
          },
        );
      },
    );
  }

  void _deleteService(int serviceId) async {
    const apiUrl =
        String.fromEnvironment('API_URI', defaultValue: config.apiUri);
    final response = await http.get(Uri.parse('${apiUrl}/services/$serviceId'), headers: {HttpHeaders.authorizationHeader: 'Bearer ' + token});
    if (response.statusCode == 200) {
      fetchServices();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Service deleted successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      throw Exception('Failed to delete service');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: services.isEmpty
          ? Center(
              child: Text(
                'No services yet',
                style: TextStyle(fontSize: 24, color: Colors.grey),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SfDataGrid(
                    source: serviceDataSource,
                    columns: [
                      GridColumn(
                        columnName: 'name',
                        label: Text('Name', textAlign: TextAlign.center),
                        minimumWidth: 0.7 * MediaQuery.sizeOf(context).width,
                      ),
                      GridColumn(
                        columnName: 'actions',
                        label: Text('     Actions'),
                        minimumWidth: 0.3 * MediaQuery.sizeOf(context).width,
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addService,
        child: Icon(
          Icons.add,
          color: Color.fromARGB(255, 76, 175, 142),
        ),
      ),
    );
  }
}

class Service {
  Service({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.duration,
    required this.isAvailable,
    this.imageUrl,
    required this.serviceCategoryId,
    required this.serviceCategoryName,
  });

  final int id;
  final String name;
  final String? description;
  final double price;
  final int duration;
  final bool isAvailable;
  final String? imageUrl;
  final int serviceCategoryId;
  final String serviceCategoryName;

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0.0).toDouble(),
      duration: json['duration'] ?? 0,
      isAvailable: json['isAvailable'] ?? false,
      imageUrl: json['imageUrl'],
      serviceCategoryId: json['serviceCategory']['id'] ?? 0,
      serviceCategoryName: json['serviceCategory']['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'isAvailable': isAvailable,
      'imageUrl': imageUrl,
      'serviceCategoryId': serviceCategoryId,
      'serviceCategoryName': serviceCategoryName,
    };
  }
}

class ServiceCategory {
  ServiceCategory({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class ServiceDataSource extends DataGridSource {
  ServiceDataSource(
      {required List<Service> services,
      required this.onEdit,
      required this.onDelete}) {
    dataGridRows = services
        .map<DataGridRow>((service) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'name', value: service.name),
              DataGridCell<Widget>(
                  columnName: 'actions',
                  value: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => onEdit(service),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => onDelete(service.id),
                      ),
                    ],
                  )),
            ]))
        .toList();
  }

  List<DataGridRow> dataGridRows = [];
  final Function(Service) onEdit;
  final Function(int) onDelete;

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: [
      Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text(row.getCells()[0].value),
      ),
      Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: row.getCells()[1].value,
      ),
    ]);
  }
}

class ServiceForm extends StatefulWidget {
  final List<ServiceCategory> serviceCategories;
  final Service? service;
  final Function(Service) onSubmit;

  ServiceForm({
    required this.serviceCategories,
    required this.onSubmit,
    this.service,
  });

  @override
  _ServiceFormState createState() => _ServiceFormState();
}

class _ServiceFormState extends State<ServiceForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late TextEditingController _imageUrlController;
  bool _isAvailable = false;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.service?.description ?? '');
    _priceController =
        TextEditingController(text: widget.service?.price.toString() ?? '');
    _durationController =
        TextEditingController(text: widget.service?.duration.toString() ?? '');
    _imageUrlController =
        TextEditingController(text: widget.service?.imageUrl ?? '');
    _isAvailable = widget.service?.isAvailable ?? false;
    _selectedCategoryId = widget.service?.serviceCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.65,
        child: AlertDialog(
          title: Text(widget.service == null ? 'Add Service' : 'Edit Service'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a price';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _durationController,
                    decoration:
                        InputDecoration(labelText: 'Duration (minutes)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a duration';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16), // Add some space between fields
                  Row(
                    children: [
                      Text('Available'),
                      Switch(
                        value: _isAvailable,
                        onChanged: (bool value) {
                          setState(() {
                            _isAvailable = value;
                          });
                        },
                      ),
                    ],
                  ),
                  DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: InputDecoration(labelText: 'Category'),
                    items: widget.serviceCategories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (int? value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: InputDecoration(labelText: 'Image URL'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Service newService = Service(
                    id: widget.service?.id ?? 0,
                    name: _nameController.text,
                    description: _descriptionController.text,
                    price: double.parse(_priceController.text),
                    duration: int.parse(_durationController.text),
                    isAvailable: _isAvailable,
                    imageUrl: _imageUrlController.text.isEmpty
                        ? 'https://st4.depositphotos.com/14953852/24787/v/450/depositphotos_247872612-stock-illustration-no-image-available-icon-vector.jpg'
                        : _imageUrlController.text,
                    serviceCategoryId: _selectedCategoryId!,
                    serviceCategoryName: widget.serviceCategories
                        .firstWhere(
                            (category) => category.id == _selectedCategoryId)
                        .name,
                  );
                  widget.onSubmit(newService);
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
