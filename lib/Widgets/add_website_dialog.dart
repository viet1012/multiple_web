import 'package:flutter/material.dart';

void showAddWebsiteBottomSheet({
  required BuildContext context,
  required void Function(String title, String url) onAdd,
}) {
  final titleController = TextEditingController();
  final urlController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildTextField(
                controller: titleController,
                label: 'Tên website',
                icon: Icons.title,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Vui lòng nhập tên.'
                    : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: urlController,
                label: 'Địa chỉ URL (http/https)',
                icon: Icons.link,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập URL.';
                  }
                  final urlPattern = RegExp(r'^(http|https)://');
                  if (!urlPattern.hasMatch(value)) {
                    return 'URL phải bắt đầu bằng http:// hoặc https://';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              _buildActionButtons(
                context: context,
                onSubmit: () {
                  if (formKey.currentState!.validate()) {
                    onAdd(
                      titleController.text.trim(),
                      urlController.text.trim(),
                    );
                    Navigator.of(context).pop(); // Close bottom sheet
                  }
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildHeader() {
  return Row(
    children: const [
      Icon(Icons.language, color: Colors.indigo, size: 30),
      SizedBox(width: 12),
      Text(
        'Thêm Website Mới',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
          letterSpacing: 0.5,
        ),
      ),
    ],
  );
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  required String? Function(String?) validator,
}) {
  return TextFormField(
    controller: controller,
    validator: validator,
    style: const TextStyle(fontSize: 15),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black87),
      prefixIcon: Icon(icon, color: Colors.indigo),
      filled: true,
      fillColor: Colors.indigo.shade50.withOpacity(0.15),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.indigo, width: 1.6),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

Widget _buildActionButtons({
  required BuildContext context,
  required VoidCallback onSubmit,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          foregroundColor: Colors.grey.shade700,
          side: BorderSide(color: Colors.grey.shade400),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel', style: TextStyle(fontSize: 15)),
      ),
      const SizedBox(width: 16),
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 3,
        ),
        label: const Text(
          'Add',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        onPressed: onSubmit,
      ),
    ],
  );
}


