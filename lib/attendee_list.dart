import 'package:flutter/material.dart';
import 'db/db_helper.dart';
import 'models/attendee.dart';

class AttendeeListPage extends StatefulWidget {
  const AttendeeListPage({Key? key}) : super(key: key);

  @override
  State<AttendeeListPage> createState() => _AttendeeListPageState();
}

class _AttendeeListPageState extends State<AttendeeListPage> {
  final DBHelper db = DBHelper();
  List<Attendee> attendees = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await db.getAllAttendees();
    if (!mounted) return;
    setState(() => attendees = list);
  }

  @override
  Widget build(BuildContext context) {
    final checkedInCount = attendees.where((a) => a.checkedIn).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendees'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          itemCount: attendees.length + 1,
          itemBuilder: (context, idx) {
            if (idx == 0) {
              return ListTile(
                title: Text('Checked in: $checkedInCount'),
                subtitle: Text('Total records: ${attendees.length}'),
              );
            }
            final a = attendees[idx - 1];
            return ListTile(
              leading: CircleAvatar(child: Text(a.id.substring(0, 2).toUpperCase())),
              title: Text(a.name ?? a.id),
              subtitle: Text(a.checkedInAt ?? (a.checkedIn ? 'Checked in' : 'Not checked in')),
              trailing: a.checkedIn ? const Icon(Icons.check_circle, color: Colors.green) : null,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _load,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
