import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/models/professional_model.dart';
import 'package:mini_fiverr/providers/data_provider.dart';
import 'package:mini_fiverr/screens/client/professional_profile_screen.dart';
import 'package:mini_fiverr/utils/constants.dart';
import 'package:mini_fiverr/widgets/professional_tile.dart';

class FindTalentScreen extends StatefulWidget {
  const FindTalentScreen({super.key});

  @override
  State<FindTalentScreen> createState() => _FindTalentScreenState();
}

class _FindTalentScreenState extends State<FindTalentScreen> {
  final TextEditingController _search = TextEditingController();
  String _filter = 'All';
  String _query = '';
  Timer? _timer;

  @override
  void dispose() {
    _search.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DataProvider data = context.watch<DataProvider>();
    List<ProfessionalModel> list = data.professionals.where((ProfessionalModel p) {
      final String hay = '${p.name} ${p.title} ${p.skills.join(' ')}'.toLowerCase();
      final bool matchesSearch = _query.isEmpty || hay.contains(_query.toLowerCase());
      final bool matchesFilter = _filter == 'All' || p.skills.join(' ').toLowerCase().contains(_filter.toLowerCase());
      return matchesSearch && matchesFilter;
    }).toList();

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _search,
            onChanged: (String value) {
              _timer?.cancel();
              _timer = Timer(const Duration(milliseconds: 300), () {
                if (mounted) {
                  setState(() => _query = value.trim());
                }
              });
            },
            decoration: InputDecoration(
              hintText: 'Search skills, titles, or names...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _search.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
        ),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.skillFilters.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, int i) {
              final String value = AppConstants.skillFilters[i];
              final bool active = value == _filter;
              return ChoiceChip(
                selected: active,
                label: Text(value),
                onSelected: (_) => setState(() => _filter = value),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: list.isEmpty
              ? Center(child: Text("No talent found for '$_query'"))
              : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, int i) {
                    final ProfessionalModel p = list[i];
                    final bool isFavorite = data.currentUser?.favoriteProfessionalIds.contains(p.id) ?? false;
                    return ProfessionalTile(
                      professional: p,
                      isFavorite: isFavorite,
                      onToggleFavorite: () => data.toggleFavorite(p.id),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(builder: (_) => ProfessionalProfileScreen(professional: p)),
                      ),
                      onHire: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(builder: (_) => ProfessionalProfileScreen(professional: p)),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
