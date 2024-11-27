// Dart imports
import 'dart:io';

// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';

// Firebase imports
import 'package:cloud_firestore/cloud_firestore.dart';

// PDF related imports
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// Storage & File handling
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

// Utility imports
import 'package:intl/intl.dart';

// Local imports
import '../../../core/models/rpt_model_terapis.dart';

class TerapisReEvaluasiDetail extends StatefulWidget {
  final String rptId;
  final String childName;
  final Map<String, dynamic> reviewStatus;

  const TerapisReEvaluasiDetail({
    Key? key,
    required this.rptId,
    required this.childName,
    required this.reviewStatus,
  }) : super(key: key);

  @override
  State<TerapisReEvaluasiDetail> createState() =>
      _TerapisReEvaluasiDetailState();
}

// Color constants untuk digunakan di seluruh widget
const Color colorPrimary = Color(0xFF1E88E5);
const Color colorSecondary = Color(0xFF64B5F6);
const Color colorSuccess = Color(0xFF4CAF50);
const Color colorPending = Color(0xFF90CAF9);
const Color colorBackground = Color(0xFFF8F9FF);

class _TerapisReEvaluasiDetailState extends State<TerapisReEvaluasiDetail> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  bool _isGeneratingPdf = false;
  RPTModel? _rptData;
  Map<String, dynamic>? _childData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      final rptDoc =
          await _firestore.collection('rpts').doc(widget.rptId).get();
      if (!rptDoc.exists) {
        throw Exception('RPT tidak ditemukan');
      }

      final childId = rptDoc.data()?['childId'];
      if (childId != null) {
        final childDoc =
            await _firestore.collection('children').doc(childId).get();
        if (childDoc.exists) {
          _childData = childDoc.data();
        }
      }

      final titlesSnapshot = await _firestore
          .collection('rpts')
          .doc(widget.rptId)
          .collection('titles')
          .orderBy('createdAt')
          .get();

      List<TitleModel> titles = [];
      for (var titleDoc in titlesSnapshot.docs) {
        final subtitlesSnapshot = await titleDoc.reference
            .collection('subtitles')
            .orderBy('createdAt')
            .get();

        List<SubtitleModel> subtitles = [];
        for (var subtitleDoc in subtitlesSnapshot.docs) {
          final activitiesSnapshot = await subtitleDoc.reference
              .collection('activities')
              .orderBy('createdAt')
              .get();

          List<ActivityModel> activities = activitiesSnapshot.docs
              .map((activityDoc) => ActivityModel.fromFirestore(activityDoc))
              .toList();

          subtitles.add(SubtitleModel.fromFirestore(
            subtitleDoc,
            activities: activities,
            ratings: null,
          ));
        }

        titles.add(TitleModel.fromFirestore(titleDoc, subtitles));
      }

      setState(() {
        _rptData = RPTModel.fromFirestore(rptDoc).copyWith(titles: titles);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateEndDate(SubtitleModel subtitle) async {
    try {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: subtitle.createdAt,
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: colorPrimary,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedDate != null) {
        // Show loading indicator
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 16),
                Text('Menyimpan perubahan...'),
              ],
            ),
            duration: Duration(seconds: 1),
          ),
        );

        // Update Firestore
        await _firestore
            .collection('rpts')
            .doc(widget.rptId)
            .collection('titles')
            .doc(subtitle.titleId) // Pastikan subtitle memiliki titleId
            .collection('subtitles')
            .doc(subtitle.id)
            .update({
          'endDate': Timestamp.fromDate(pickedDate),
          'isCompleted': true,
          'updatedAt': Timestamp.now(),
        });

        // Reload data
        await _loadData();

        // Show success message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tanggal selesai berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error updating end date: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengupdate tanggal selesai: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        // Untuk Android 13 ke atas
        final permissionStatus =
            await Permission.manageExternalStorage.request();

        if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
          if (!mounted) return false;
          final openSettings = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Izin Diperlukan'),
              content: const Text(
                'Aplikasi membutuhkan izin untuk menyimpan dokumen PDF. '
                'Silakan aktifkan izin di pengaturan aplikasi.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Buka Pengaturan'),
                ),
              ],
            ),
          );

          if (openSettings == true) {
            await openAppSettings();
          }
          return false;
        }
        return permissionStatus.isGranted;
      } else {
        // Untuk Android 12 ke bawah
        final storageStatus = await Permission.storage.request();
        if (storageStatus.isDenied || storageStatus.isPermanentlyDenied) {
          if (!mounted) return false;
          final openSettings = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Izin Diperlukan'),
              content: const Text(
                'Aplikasi membutuhkan izin untuk menyimpan dokumen PDF. '
                'Silakan aktifkan izin di pengaturan aplikasi.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Buka Pengaturan'),
                ),
              ],
            ),
          );

          if (openSettings == true) {
            await openAppSettings();
          }
          return false;
        }
        return storageStatus.isGranted;
      }
    }
    return true;
  }

  // 2. Tambahkan method storage path handler di sini
  Future<Directory?> _getStorageDirectory() async {
    if (Platform.isAndroid) {
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          // Untuk Android 13+, coba dapatkan root storage
          Directory? directory = await getExternalStorageDirectory();
          if (directory != null) {
            // Naik ke root storage dan buat folder Download
            String newPath = directory.path;
            final List<String> paths = newPath.split("/");
            String finalPath = "";
            for (int x = 1; x < paths.length; x++) {
              String folder = paths[x];
              if (folder != "Android") {
                finalPath += "/$folder";
              } else {
                break;
              }
            }
            finalPath += "/Download";

            directory = Directory(finalPath);
            if (!await directory.exists()) {
              await directory.create(recursive: true);
            }
            return directory;
          }
        } else {
          // Untuk Android 12 ke bawah
          final directory = await getExternalStorageDirectory();
          if (directory != null) {
            final downloadDir = Directory('${directory.path}/Download');
            if (!await downloadDir.exists()) {
              await downloadDir.create(recursive: true);
            }
            return downloadDir;
          }
        }
      } catch (e) {
        print('Error getting storage directory: $e');
      }
    }
    return null;
  }

  Future<void> _generateAndDownloadPDF() async {
    try {
      setState(() => _isGeneratingPdf = true);

      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Izin penyimpanan diperlukan untuk menyimpan PDF');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white)),
              SizedBox(width: 16),
              Text('Menyiapkan PDF...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Center(
                  child: pw.Text(
                    'Laporan Re Evaluasi',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),

                // Nama Anak
                pw.Text(
                  'Nama Anak: ${_childData?['name'] ?? widget.childName}',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 10),

                // Program Terapi Header
                pw.Text(
                  'Program Terapi',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 10),

                // Table
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(0.5), // No
                    1: const pw.FlexColumnWidth(2.0), // Judul Program
                    2: const pw.FlexColumnWidth(2.0), // Sub Program
                    3: const pw.FlexColumnWidth(2.0), // Aktivitas
                    4: const pw.FlexColumnWidth(1.5), // Tanggal Mulai
                    5: const pw.FlexColumnWidth(1.5), // Tanggal Selesai
                  },
                  children: [
                    // Table Header
                    pw.TableRow(
                      children: [
                        'No',
                        'Judul Program',
                        'Sub Program',
                        'Aktivitas',
                        'Tanggal Mulai',
                        'Tanggal Selesai',
                      ]
                          .map((text) => pw.Padding(
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Text(text,
                                    style: pw.TextStyle(fontSize: 10)),
                              ))
                          .toList(),
                    ),

                    // Table Data
                    ...(_rptData?.titles.expand((title) {
                          int rowNumber = 1;
                          return title.subtitles.expand((subtitle) {
                            bool isFirstTitle = true;
                            bool isFirstSubtitle = true;

                            return subtitle.activities.map((activity) {
                              final row = pw.TableRow(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text(
                                      isFirstTitle ? rowNumber.toString() : '',
                                      style: const pw.TextStyle(fontSize: 10),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text(
                                      isFirstTitle ? title.title : '',
                                      style: const pw.TextStyle(fontSize: 10),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text(
                                      isFirstSubtitle ? subtitle.subtitle : '',
                                      style: const pw.TextStyle(fontSize: 10),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text(
                                      activity.description,
                                      style: const pw.TextStyle(fontSize: 10),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text(
                                      DateFormat('dd/MM/yyyy')
                                          .format(subtitle.createdAt),
                                      style: const pw.TextStyle(fontSize: 10),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text(
                                      subtitle.endDate != null
                                          ? DateFormat('dd/MM/yyyy')
                                              .format(subtitle.endDate!)
                                          : '-',
                                      style: const pw.TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ],
                              );

                              if (isFirstTitle) {
                                isFirstTitle = false;
                                rowNumber++;
                              }
                              if (isFirstSubtitle) isFirstSubtitle = false;

                              return row;
                            });
                          });
                        }).toList() ??
                        []),
                  ],
                ),
              ],
            );
          },
        ),
      );

      final directory = await _getStorageDirectory();
      if (directory == null) {
        throw Exception('Tidak dapat mengakses penyimpanan');
      }

      final timestamp = DateFormat('ddMMyyyy_HHmmss').format(DateTime.now());
      final fileName = 'laporan_evaluasi_${widget.childName}_$timestamp.pdf';
      final file = File('${directory.path}/$fileName');

      await file.writeAsBytes(await pdf.save());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PDF berhasil disimpan'),
              const SizedBox(height: 4),
              Text(
                'Lokasi: ${file.path}',
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: 'Buka',
            textColor: Colors.white,
            onPressed: () async {
              try {
                final result = await OpenFile.open(file.path);
                if (result.type != ResultType.done && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal membuka file: ${result.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                print('Error opening file: $e');
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal membuka file: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ),
      );
    } catch (e) {
      print('Error generating PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunduh PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  DataRow _buildTitleRow(
    String number,
    String title,
    DateTime? startDate,
    DateTime? endDate,
    bool isCompleted,
  ) {
    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.hovered)) {
            return colorPrimary.withOpacity(0.05);
          }
          return Colors.grey[50];
        },
      ),
      cells: [
        DataCell(Text(
          number,
          style: const TextStyle(
            color: colorPrimary,
            fontWeight: FontWeight.bold,
          ),
        )),
        DataCell(Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        )),
        const DataCell(Text('')),
        const DataCell(Text('')),
        DataCell(_buildDateCell(
          startDate != null ? DateFormat('dd/MM/yyyy').format(startDate) : '-',
          isCompleted: isCompleted,
        )),
        DataCell(_buildDateCell(
          endDate != null ? DateFormat('dd/MM/yyyy').format(endDate) : '-',
          isCompleted: isCompleted,
        )),
      ],
    );
  }

  DataRow _buildEmptyRow() {
    return DataRow(
      color: MaterialStateProperty.all(Colors.white),
      cells: List.generate(6, (index) => const DataCell(Text(''))),
    );
  }

  List<DataRow> _buildSubtitleRows(SubtitleModel subtitle, bool isFirstTitle) {
    List<DataRow> rows = [];
    bool isFirstSubtitle = true;

    for (var activity in subtitle.activities) {
      rows.add(
        DataRow(
          color: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return colorPrimary.withOpacity(0.05);
              }
              return null;
            },
          ),
          cells: [
            const DataCell(Text('')),
            const DataCell(Text('')),
            DataCell(Text(
              isFirstSubtitle ? subtitle.subtitle : '',
              style: const TextStyle(fontWeight: FontWeight.w500),
            )),
            DataCell(Text(
              activity.description,
              style: TextStyle(
                color: Colors.grey[800],
              ),
            )),
            DataCell(_buildDateCell(
              DateFormat('dd/MM/yyyy').format(subtitle.createdAt),
              isCompleted: subtitle.completedAt != null,
            )),
            DataCell(
              _buildDateCell(
                subtitle.completedAt != null
                    ? DateFormat('dd/MM/yyyy').format(subtitle.completedAt!)
                    : '-',
                isCompleted: subtitle.completedAt != null,
              ),
            ),
          ],
        ),
      );
      isFirstSubtitle = false;
    }

    return rows;
  }

  Widget _buildDateCell(String date, {bool isCompleted = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted
            ? colorSuccess.withOpacity(0.1)
            : colorPending.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isCompleted
              ? colorSuccess.withOpacity(0.3)
              : colorPending.withOpacity(0.3),
        ),
      ),
      child: Text(
        date,
        style: TextStyle(
          color: isCompleted ? colorSuccess : colorPending,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<bool> _checkAndRequestPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        // Untuk Android 13+, kita perlu menggunakan MANAGE_EXTERNAL_STORAGE
        if (await Permission.manageExternalStorage.status.isGranted) {
          return true;
        }

        // Tampilkan dialog penjelasan sebelum meminta permission
        if (!mounted) return false;
        final shouldRequest = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Izin Penyimpanan Diperlukan'),
                content: const Text(
                  'Aplikasi membutuhkan izin untuk mengakses penyimpanan perangkat '
                  'untuk menyimpan file PDF. Anda akan diarahkan ke pengaturan aplikasi '
                  'untuk mengaktifkan izin ini.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Buka Pengaturan'),
                  ),
                ],
              ),
            ) ??
            false;

        if (shouldRequest) {
          await openAppSettings();
          // Cek lagi setelah kembali dari settings
          final finalStatus = await Permission.manageExternalStorage.status;
          return finalStatus.isGranted;
        }
        return false;
      } else {
        // Untuk Android 12 ke bawah
        final status = await Permission.storage.status;
        if (status.isGranted) return true;

        final result = await Permission.storage.request();
        if (result.isPermanentlyDenied) {
          // Jika permission ditolak permanen, tampilkan dialog
          if (!mounted) return false;
          final shouldOpenSettings = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Izin Diperlukan'),
                  content: const Text(
                    'Izin penyimpanan diperlukan untuk menyimpan file PDF. '
                    'Silakan aktifkan izin di pengaturan aplikasi.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Buka Pengaturan'),
                    ),
                  ],
                ),
              ) ??
              false;

          if (shouldOpenSettings) {
            await openAppSettings();
            return await Permission.storage.status.isGranted;
          }
          return false;
        }
        return result.isGranted;
      }
    }
    return false;
  }

  pw.Widget _buildPdfTable() {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.5),
        1: const pw.FlexColumnWidth(2.0),
        2: const pw.FlexColumnWidth(2.0),
        3: const pw.FlexColumnWidth(2.0),
        4: const pw.FlexColumnWidth(1.5),
        5: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F8F9FF')),
          children: [
            'No',
            'Judul Program',
            'Sub Program',
            'Aktivitas',
            'Tanggal Mulai',
            'Tanggal Selesai',
          ]
              .map((text) => pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(text,
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ))
              .toList(),
        ),
        ...(_rptData?.titles.expand((title) {
              Map<String, bool> subtitleFirstAppearance = {};
              bool isFirstTitle = true;
              return title.subtitles.expand((subtitle) {
                bool isFirstSubtitle =
                    !subtitleFirstAppearance.containsKey(subtitle.subtitle);
                subtitleFirstAppearance[subtitle.subtitle] = true;

                return subtitle.activities.map((activity) {
                  final row = pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(isFirstTitle ? "1" : "")),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(isFirstTitle ? title.title : "")),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                              isFirstSubtitle ? subtitle.subtitle : "")),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(activity.description)),
                      pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: pw.BoxDecoration(
                              color: subtitle.completedAt != null
                                  ? PdfColor.fromHex('#E8F5E9')
                                  : PdfColor.fromHex('#E3F2FD'),
                              borderRadius: const pw.BorderRadius.all(
                                  pw.Radius.circular(4))),
                          child: pw.Text(DateFormat('dd/MM/yyyy')
                              .format(subtitle.createdAt))),
                      pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: pw.BoxDecoration(
                              color: subtitle.completedAt != null
                                  ? PdfColor.fromHex('#E8F5E9')
                                  : PdfColor.fromHex('#E3F2FD'),
                              borderRadius: const pw.BorderRadius.all(
                                  pw.Radius.circular(4))),
                          child: pw.Text(subtitle.completedAt != null
                              ? DateFormat('dd/MM/yyyy')
                                  .format(subtitle.completedAt!)
                              : '-')),
                    ],
                  );
                  isFirstTitle = false;
                  isFirstSubtitle = false;
                  return row;
                });
              });
            }).toList() ??
            []),
      ],
    );
  }

  List<pw.TableRow> _buildPdfDataRows() {
    if (_rptData == null) return [];

    List<pw.TableRow> allRows = [];
    Map<String, bool> titleFirstAppearance = {};
    Map<String, bool> subtitleFirstAppearance = {};
    int globalRowNumber = 1;

    for (var title in _rptData!.titles) {
      bool isFirstTitle = !titleFirstAppearance.containsKey(title.title);
      if (isFirstTitle) {
        titleFirstAppearance[title.title] = true;
        globalRowNumber++;
      }

      for (var subtitle in title.subtitles) {
        bool isFirstSubtitle =
            !subtitleFirstAppearance.containsKey(subtitle.subtitle);
        subtitleFirstAppearance[subtitle.subtitle] = true;

        for (var activity in subtitle.activities) {
          allRows.add(pw.TableRow(
            children: [
              pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(
                      isFirstTitle ? (globalRowNumber - 1).toString() : '')),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(isFirstTitle ? title.title : '')),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(isFirstSubtitle ? subtitle.subtitle : '')),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(activity.description)),
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: subtitle.completedAt != null
                      ? PdfColor.fromHex('#E8F5E9')
                      : PdfColor.fromHex('#E3F2FD'),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Text(
                    DateFormat('dd/MM/yyyy').format(subtitle.createdAt)),
              ),
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: subtitle.completedAt != null
                      ? PdfColor.fromHex('#E8F5E9')
                      : PdfColor.fromHex('#E3F2FD'),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Text(subtitle.completedAt != null
                    ? DateFormat('dd/MM/yyyy').format(subtitle.completedAt!)
                    : '-'),
              ),
            ],
          ));
          isFirstTitle = false;
          isFirstSubtitle = false;
        }
      }
    }

    return allRows;
  }

  Future<bool> _confirmDownload() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Unduh PDF'),
          content: const Text(
            'Apakah Anda yakin ingin mengunduh dokumen ini dalam format PDF?',
          ),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Unduh'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
    return confirm ?? false;
  }

  // Build method untuk UI
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorBackground,
        body: Center(
          child: CircularProgressIndicator(color: colorPrimary),
        ),
      );
    }

    if (_rptData == null || _rptData!.titles.isEmpty) {
      return Scaffold(
        backgroundColor: colorBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Re-Evaluasi ${widget.childName}',
            style: const TextStyle(
              color: colorPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: colorPrimary),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 64,
                color: colorPrimary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada program terapi',
                style: TextStyle(
                  fontSize: 16,
                  color: colorPrimary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Re-Evaluasi ${widget.childName}',
          style: const TextStyle(
            color: colorPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: colorPrimary),
        actions: [
          IconButton(
            icon: _isGeneratingPdf
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(colorPrimary),
                    ),
                  )
                : const Icon(Icons.download, color: colorPrimary),
            onPressed: _isGeneratingPdf
                ? null
                : () async {
                    if (await _confirmDownload()) {
                      await _generateAndDownloadPDF();
                    }
                  },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      color: colorPrimary,
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildProgramCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorPrimary.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline, color: colorPrimary),
                const SizedBox(width: 8),
                const Text(
                  'Data Anak',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_childData != null) ...[
              _buildInfoRow('Nama', _childData!['name'] ?? widget.childName),
              _buildInfoRow('Usia', _childData!['age']?.toString() ?? 'N/A'),
              if (_childData!['dateOfBirth'] != null)
                _buildInfoRow(
                  'Tanggal Lahir',
                  DateFormat('dd MMM yyyy').format(
                    (_childData!['dateOfBirth'] as Timestamp).toDate(),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgramCard() {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorPrimary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.assignment_outlined, color: colorPrimary),
                const SizedBox(width: 8),
                const Text(
                  'Program Terapi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorPrimary,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _buildDataTable(),
          ),
        ],
      ),
    );
  }

  DataTable _buildDataTable() {
    return DataTable(
      headingRowColor: MaterialStateColor.resolveWith(
        (states) => colorPrimary.withOpacity(0.05),
      ),
      border: TableBorder.all(
        color: colorPrimary.withOpacity(0.1),
        width: 1,
        borderRadius: BorderRadius.circular(8),
      ),
      columnSpacing: 24,
      horizontalMargin: 16,
      columns: [
        _buildColumn('No'),
        _buildColumn('Judul Program'),
        _buildColumn('Sub Program'),
        _buildColumn('Aktivitas'),
        _buildColumn('Tanggal Mulai'),
        _buildColumn('Tanggal Selesai'),
      ],
      rows: _buildTableRows(),
    );
  }

  DataColumn _buildColumn(String label) {
    return DataColumn(
      label: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: colorPrimary,
          ),
        ),
      ),
    );
  }

  List<DataRow> _buildTableRows() {
    int rowNumber = 1;
    List<DataRow> rows = [];

    if (_rptData == null) return [];

    for (var title in _rptData!.titles) {
      DateTime? titleStartDate = title.subtitles.isNotEmpty
          ? title.subtitles
              .map((s) => s.createdAt)
              .reduce((a, b) => a.isBefore(b) ? a : b)
          : null;
      bool allSubtitlesCompleted =
          title.subtitles.every((s) => s.completedAt != null);
      DateTime? titleEndDate = allSubtitlesCompleted
          ? title.subtitles
              .map((s) => s.completedAt!)
              .reduce((a, b) => a.isAfter(b) ? a : b)
          : null;

      // Add title row with start/end dates
      if (title.subtitles.isNotEmpty) {
        rows.add(DataRow(
          cells: [
            DataCell(Text(rowNumber.toString())),
            DataCell(Text(title.title)),
            const DataCell(Text('')),
            const DataCell(Text('')),
            DataCell(_buildDateCell(
              titleStartDate != null
                  ? DateFormat('dd/MM/yyyy').format(titleStartDate)
                  : '-',
              isCompleted: false,
            )),
            DataCell(_buildDateCell(
              titleEndDate != null
                  ? DateFormat('dd/MM/yyyy').format(titleEndDate)
                  : '-',
              isCompleted: allSubtitlesCompleted,
            )),
          ],
        ));
      }

      // Add subtitle and activity rows
      Map<String, bool> subtitleFirstAppearance = {};
      for (var subtitle in title.subtitles) {
        for (var activity in subtitle.activities) {
          bool isFirstAppearance =
              !subtitleFirstAppearance.containsKey(subtitle.subtitle);
          subtitleFirstAppearance[subtitle.subtitle] = true;

          rows.add(DataRow(
            cells: [
              const DataCell(Text('')),
              const DataCell(Text('')),
              DataCell(Text(isFirstAppearance ? subtitle.subtitle : '')),
              DataCell(Text(activity.description)),
              DataCell(_buildDateCell(
                DateFormat('dd/MM/yyyy').format(subtitle.createdAt),
                isCompleted: subtitle.completedAt != null,
              )),
              DataCell(_buildDateCell(
                subtitle.completedAt != null
                    ? DateFormat('dd/MM/yyyy').format(subtitle.completedAt!)
                    : '-',
                isCompleted: subtitle.completedAt != null,
              )),
            ],
          ));
        }
      }
      rowNumber++;
    }

    return rows;
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: colorPrimary.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
