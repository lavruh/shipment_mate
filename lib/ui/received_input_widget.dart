import 'package:flutter/material.dart';

class ReceivedInput extends StatefulWidget {
  final int initialValue;
  final Function(int) onConfirm;

  const ReceivedInput({
    super.key,
    required this.initialValue,
    required this.onConfirm,
  });

  @override
  State<ReceivedInput> createState() => _ReceivedInputState();
}

class _ReceivedInputState extends State<ReceivedInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Center(
        child: SizedBox(
          width: 90, // 90pt width
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              isDense: true,
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.black26,
              suffixIcon: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.check, color: Colors.white, size: 20),
                onPressed: () {
                  final val = int.tryParse(_controller.text) ?? widget.initialValue;
                  widget.onConfirm(val);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
