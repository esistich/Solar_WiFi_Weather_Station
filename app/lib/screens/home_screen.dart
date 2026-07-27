import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';
import 'detail_screen.dart';
import 'device_setup_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _autoRefresh;
  String? _selectedDeviceId; // Für Tablet-Layout

  @override
  void initState() {
    super.initState();
    _autoRefresh = Timer.periodic(
      const Duration(minutes: 5),
      (_) => context.read<DeviceProvider>().refreshAll(),
    );
  }

  @override
  void dispose() {
    _autoRefresh?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeviceProvider>();
    final width = MediaQuery.of(context).size.width;

    // Material 3 Breakpoints:
    // Compact (< 600dp), Medium (600-840dp), Expanded (> 840dp)
    // Wir nutzen das Master-Detail Layout ab 'Expanded' (Tablet/Landscape)
    final isExpanded = width >= 840;

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.refreshAll(),
            tooltip: l10n.refresh,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: isExpanded
          ? _buildTabletLayout(provider) 
          : _buildMobileLayout(provider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSetup(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.addDevice),
      ),
    );
  }

  // --- MOBIL LAYOUT (Liste) ---
  Widget _buildMobileLayout(DeviceProvider provider) {
    if (provider.devices.isEmpty) return _EmptyState(onAdd: () => _openSetup(context));

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return RefreshIndicator(
      onRefresh: provider.refreshAll,
      child: ListView.builder(
        padding: EdgeInsets.only(top: 8, bottom: 80 + bottomPadding), // Platz für FAB + System-Nav
        itemCount: provider.devices.length,
        itemBuilder: (context, index) {
          final device = provider.devices[index];
          return TileCard(
            device: device,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailScreen(device: device)),
            ),
            onRefresh: () => provider.refreshDevice(device.id),
          );
        },
      ),
    );
  }

  // --- TABLET LAYOUT (Master-Detail) ---
  Widget _buildTabletLayout(DeviceProvider provider) {
    if (provider.devices.isEmpty) return _EmptyState(onAdd: () => _openSetup(context));

    // Falls nichts ausgewählt, nimm das erste Gerät
    if (_selectedDeviceId == null && provider.devices.isNotEmpty) {
      _selectedDeviceId = provider.devices.first.id;
    }

    final selectedDevice = provider.devices.firstWhere(
      (d) => d.id == _selectedDeviceId,
      orElse: () => provider.devices.first,
    );

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Row(
      children: [
        // Linke Spalte: Liste
        SizedBox(
          width: 350,
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 80 + bottomPadding),
            itemCount: provider.devices.length,
            itemBuilder: (context, index) {
              final device = provider.devices[index];
              final isSelected = device.id == _selectedDeviceId;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TileCard(
                  device: device,
                  isSelected: isSelected, // Neues Property
                  onTap: () => setState(() => _selectedDeviceId = device.id),
                  onRefresh: () => provider.refreshDevice(device.id),
                ),
              );
            },
          ),
        ),
        const VerticalDivider(width: 1),
        // Rechte Spalte: Details
        Expanded(
          child: DetailScreen(key: ValueKey(_selectedDeviceId), device: selectedDevice, isEmbedded: true),
        ),
      ],
    );
  }

  void _openSetup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DeviceSetupScreen()),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wb_cloudy_outlined, size: 72, color: Colors.grey),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.noDevices, style: const TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 24),
          FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: Text(AppLocalizations.of(context)!.addDevice)),
        ],
      ),
    );
  }
}
