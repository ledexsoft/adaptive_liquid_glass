import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/cupertino.dart';

class SearchDividerSwitchDemoPage extends StatefulWidget {
  const SearchDividerSwitchDemoPage({super.key});

  @override
  State<SearchDividerSwitchDemoPage> createState() =>
      _SearchDividerSwitchDemoPageState();
}

class _SearchDividerSwitchDemoPageState
    extends State<SearchDividerSwitchDemoPage> {
  bool _notifications = true;
  bool _darkMode = false;
  bool _autoUpdates = true;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(title: 'Search · Divider · Switch List'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 24),
          AdaptiveSearchBar(
            hintText: 'Buscar productos…',
            onChanged: (value) => setState(() => _query = value),
            onClear: () => setState(() => _query = ''),
          ),
          if (_query.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Buscando: $_query'),
            ),
          const SizedBox(height: 24),
          AdaptiveDivider(indent: 0),
          const SizedBox(height: 8),
          AdaptiveSwitchListTile(
            leading: const Icon(CupertinoIcons.bell),
            title: const Text('Notificaciones'),
            subtitle: const Text('Alertas de pedidos y promociones'),
            value: _notifications,
            onChanged: (v) => setState(() => _notifications = v),
            activeColor: CupertinoColors.systemGreen,
          ),
          AdaptiveDivider(indent: 44),
          AdaptiveSwitchListTile(
            leading: const Icon(CupertinoIcons.moon),
            title: const Text('Modo oscuro'),
            subtitle: const Text('Aplicar a toda la app'),
            value: _darkMode,
            onChanged: (v) => setState(() => _darkMode = v),
          ),
          AdaptiveDivider(indent: 44),
          AdaptiveSwitchListTile(
            leading: const Icon(CupertinoIcons.cloud_download),
            title: const Text('Actualizaciones automáticas'),
            value: _autoUpdates,
            onChanged: (v) => setState(() => _autoUpdates = v),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
