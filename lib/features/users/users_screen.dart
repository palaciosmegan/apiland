import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';
import 'package:apiland/core/network/api_error.dart';
import 'package:apiland/core/widgets/error_state.dart';
import 'package:apiland/core/widgets/floating_nav_fab.dart';
import 'package:apiland/core/widgets/role_badge.dart';
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

  List<User> _users = const [];
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _service.getUsers();
      if (!mounted) return;
      setState(() {
        _users = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _addUser() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewUserScreen()),
    );
    await _load(); // refresca al volver (por si se creó uno)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      body: _buildBody(),
      floatingActionButton: FloatingNavFab(
        currentRoute: '/users',
        onAdd: _addUser,
        addEnabled: _error == null,
        addTooltip: 'Nuevo usuario',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ErrorState(
        title: 'No se pudieron traer los usuarios',
        message: apiErrorMessage(_error!),
        onRetry: _load,
      );
    }
    if (_users.isEmpty) {
      return const Center(child: Text('No hay usuarios todavía'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: _users.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final u = _users[i];
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
              trailing: RoleBadge(role: u.role),
            ),
          );
        },
      ),
    );
  }
}
