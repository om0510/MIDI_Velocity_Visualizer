import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VelocityVisualizer(),
    );
  }
}

class VelocityVisualizer extends StatefulWidget {
  const VelocityVisualizer({super.key});

  @override
  State<VelocityVisualizer> createState() => _VelocityVisualizerState();
}

class _VelocityVisualizerState extends State<VelocityVisualizer> {
  static const int totalKeys = 88;
  List<int> velocities = List<int>.filled(totalKeys, 0);

  // 產生88鍵對應音名
  final List<String> noteNames = () {
    const names = ['A', 'A#', 'B', 'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#'];
    List<String> result = [];
    int octave = 0;
    for (int i = 0; i < 88; i++) {
      result.add('${names[i % 12]}$octave');
      if (names[i % 12] == 'G#') octave++;
    }
    return result;
  }();

  final MidiCommand midiCommand = MidiCommand();

  // 初始化 MIDI
  void _initMidi() {
    midiCommand.start();
    midiCommand.addListener(_midiInput);
  }

  // 處理 MIDI 訊號（按鍵、velocity）
  void _midiInput(MidiMessage message) {
    if (message.type == MidiType.noteOn) {
      int velocity = message.velocity;
      int note = message.note;

      setState(() {
        velocities[note - 21] = velocity; // MIDI 音符 21 是鍵盤上的 C0
      });
    } else if (message.type == MidiType.noteOff) {
      int note = message.note;

      setState(() {
        velocities[note - 21] = 0; // note off 時將 velocity 設為 0
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initMidi();
  }

  @override
  Widget build(BuildContext context) {
    const double keyWidth = 12.0;
    const double maxBarHeight = 300;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: RawKeyboardListener(
          autofocus: true,
          focusNode: FocusNode(),
          onKey: _handleKey,
          child: RotatedBox(
            quarterTurns: 1, // 橫向
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(totalKeys, (index) {
                  final velocity = velocities[index];
                  final barHeight = (velocity / 127.0) * maxBarHeight;
                  final note = noteNames[index];

                  return Container(
                    width: keyWidth,
                    margin: const EdgeInsets.symmetric(horizontal: 0.3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: velocity > 0 ? 5 : 200), // 進入短，退出長
                          width: keyWidth * 0.9,
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: velocity > 0 ? Colors.green : Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 2),
                        RotatedBox(
                          quarterTurns: -1,
                          child: SizedBox(
                            width: 20, // 固定寬度，避免音名不同長度導致位移
                            child: Text(
                              note,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 7,
                                color: Colors.white70,
                                fontFamily: 'monospace', // 使用等寬字體
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleKey(RawKeyEvent event) {
    // 用來處理電腦鍵盤按鍵的原始事件（現在主要用 MIDI）
  }
}
