import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Map<int, int> _keyVelocities = {}; // MIDI note number -> velocity
  late MidiCommand _midiCommand;
  Stream<MidiPacket>? _midiData;

  @override
  void initState() {
    super.initState();
    _midiCommand = MidiCommand();
    _midiCommand.startScanningForBluetoothDevices();
    _midiData = _midiCommand.onMidiDataReceived;
    _midiData?.listen(_handleMidiData);
  }

  void _handleMidiData(MidiPacket packet) {
    final data = packet.data;
    if (data.length >= 3 && data[0] >= 144 && data[0] <= 159) {
      final note = data[1];
      final velocity = data[2];
      setState(() {
        _keyVelocities[note] = velocity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MIDI Visualizer',
      home: Scaffold(
        appBar: AppBar(title: Text('MIDI Velocity Visualizer')),
        body: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 11,
            childAspectRatio: 0.2,
          ),
          itemCount: 88,
          itemBuilder: (context, index) {
            int note = index + 21;
            double velocity = (_keyVelocities[note] ?? 0).toDouble();
            return Column(
              children: [
                Container(
                  height: 100,
                  width: 10,
                  color: velocity > 0 ? Colors.blue : Colors.grey[200],
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: velocity,
                      color: Colors.red,
                    ),
                  ),
                ),
                Text('$note', style: TextStyle(fontSize: 10)),
              ],
            );
          },
        ),
      ),
    );
  }
}
