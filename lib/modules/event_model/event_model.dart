import 'package:mongo_dart/mongo_dart.dart';

class Event {
  ObjectId id;
  String title;
  String description;
  String eventImage;
  DateTime startDateTime;
  DateTime endDateTime;
  String venue;
  bool isPaid;
  double price;
  int totalSeats;
  int bookedSeats;
  String eventType;
  String? qrCode;
  ObjectId host;
  String category;
  List<String> attendees;
  DateTime createdAt;
  String hostEmail;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.eventImage,
    required this.startDateTime,
    required this.endDateTime,
    required this.venue,
    required this.isPaid,
    required this.price,
    required this.totalSeats,
    required this.bookedSeats,
    required this.eventType,
    this.qrCode,
    required this.host,
    required this.category,
    required this.attendees,
    required this.createdAt,
    required this.hostEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'eventImage': eventImage,
      'startDateTime': startDateTime,
      'endDateTime': endDateTime,
      'venue': venue,
      'isPaid': isPaid,
      'price': price,
      'totalSeats': totalSeats,
      'bookedSeats': bookedSeats,
      'eventType': eventType,
      'qrCode': qrCode,
      'host': host,
      'category': category,
      'attendees': attendees,
      'createdAt': createdAt,
      'hostEmail': hostEmail,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      eventImage: json['eventImage'],
      startDateTime: json['startDateTime'],
      endDateTime: json['endDateTime'],
      venue: json['venue'],
      isPaid: json['isPaid'],
      price: json['price'],
      totalSeats: json['totalSeats'],
      bookedSeats: json['bookedSeats'],
      eventType: json['eventType'],
      qrCode: json['qrCode'],
      host: json['host'],
      category: json['category'],
      attendees: List<String>.from(json['attendees']),
      createdAt: json['createdAt'],
      hostEmail: json['hostEmail'],
    );
  }
}