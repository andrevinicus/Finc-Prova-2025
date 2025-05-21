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

  String getBankLogoUrl(String code) {
    final domain = BankDomains.getDomain(code);
    if (domain.isNotEmpty) {
      return 'https://img.logo.dev/$domain?token=pk_TboSWrKJRDKchCKkTSXr3Q';
    }
    return '';
  }

  String _sortOrder = 'asc'; // 'asc' = ordem alfabética crescente, 'desc' = decrescente
  ScrollController _scrollController = ScrollController();

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
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar bancos')),
      );
    }
  }

  void _filterBanks() {
    _applyFilters();
  }

  void _applyFilters() {
    final query = searchController.text.toLowerCase();

    // Filtra pelo texto, ignorando o prefixo "BCO" no início do nome
    filteredBanks = banks.where((bank) {
      final originalName = bank['name'].toString();
      final cleanName = originalName.replaceAll(RegExp(r'^BCO\s*'), '').toLowerCase();
      return cleanName.contains(query);
    }).toList();

    // Ordena baseado na opção selecionada, também ignorando "BCO" no início
    filteredBanks.sort((a, b) {
      final nameA = a['name'].toString().replaceAll(RegExp(r'^BCO\s*'), '');
      final nameB = b['name'].toString().replaceAll(RegExp(r'^BCO\s*'), '');
      if (_sortOrder == 'asc') {
        return nameA.compareTo(nameB);
      } else {
        return nameB.compareTo(nameA);
      }
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Selecionar Banco',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar banco...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // Dropdown do filtro logo abaixo da busca
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list, color: Colors.white70),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _sortOrder,
                          dropdownColor: const Color(0xFF2A2A2A),
                          isExpanded: true,
                          iconEnabledColor: Colors.white,
                          underline: Container(),
                          items: {
                            'asc': 'Ordem Alfabética (A-Z)',
                            'desc': 'Ordem Alfabética (Z-A)',
                          }.entries
                              .map((entry) => DropdownMenuItem<String>(
                                    value: entry.key,
                                    child: Text(
                                      entry.value,
                                      style: const TextStyle(color: Colors.white),
                                    ),
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
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: filteredBanks.length,
                    itemBuilder: (context, index) {
                      final bank = filteredBanks[index];
                      final code = bank['code'].toString();
                      final logoUrl = getBankLogoUrl(code);
                      final name = bank['name']
                          .toString()
                          .replaceAll(RegExp(r'^BCO\s*'), '');

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context, bank);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
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
                                    color: Colors.grey[800],
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
                                              color: Colors.white,
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
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Código: $code',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                ),
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
  }
}
