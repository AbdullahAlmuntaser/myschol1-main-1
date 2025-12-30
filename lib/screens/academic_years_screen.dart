import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/academic_year_provider.dart';
import 'add_edit_academic_year_dialog.dart';

class AcademicYearsScreen extends StatelessWidget {
  static const routeName = '/academic-years';

  const AcademicYearsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الأعوام الدراسية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => const AddEditAcademicYearDialog(),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: Provider.of<AcademicYearProvider>(context, listen: false)
            .fetchAcademicYears(),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : Consumer<AcademicYearProvider>(
                    builder: (ctx, academicYearProvider, child) =>
                        ListView.builder(
                      itemCount: academicYearProvider.academicYears.length,
                      itemBuilder: (ctx, i) {
                        final academicYear =
                            academicYearProvider.academicYears[i];
                        return ListTile(
                          title: Text(academicYear.name),
                          subtitle: Text(
                              '${academicYear.startDate} - ${academicYear.endDate}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (academicYear.isActive)
                                const Chip(
                                  label: Text('نشط'),
                                  backgroundColor: Colors.green,
                                ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AddEditAcademicYearDialog(
                                      academicYear: academicYear,
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('تأكيد الحذف'),
                                      content: const Text(
                                          'هل أنت متأكد أنك تريد حذف هذا العام الدراسي؟'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('إلغاء'),
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('حذف'),
                                          onPressed: () {
                                            Provider.of<AcademicYearProvider>(
                                                    context,
                                                    listen: false)
                                                .deleteAcademicYear(
                                                    academicYear.id!);
                                            Navigator.of(ctx).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              if (!academicYear.isActive)
                                ElevatedButton(
                                  child: const Text('تنشيط'),
                                  onPressed: () {
                                    Provider.of<AcademicYearProvider>(context,
                                            listen: false)
                                        .setActiveAcademicYear(academicYear);
                                  },
                                )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
