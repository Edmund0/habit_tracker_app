import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'settings_modal_web.dart';
import 'settings_modal_io.dart';

class SettingsModal extends StatelessWidget {
  const SettingsModal({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const SettingsModalWeb();
    }
    return const SettingsModalIO();
  }
}
