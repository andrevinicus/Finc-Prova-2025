import 'package:finc/screens/comuniti/comunidadeScreen/bottom_nav_bar.dart';
import 'package:flutter/material.dart';


class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  int _currentIndex = 3; // Perfil é a aba 3

  final List<Widget> _screens = [
    Center(child: Text('Home')),
    Center(child: Text('Explorar')),
    Center(child: Text('Notificações')),
    const PerfilContent(), // aba 3 = Perfil
    Center(child: Text('Configurações')),
  ];

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
      ),
    );
  }
}

class PerfilContent extends StatelessWidget {
  const PerfilContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Icon(Icons.arrow_back, color: theme.textTheme.bodyLarge?.color),
                    ),
                  ),
                  Text(
                    'Perfil',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(Icons.settings, color: theme.textTheme.bodyLarge?.color),
                  ),
                ],
              ),
            ),

            // Header do perfil
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundImage: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCY0R-WeauGAyM2c_mqdTh33W_TEPLxRwIfftLqyRJUF-KRqRb19AfFnVB83qKjS5SZ7HH0pGGfRntMQIrXX_ffQ1OBv5WDLBhEgriahNzm_r9gctbY8NEpEMjronBUhJfOQip4rWPUe8TQ_kRI73zFAzXL6bD0Vy_ID_C_8VrZR1h-fbydtii6-hqmETDlRGFuEiOQk-TKvQp7grWet0IEo0WFm_SKTHOEsPTx3L55ybQjjeoQg1dUTkH7ZxashJgKrA1bI1LFmzs',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ana Oliveira',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@ana.investe',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Apaixonada por finanças pessoais e investimentos de longo prazo. Compartilhando minha jornada para a independência financeira.',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor.withOpacity(0.2),
                      foregroundColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'Editar Perfil',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statCard('1.250', 'Publicações', theme),
                  _statCard('5.8K', 'Seguidores', theme),
                  _statCard('348', 'Seguindo', theme),
                ],
              ),
            ),

            // Financial Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _financialCard('Patrimônio', 'R\$ 148.721,50', theme),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _financialCard('Performance Mês', '+2.3%', theme, isSuccess: true),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              color: theme.scaffoldBackgroundColor.withOpacity(0.8),
              child: Row(
                children: [
                  _tabItem('Publicações', isSelected: true, theme: theme),
                  _tabItem('Conquistas', theme: theme),
                  _tabItem('Informações', theme: theme),
                ],
              ),
            ),

            // Posts Grid
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                children: [
                  _postImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBV6KhWjmwtikKTPRGWF5UxnY67ocTQkRjopuJGYCP1NdfgSsiYI-SaY5QO7K1d4Ibn337lSyMrdXG6RgY-JuPUm4QZyw7WeYA9Bn5lMnnvqv3lVakvYnroXMEafw2AB6RuQWqDUX9Qu3muNPuHO96THvo3ZESj_tSgcs8-H_drTwIQxwacYrnaBziWAVys-fs2Y8EjAV4OdRlyrJ-2eujAtXf8iaMkmMNW1N98AkPQ4xcmVcbDOhyWennfdJkPLi8S36L624fA9tY'),
                  _postImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDMQ0VIW2vMNdBnTo2_mccMmykZwwpgz0CL7sf_ey3vIkXd1Opq4cZ647bF2C7nWUA5LNYyoj_h1RgH7X3fVHS1FC5QYz9XGW9H3-ZBrcLjLejdfzmv03FN7erwVellm8bB7RsPjsmhS-pFPBnlrI73Buw5mUz5qW-AJNHRI1oHKFrgfyXEoyJspQaS0nzUGdpFAnT92-MH3P0K7GpWbsE6G4-ln0l7FNCeRcd93SoXbKDCclm0cHthbcBNGCXdH2NsboB0RnrJ9CI'),
                  _postImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBD7boMuNX1YCoFgizjrtBToJc3bWgYztmSafxDHVJcb6xh4Z9wpE-GeZ4xKhJUUeQ7F3MS3WFXLJXhquYrzUDbOW2bU_oceBEncDmT8539XJU2sZlLSZrYOfnzpgdKk3A4s67-eh4ECIW2XVHCOFHlkU2JwajfRX8gxo4dzh-K3RBxniY0RWS8MmD_FUyMaVAnQPsNcDm2XwNx1l7oVwsU3dvI0iYvrQ39VRCEohSGt5PUgcr7cqDhUbzPCGbvr3PK-yDjuvkXz3k'),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String value, String label, ThemeData theme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          children: [
            Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _financialCard(String label, String value, ThemeData theme, {bool isSuccess = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isSuccess ? Colors.green : theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabItem(String label, {bool isSelected = false, required ThemeData theme}) {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? theme.primaryColor : theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
          Container(
            height: 3,
            color: isSelected ? theme.primaryColor : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _postImage(String url) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
