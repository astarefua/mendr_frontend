import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? selectedRole;

  Future<void> _handleSelection(BuildContext context, String role) async {
    final prefs = await SharedPreferences.getInstance();
    final hasSignedUp = prefs.getBool('hasSignedUp_$role') ?? false;

    if (hasSignedUp) {
      Navigator.pushNamed(context, '/login', arguments: role);
    } else {
      Navigator.pushNamed(context, '/signup/$role');
    }
  }

  void _onRoleSelected(String role) {
    setState(() {
      selectedRole = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Your Role"),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Role Information"),
                  content: const Text(
                    "Select your role to proceed. If you are a new user, you can sign up. If you already have an account, you can log in.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1.0, color: Colors.grey.shade300),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            children: [
              Image.asset(
                'assets/images/mendr logo.png',
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              // Role selection cards
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ModernRoleCard(
                    title: 'Doctor',
                    subtitle: 'Provide medical consultation',
                    icon: Icons.medical_services_rounded,
                    role: 'doctor',
                    isSelected: selectedRole == 'doctor',
                    onTap: () => _onRoleSelected('doctor'),
                  ),
                  const SizedBox(height: 20),
                  ModernRoleCard(
                    title: 'Patient',
                    subtitle: 'Get medical consultation',
                    icon: Icons.person_rounded,
                    role: 'patient',
                    isSelected: selectedRole == 'patient',
                    onTap: () => _onRoleSelected('patient'),
                  ),
                  const SizedBox(height: 20),
                  ModernRoleCard(
                    title: 'Administrator',
                    subtitle: 'Manage platform operations',
                    icon: Icons.admin_panel_settings_rounded,
                    role: 'admin',
                    isSelected: selectedRole == 'admin',
                    onTap: () => _onRoleSelected('admin'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: selectedRole != null
                  ? () => _handleSelection(context, selectedRole!)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedRole != null
                    ? Colors.green
                    : Colors.grey[300],
                foregroundColor: selectedRole != null
                    ? Colors.white
                    : Colors.grey[500],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: selectedRole != null
                        ? Colors.green
                        : Colors.grey[300]!,
                    width: selectedRole != null ? 2 : 1,
                  ),
                ),
                elevation: 0,
              ),
              child: Text(
                'Get Started',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ModernRoleCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String role;
  final bool isSelected;
  final VoidCallback onTap;

  const ModernRoleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<ModernRoleCard> createState() => _ModernRoleCardState();
}

class _ModernRoleCardState extends State<ModernRoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _animationController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _animationController.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isSelected
                      ? Colors.green
                      : (_isPressed ? Colors.green : Colors.grey[300]!),
                  width: widget.isSelected ? 0.8 : (_isPressed ? 0.8 : 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    child: Icon(widget.icon, size: 32, color: Colors.black54),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
