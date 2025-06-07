import 'dart:convert';
import 'package:finc/screens/create_banks/constants/banks_domains.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BankOptionsModal extends StatefulWidget {
  const BankOptionsModal({super.key});

  @override
  State<BankOptionsModal> createState() => _BankOptionsModalState();
}

class _BankOptionsModalState extends State<BankOptionsModal> {
  List<dynamic> banks = [];
  List<dynamic> filteredBanks = [];
  bool isLoading = true;

  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _sortOrder = 'asc';

  String getBankLogoUrl(String code) {
    final domain = BankDomains.getDomain(code);
    if (domain.isNotEmpty) {
      return 'https://img.logo.dev/$domain?token=pk_TboSWrKJRDKchCKkTSXr3Q';
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    fetchBanks();
    searchController.addListener(_filterBanks);
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchBanks() async {
    final url = Uri.parse('https://brasilapi.com.br/api/banks/v1');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final allBanks = json.decode(response.body) as List<dynamic>;
      setState(() {
        banks = allBanks.where((bank) {
          final code = bank['code'].toString();
          return BankDomains.getDomain(code).isNotEmpty;
        }).toList();

        _applyFilters();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao carregar bancos')),
        );
      }
    }
  }

  void _filterBanks() => _applyFilters();

  void _applyFilters() {
    final query = searchController.text.toLowerCase();
    filteredBanks = banks.where((bank) {
      final originalName = bank['name'].toString();
      final cleanName = originalName.replaceAll(RegExp(r'^BCO\s*'), '').toLowerCase();
      return cleanName.contains(query);
    }).toList();

    filteredBanks.sort((a, b) {
      final nameA = a['name'].toString().replaceAll(RegExp(r'^BCO\s*'), '');
      final nameB = b['name'].toString().replaceAll(RegExp(r'^BCO\s*'), '');
      return _sortOrder == 'asc' ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 1,
      minChildSize: 0.4,
      maxChildSize: 1,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5), // Alterado para cinza claro
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400], // Alterado para cinza mais claro
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(color: Colors.black87), // Alterado para preto
                  decoration: InputDecoration(
                    hintText: 'Buscar banco...',
                    hintStyle: TextStyle(color: Colors.grey[600]), // Alterado para cinza mais escuro
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white, // Alterado para branco
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.filter_list, color: Colors.black54), // Alterado para preto
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _sortOrder,
                        dropdownColor: Colors.white, // Alterado para branco
                        isExpanded: true,
                        iconEnabledColor: Colors.black54, // Alterado para preto
                        underline: Container(),
                        items: {
                          'asc': 'Ordem Alfabética (A-Z)',
                          'desc': 'Ordem Alfabética (Z-A)',
                        }.entries
                            .map((entry) => DropdownMenuItem<String>(
                                  value: entry.key,
                                  child: Text(entry.value, style: const TextStyle(color: Colors.black87)), // Alterado
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null && value != _sortOrder) {
                            setState(() {
                              _sortOrder = value;
                              _applyFilters();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemCount: filteredBanks.length,
                        itemBuilder: (context, index) {
                          final bank = filteredBanks[index];
                          final code = bank['code'].toString();
                          final logoUrl = getBankLogoUrl(code);
                          final name = bank['name'].toString().replaceAll(RegExp(r'^BCO\s*'), '');

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: InkWell(
                              onTap: () => Navigator.pop(context, bank),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white, // Alterado para branco
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2), // Alterado para sombra suave
                                      offset: const Offset(0, 2),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100], // Alterado para cinza bem claro
                                        borderRadius: BorderRadius.circular(8),
                                        image: logoUrl.isNotEmpty
                                            ? DecorationImage(
                                                image: NetworkImage(logoUrl),
                                                fit: BoxFit.contain,
                                              )
                                            : null,
                                      ),
                                      child: logoUrl.isEmpty
                                          ? Center(
                                              child: Text(
                                                name.isNotEmpty ? name[0] : '',
                                                style: const TextStyle(
                                                  color: Colors.black54, // Alterado para preto
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              color: Colors.black87, // Alterado para preto
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Código: $code',
                                            style: TextStyle(
                                              color: Colors.grey[600], // Alterado para cinza escuro
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}