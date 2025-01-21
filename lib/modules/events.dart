import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Events extends StatefulWidget {
  @override
  _EventsState createState() => _EventsState();
}

class _EventsState extends State<Events> {
  late mongo.Db db;
  late mongo.DbCollection eventsCollection;
  List<Map<String, dynamic>> events = [];
  bool isLoading = true;

  String selectedCategory = 'All';   

  @override
  void initState() {
    super.initState();
    connectToDatabase();
  }

  Future<void> connectToDatabase() async {
    try {
      String? uri = dotenv.env['MONGODB_URI'];
      db = mongo.Db(uri.toString());
      await db.open();

      eventsCollection = db.collection('events');

      final fetchedEvents = await eventsCollection.find().toList();

      setState(() {
        events = fetchedEvents.map((e) => e as Map<String, dynamic>).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error connecting to MongoDB: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String truncateWithEllipsis(int cutoff, String myString) {
    return (myString.length <= cutoff)
        ? myString
        : '${myString.substring(0, cutoff)}...';
  }

  List<Map<String, dynamic>> getFilteredEvents() {
    return events.where((event) {
      bool matchesCategory = selectedCategory == 'All' || event['category'] == selectedCategory;
      return matchesCategory;
    }).toList();
  }

  @override
  void dispose() {
    db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: false,
                  snap: true,
                  backgroundColor: Colors.black,
                  elevation: 2,
                  toolbarHeight: 50,
                  flexibleSpace: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCategory = newValue!;
                          });
                        },
                        items: <String>['All', 'meetup', 'seminar', 'workshop', 'webinar', 'exhibition', 'masterclass']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        underline: const SizedBox(),
                        icon: const Icon(Icons.filter_list, size: 20),
                      ),
                    ),
                  ),
                ),

                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final event = getFilteredEvents()[index];
                      final imageUrl = event['eventImage'] ?? '';
                      final startDateTime = event['startDateTime'] ?? '';
                      final endDateTime = event['endDateTime'] ?? '';
                      final venue = event['venue'] ?? 'Online';
                      final category = event['category'] ?? 'general';

                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (imageUrl.isNotEmpty)
                              Image.network(
                                imageUrl,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Text('Image not available'),
                                  );
                                },
                              ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event['title'] ?? 'No Title',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '${(startDateTime)}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(' - '),
                                      Text(
                                        '${(endDateTime)}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$category',
                                   style: const TextStyle(
                                     // backgroundColor: Colors.grey,
                                     color: Colors.cyan,
                                     fontSize: 12,
                                   ),
                                 ),
                                  const SizedBox(height: 4),
                                  Text(
                                    truncateWithEllipsis(50, event['description']) ?? 'No Description',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_pin, size: 16),
                                      Text(
                                        '$venue',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: getFilteredEvents().length,
                  ),
                ),
              ],
            ),
    );
  }
}
