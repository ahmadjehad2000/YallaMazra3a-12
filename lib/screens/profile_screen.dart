import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      backgroundImage: user?.photoUrl != null
                          ? NetworkImage(user!.photoUrl!)
                          : null,
                      child: user?.photoUrl == null
                          ? Text(
                              user?.name.isNotEmpty == true
                                  ? user!.name.substring(0, 1)
                                  : "؟",
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
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
                            user?.name ?? "ضيف",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? "بدون بريد إلكتروني",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          if (user?.phoneNumber != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              user!.phoneNumber!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Statistics
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(context, "المفضلة", 
                        user?.favoriteVillas.length.toString() ?? "0"),
                    _buildStatItem(context, "الحجوزات", 
                        user?.bookings.length.toString() ?? "0"),
                    _buildStatItem(context, "التقييمات", "0"),
                  ],
                ),
                
                const SizedBox(height: 32),
                const Divider(),
                
                // Settings
                _buildSettingsItem(
                  context,
                  Icons.edit,
                  "تعديل الملف الشخصي",
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("ميزة تعديل الملف الشخصي قيد التطوير"),
                      ),
                    );
                  },
                ),
                _buildSettingsItem(
                  context,
                  Icons.favorite,
                  "المزارع المفضلة",
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("ميزة المفضلة قيد التطوير"),
                      ),
                    );
                  },
                ),
                _buildSettingsItem(
                  context,
                  Icons.history,
                  "سجل الحجوزات",
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("ميزة سجل الحجوزات قيد التطوير"),
                      ),
                    );
                  },
                ),
                _buildSettingsItem(
                  context,
                  Icons.payment,
                  "طرق الدفع",
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("ميزة طرق الدفع قيد التطوير"),
                      ),
                    );
                  },
                ),
                _buildSettingsItem(
                  context,
                  Icons.settings,
                  "الإعدادات",
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("ميزة الإعدادات قيد التطوير"),
                      ),
                    );
                  },
                ),
                _buildSettingsItem(
                  context,
                  Icons.help_outline,
                  "المساعدة والدعم",
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("ميزة المساعدة والدعم قيد التطوير"),
                      ),
                    );
                  },
                ),
                _buildSettingsItem(
                  context,
                  Icons.info_outline,
                  "عن التطبيق",
                  () {
                    _showAboutDialog(context);
                  },
                ),
                
                const SizedBox(height: 16),
                const Divider(),
                
                // Logout button
                _buildSettingsItem(
                  context,
                  Icons.logout,
                  "تسجيل الخروج",
                  () {
                    _confirmLogout(context);
                  },
                  isLogout: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(BuildContext context, String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: isLogout ? Colors.red : Colors.grey[700],
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isLogout ? Colors.red : Colors.black,
                fontWeight: isLogout ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (!isLogout)
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تسجيل الخروج"),
        content: const Text("هل أنت متأكد من تسجيل الخروج؟"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<AuthProvider>(context, listen: false).signOut();
              
              // Navigate to login screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            child: const Text(
              "تسجيل الخروج",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("عن التطبيق"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                Icons.villa_rounded,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                "يلا مزرعة",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                "الإصدار 1.0.0",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "تطبيق يلا مزرعة هو منصة لاستئجار المزارع والاستراحات في المملكة العربية السعودية.",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              "جميع الحقوق محفوظة © 2023",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("إغلاق"),
          ),
        ],
      ),
    );
  }
}
