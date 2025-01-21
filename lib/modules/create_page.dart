import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo; 
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'event_model/event_model.dart';

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();
  final _priceController = TextEditingController();
  final _totalSeatsController = TextEditingController();
  final _hostEmailController = TextEditingController();

  DateTime? _startDateTime;
  DateTime? _endDateTime;
  bool _isPaid = false;
  String _eventType = 'online';
  String _category = 'meetup';
  String? _eventImageUrl; 

  final ImagePicker _picker = ImagePicker();

  void _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDateTime = picked;
        } else {
          _endDateTime = picked;
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _uploadImageToCloudinary(image);
    }
  }

  Future<void> _uploadImageToCloudinary(XFile image) async {
    final url = dotenv.env['CLOUDINARY_URL'];
    final request = http.MultipartRequest('POST', Uri.parse(url.toString()));
    request.fields['upload_preset'] = dotenv.env['CLOUDINARY_UPLOAD_PRESET'].toString();
    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonResponse = json.decode(responseString);
      setState(() {
        _eventImageUrl = jsonResponse['secure_url'];
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed')),
      );
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_startDateTime != null && _endDateTime != null && _startDateTime!.isAfter(_endDateTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Start date must be less than or equal to end date')),
        );
        return;
      }


      final uri = dotenv.env['MONGODB_URI'];
      final db = mongo.Db(uri.toString());
      await db.open();
      final collection = db.collection('events');

      final event = Event(
        id: mongo.ObjectId(),
        title: _titleController.text,
        description: _descriptionController.text,
        eventImage: _eventImageUrl!, 
        startDateTime: _startDateTime!,
        endDateTime: _endDateTime!,
        venue: _venueController.text,
        isPaid: _isPaid,
        price: _isPaid ? double.parse(_priceController.text) : 0.0,
        totalSeats: int.parse(_totalSeatsController.text),
        bookedSeats: 0,
        eventType: _eventType,
        host: mongo.ObjectId(),
        category: _category,
        attendees: [],
        createdAt: DateTime.now(),
        hostEmail: _hostEmailController.text,
      );

      await collection.insertOne(event.toJson());
      await db.close();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event created successfully!')),
      );
    }
  }

@override
Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter Details:',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
          child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _eventImageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(_eventImageUrl!,
                                      fit: BoxFit.cover),
                                )
                              : Center(child: Text('Pick an Image')),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _venueController,
                        decoration: InputDecoration(
                          labelText: 'Venue',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a venue';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text('Is Paid'),
                          Switch(
                            value: _isPaid,
                            onChanged: (value) {
                              setState(() {
                                _isPaid = value;
                              });
                            },
                          ),
                        ],
                      ),
                      if (_isPaid)
                        TextFormField(
                          controller: _priceController,
                          decoration: InputDecoration(
                            labelText: 'Price',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a price';
                            }
                            return null;
                          },
                        ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _totalSeatsController,
                        decoration: InputDecoration(
                          labelText: 'Total Seats',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter total seats';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _hostEmailController,
                        decoration: InputDecoration(
                          labelText: 'Host Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter host email';
                          }

                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 8),
                      ListTile(
                        title: Text('Start Date'),
                        subtitle: Text(_startDateTime == null
                            ? 'Not selected'
                            : DateFormat.yMd().format(_startDateTime!)),
                        onTap: () => _selectDate(context, true),
                      ),
                      ListTile(
                        title: Text('End Date'),
                        subtitle: Text(_endDateTime == null
                            ? 'Not selected'
                            : DateFormat.yMd().format(_endDateTime!)),
                        onTap: () => _selectDate(context, false),
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Event Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        value: _eventType,
                        items: ['online', 'offline']
                            .map((label) => DropdownMenuItem(
                                  child: Text(label),
                                  value: label,
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _eventType = value!;
                          });
                        },
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        value: _category,
                        items: [
                          'meetup',
                          'seminar',
                          'workshop',
                          'webinar',
                          'exhibition',
                          'masterclass'
                        ]
                            .map((label) => DropdownMenuItem(
                                  child: Text(label),
                                  value: label,
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _category = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Create Event', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}