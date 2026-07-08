import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';
import 'package:apiland/core/network/api_error.dart';
import 'package:apiland/core/widgets/error_state.dart';
import 'package:apiland/core/widgets/floating_nav_fab.dart';
import 'package:apiland/features/login/data/user.dart';
import 'package:apiland/features/users/data/user_service.dart';
import 'package:apiland/features/users/new_user_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final UserService _service = UserService();
  late Future<List<User>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getUsers();
  }

  Future<void> _reload() async {
    final f = _service.getUsers();
    setState(() {
      _future = f;
    });
    await f;
  }

  Future<void> _addUser() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewUserScreen()),
    );
    // Al volver del form, refresca la lista (por si se creó uno).
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
        actions: [
          IconButton(
            onPressed: _addUser,
            icon: const Icon(Icons.add),
            tooltip: 'Nuevo usuario',
          ),
        ],
      ),
      body: FutureBuilder<List<User>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorState(
              title: 'No se pudieron cargar los usuarios',
              message: apiErrorMessage(snapshot.error!),
              onRetry: _reload,
            );
          }
          final users = snapshot.data ?? const <User>[];
          if (users.isEmpty) {
            return const Center(child: Text('No hay usuarios todavía'));
          }
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final u = users[i];
                final fullName = [
                  u.username,
                  u.lastName,
                ].where((s) => s.isNotEmpty).join(' ');
                return Card(
                  color: AppColors.secondarySurface,
                  child: ListTile(
                    leading: const Icon(
                      Icons.person_outline,
                      color: AppColors.textPrimary,
                    ),
                    title: Text(
                      fullName.isEmpty ? u.username : fullName,
                      style: const TextStyle(
                        color: AppColors.textStandout,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      [
                        u.email,
                        if (u.position.isNotEmpty) u.position,
                      ].join(' · '),
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    trailing: _RoleBadge(role: u.role),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: const FloatingNavFab(currentRoute: '/users'),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

/// Chip con el rol del usuario.
class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        role.wire,
        style: const TextStyle(
          fontSize: AppTextSizes.xs,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
