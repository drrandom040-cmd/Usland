import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usland/state/notification_state.dart';
import 'package:usland/utils/design.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _uslandEnabled = true;
  bool _autoExpand = true;
  double _autoDismissSeconds = 4.0;
  double _pillTopOffset = 8.0;
  List<Map<String, String>> _installedApps = [];
  Set<String> _mutedPackages = {};

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _uslandEnabled = prefs.getBool('usland_enabled') ?? true;
      _autoExpand = prefs.getBool('auto_expand') ?? true;
      _autoDismissSeconds = prefs.getDouble('auto_dismiss_seconds') ?? 4.0;
      _pillTopOffset = prefs.getDouble('pill_top_offset') ?? 8.0;
      _mutedPackages =
          Set.from(prefs.getStringList('muted_packages') ?? []);
    });
  }

  Future<void> _savePref(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) await prefs.setBool(key, value);
    if (value is double) await prefs.setDouble(key, value);
    if (value is String) await prefs.setString(key, value);
  }

  Future<void> _toggleMute(String packageName, bool mute) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (mute) {
        _mutedPackages.add(packageName);
      } else {
        _mutedPackages.remove(packageName);
      }
    });
    await prefs.setStringList('muted_packages', _mutedPackages.toList());
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NotificationState>();

    return Scaffold(
      backgroundColor: UslandDesign.background,
      appBar: AppBar(
        backgroundColor: UslandDesign.background,
        title: Text(
          'Usland Settings',
          style: GoogleFonts.dmSans(
            color: UslandDesign.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: UslandDesign.periwinkle),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionLabel('General'),
          _card([
            _toggle(
              label: 'Enable Usland',
              subtitle: 'Show the overlay pill',
              value: _uslandEnabled,
              onChanged: (v) {
                setState(() => _uslandEnabled = v);
                _savePref('usland_enabled', v);
              },
            ),
            _divider(),
            _toggle(
              label: 'Auto-expand',
              subtitle: 'Expand pill on new notifications',
              value: _autoExpand,
              onChanged: (v) {
                setState(() => _autoExpand = v);
                _savePref('auto_expand', v);
              },
            ),
          ]),
          const SizedBox(height: 16),
          _sectionLabel('Appearance'),
          _card([
            _toggle(
              label: 'Logo animation',
              subtitle: 'Rotate logo in idle state',
              value: state.logoAnimationEnabled,
              onChanged: (v) => state.toggleLogoAnimation(v),
            ),
            _divider(),
            _toggle(
              label: 'Glow pulse',
              subtitle: 'Periwinkle ambient glow on logo',
              value: state.glowEnabled,
              onChanged: (v) => state.toggleGlow(v),
            ),
          ]),
          const SizedBox(height: 16),
          _sectionLabel('Timing'),
          _card([
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Auto-dismiss delay',
                    style: GoogleFonts.dmSans(
                      color: UslandDesign.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${_autoDismissSeconds.round()}s',
                    style: GoogleFonts.dmSans(
                      color: UslandDesign.periwinkle,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Slider(
              value: _autoDismissSeconds,
              min: 2,
              max: 10,
              divisions: 8,
              activeColor: UslandDesign.periwinkle,
              inactiveColor: UslandDesign.periwinkle.withOpacity(0.2),
              onChanged: (v) {
                setState(() => _autoDismissSeconds = v);
                _savePref('auto_dismiss_seconds', v);
              },
            ),
          ]),
          const SizedBox(height: 16),
          _sectionLabel('Position'),
          _card([
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pill top offset',
                    style: GoogleFonts.dmSans(
                      color: UslandDesign.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${_pillTopOffset.round()}px',
                    style: GoogleFonts.dmSans(
                      color: UslandDesign.periwinkle,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Slider(
              value: _pillTopOffset,
              min: 0,
              max: 48,
              divisions: 48,
              activeColor: UslandDesign.periwinkle,
              inactiveColor: UslandDesign.periwinkle.withOpacity(0.2),
              onChanged: (v) {
                setState(() => _pillTopOffset = v);
                _savePref('pill_top_offset', v);
              },
            ),
          ]),
          const SizedBox(height: 16),
          _sectionLabel('Muted Apps'),
          if (_installedApps.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No apps loaded',
                style: GoogleFonts.dmSans(
                  color: UslandDesign.textSecondary,
                  fontSize: 13,
                ),
              ),
            )
          else
            _card(
              _installedApps.map((app) {
                final pkg = app['package'] ?? '';
                final name = app['name'] ?? pkg;
                final isMuted = _mutedPackages.contains(pkg);
                return Column(
                  children: [
                    _toggle(
                      label: name,
                      subtitle: pkg,
                      value: !isMuted,
                      onChanged: (v) => _toggleMute(pkg, !v),
                    ),
                    if (app != _installedApps.last) _divider(),
                  ],
                );
              }).toList(),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.dmSans(
          color: UslandDesign.periwinkle,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return Divider(
      color: UslandDesign.textSecondary.withOpacity(0.1),
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _toggle({
    required String label,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        label,
        style: GoogleFonts.dmSans(
          color: UslandDesign.textPrimary,
          fontSize: 14,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.dmSans(
                color: UslandDesign.textSecondary,
                fontSize: 12,
              ),
            )
          : null,
      value: value,
      activeColor: UslandDesign.periwinkle,
      onChanged: onChanged,
    );
  }
}
