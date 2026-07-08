import 'package:flutter/material.dart';
import 'package:lapak_tani/services/user_service.dart';
import 'package:lapak_tani/models/user_model.dart';
import 'package:lapak_tani/widgets/loading_widget.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final _userService = UserService();
  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final users = await _userService.getAllUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat pengguna: $e')),
        );
      }
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin': return Colors.red;
      case 'petani': return Colors.green;
      case 'pembeli': return Colors.blue;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }

    if (_users.isEmpty) {
      return const Center(child: Text('Tidak ada pengguna ditemukan.'));
    }

    return RefreshIndicator(
      onRefresh: _fetchUsers,
      child: ListView.separated(
        itemCount: _users.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final user = _users[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRoleColor(user.role),
              child: Text(user.name[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
            ),
            title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(user.email),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoleColor(user.role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getRoleColor(user.role)),
              ),
              child: Text(
                user.role.toUpperCase(),
                style: TextStyle(fontSize: 10, color: _getRoleColor(user.role), fontWeight: FontWeight.bold),
              ),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Detail Pengguna'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nama: ${user.name}'),
                      Text('Email: ${user.email}'),
                      Text('Role: ${user.role}'),
                      Text('No HP: ${user.phone.isNotEmpty ? user.phone : '-'}'),
                      Text('Alamat: ${user.address.isNotEmpty ? user.address : '-'}'),
                      Text('Terdaftar: ${user.createdAt.toString().substring(0, 10)}'),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
