import 'dart:convert';
// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// import 'dart:typed_data';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:path_provider/path_provider.dart';
// import 'package:open_file/open_file.dart';

// import 'package:permission_handler/permission_handler.dart';

// import '../screens/pdf_viewer_page_screen.dart';
import '../config/conn_backend.dart';
import '../config/separe_millier.dart';
import '../models/quinzaine_model.dart';

class FeuillePointageOv extends StatefulWidget {
  final Quinzaine quinzaine;

  const FeuillePointageOv({super.key, required this.quinzaine});

  @override
  State<FeuillePointageOv> createState() => _FeuillePointageOvState();
}

class _FeuillePointageOvState extends State<FeuillePointageOv> {
  List<Map<String, dynamic>> ouvriers = [];
  bool _loading = true;
  bool colonnesReduites = false;

  List<String> colonnesComplet = [];
  List<String> clesComplet = [];
  List<String> colonnesAffichees = [];
  List<String> clesAffichees = [];

  List<String> colonnes = [];
  List<String> cles = [];

  @override
  void initState() {
    super.initState();

    final DateTime debutSession = DateFormat(
      "dd-MM-yyyy",
    ).parse(widget.quinzaine.debut);

    if (widget.quinzaine.periode == 'Quinzaine') {
      // Générer les 7 premiers jours à partir du début
      final List<String> joursSemaine = List.generate(15, (i) {
        final date = debutSession.add(Duration(days: i));
        return DateFormat("dd-MM").format(date); // Ex: 04-juil
      });

      // Construit les colonnes
      colonnes = [
        'Nom',
        'Fonction',
        'Taux/jr',
        ...joursSemaine,
        'Nbre de jrs',
        'Paie total',
      ];

      cles = [
        'nom',
        'fonction',
        'prix_jr',
        'jr1',
        'jr2',
        'jr3',
        'jr4',
        'jr5',
        'jr6',
        'jr7',

        'jr8',
        'jr9',
        'jr10',
        'jr11',
        'jr12',
        'jr13',
        'jr14',
        'jr15',

        'ttal_jr',
        'paiement',
      ];

      // Affichage initial complet
      colonnesAffichees = List.from(colonnes);
      clesAffichees = List.from(cles);

      colonnesComplet = List.from(colonnes);
      clesComplet = List.from(cles);
    } else {
      // Générer les 7 premiers jours à partir du début
      final List<String> joursSemaine = List.generate(7, (i) {
        final date = debutSession.add(Duration(days: i));
        return DateFormat("dd-MM").format(date); // Ex: 04-juil
      });

      // Construit les colonnes
      colonnes = [
        'Nom',
        'Fonction',
        'Taux/jr',
        ...joursSemaine,
        'Nbre de jrs',
        'Paie total',
      ];

      // les lignes
      cles = [
        'nom',
        'fonction',
        'prix_jr',
        'jr1',
        'jr2',
        'jr3',
        'jr4',
        'jr5',
        'jr6',
        'jr7',
        'ttal_jr',
        'paiement',
      ];

      // Affichage initial complet
      colonnesAffichees = List.from(colonnes);
      clesAffichees = List.from(cles);

      colonnesComplet = List.from(colonnes);
      clesComplet = List.from(cles);
    }

    // // Générer les 7 premiers jours à partir du début
    // final List<String> joursSemaine = List.generate(7, (i) {
    //   final date = debutSession.add(Duration(days: i));
    //   return DateFormat("dd-MM").format(date); // Ex: 04-juil
    // });

    // // Construit les colonnes
    // colonnes = [
    //   'Nom',
    //   'Fonction',
    //   'Taux/jr',
    //   ...joursSemaine,
    //   'Nbre de jrs',
    //   'Paie total',
    // ];

    _chargerOuvriers();
  }

  void _toggleColonnes() {
    setState(() {
      colonnesReduites = !colonnesReduites;

      if (colonnesReduites) {
        colonnesAffichees = [
          ...colonnesComplet.take(3),
          ...colonnesComplet.skip(colonnesComplet.length - 2),
        ];

        clesAffichees = [
          ...clesComplet.take(3),
          ...clesComplet.skip(clesComplet.length - 2),
        ];
      } else {
        colonnesAffichees = List.from(colonnesComplet);
        clesAffichees = List.from(clesComplet);
      }
    });
  }

  Future<void> _chargerOuvriers() async {
    final url = ConnBackend.withParams({
      "action": "list_ovquinzaine",
      "id": widget.quinzaine.id.toString(),
    });
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          setState(() {
            ouvriers = List<Map<String, dynamic>>.from(data);
            _loading = false;
          });
        } else {
          throw Exception("Format de données invalide");
        }
      } else {
        throw Exception("Erreur HTTP ${response.statusCode}");
      }
    } catch (e) {
      // print("Erreur : $e");
      setState(() => _loading = false);
    }
  }

  // Future<void> generateFeuillePointagePdf({
  //   required String periode,
  //   required String dateDebut,
  //   required String dateFin,
  //   required List<String> colonnes,
  //   required List<String> cles,
  //   required List<Map<String, dynamic>> ouvriers,
  // }) async {
  //   final pdf = pw.Document();
  //   final debut = DateFormat("dd-MM-yyyy").parse(dateDebut);
  //   final fin = DateFormat("dd-MM-yyyy").parse(dateFin);

  //   // Préparer les lignes
  //   final List<List<String>> lignes = ouvriers.map((o) {
  //     return cles.map((cle) {
  //       if (cle == 'paiement') {
  //         final int jours = int.tryParse(o['ttal_jr'].toString()) ?? 0;
  //         final int prix = int.tryParse(o['prix_jr'].toString()) ?? 0;
  //         return (jours * prix).toString();
  //       } else {
  //         return o[cle]?.toString() ?? '';
  //       }
  //     }).toList();
  //   }).toList();

  //   // Ligne des totaux
  //   final List<String> ligneTotaux = [];
  //   int totalGeneral = 0;

  //   for (final cle in cles) {
  //     if (cle.startsWith('jr')) {
  //       final total = ouvriers
  //           .map((o) => int.tryParse(o[cle].toString()) ?? 0)
  //           .reduce((a, b) => a + b);
  //       ligneTotaux.add(total.toString());
  //     } else if (cle == 'nom') {
  //       ligneTotaux.add('Totaux');
  //     }
  //     //  else if (cle == 'ttal_jr') {
  //     //   final total = ouvriers
  //     //       .map((o) => int.tryParse(o[cle].toString()) ?? 0)
  //     //       .reduce((a, b) => a + b);
  //     //   ligneTotaux.add(total.toString());
  //     // }
  //     else if (cle == 'paiement') {
  //       final total = ouvriers
  //           .map((o) {
  //             final j = int.tryParse(o['ttal_jr'].toString()) ?? 0;
  //             final p = int.tryParse(o['prix_jr'].toString()) ?? 0;
  //             return j * p;
  //           })
  //           .reduce((a, b) => a + b);
  //       totalGeneral = total;
  //       ligneTotaux.add(total.toString());
  //     } else {
  //       ligneTotaux.add('');
  //     }
  //   }

  //   lignes.add(ligneTotaux);

  //   // Construction du PDF
  //   pdf.addPage(
  //     pw.MultiPage(
  //       build: (context) => [
  //         pw.Text(
  //           "Feuille de pointage ouvriers",
  //           style: pw.TextStyle(fontSize: 17, fontWeight: pw.FontWeight.bold),
  //         ),
  //         pw.SizedBox(height: 5),
  //         pw.Text(
  //           "Période : $periode (${DateFormat('dd-MM-yyyy').format(debut)} au ${DateFormat('dd-MM-yyyy').format(fin)})",
  //           style: pw.TextStyle(fontSize: 12),
  //         ),
  //         pw.SizedBox(height: 20),
  //         pw.TableHelper.fromTextArray(
  //           headers: colonnes,
  //           data: lignes,
  //           border: pw.TableBorder.all(),
  //           headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
  //           headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
  //           cellAlignment: pw.Alignment.centerLeft,
  //           cellStyle: pw.TextStyle(fontSize: 10),
  //         ),
  //         pw.SizedBox(height: 18),
  //         pw.Text(
  //           "Total paiement général : ${NumberFormat.decimalPattern('fr_FR').format(totalGeneral)} FCFA",
  //           style: pw.TextStyle(
  //             fontSize: 14,
  //             fontWeight: pw.FontWeight.bold,
  //             // color: PdfColors.green900,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );

  //   // Enregistrement
  //   final output = await getTemporaryDirectory();
  //   final file = File("${output.path}/feuille_pointage.pdf");
  //   await file.writeAsBytes(await pdf.save());
  //   await OpenFile.open(file.path);
  //   // ignore: use_build_context_synchronously
  //   // Navigator.of(context).pop();
  //   // return file;

  //   // Demande la permission d’écriture
  //   // if (await Permission.storage.request().isGranted) {
  //   //   // 📁 Récupère le dossier "Download" (pour Android)
  //   //   final directory = Directory('/storage/emulated/0/Download');
  //   //   if (!(await directory.exists())) {
  //   //     await directory.create(recursive: true);
  //   //   }

  //   //   final file = File('${directory.path}/feuille_pointage.pdf');
  //   //   await file.writeAsBytes(await pdf.save());

  //   //   return file;
  //   // } else {
  //   //   return null;
  //   // }

  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feuille de pointage"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              colonnesReduites ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: _toggleColonnes,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  // width: double.infinity,
                  width: MediaQuery.of(context).size.width * 1,
                  padding: const EdgeInsets.all(10),
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: Text(
                    "${widget.quinzaine.periode} du ${widget.quinzaine.debut} au ${widget.quinzaine.fin} ",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                      // color: Color(0xFF0D47A1),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: SizedBox(
                    // width: 950,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 10),
                          DataTable(
                            border: TableBorder.all(color: Colors.black),
                            columnSpacing: 3,
                            headingRowColor: WidgetStateProperty.all(
                              Colors.blue[50],
                            ),
                            dataRowColor: WidgetStateColor.resolveWith(
                              (states) => Colors.grey[50]!,
                            ),
                            columns: colonnesAffichees.map((col) {
                              return DataColumn(
                                label: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    col,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            rows: [
                              ...ouvriers.map((row) {
                                return DataRow(
                                  cells: clesAffichees.map((cle) {
                                    String valeur = '';
                                    if (cle == 'paiement') {
                                      final int ttalJr =
                                          int.tryParse(
                                            row['ttal_jr'].toString(),
                                          ) ??
                                          0;
                                      final int prixJr =
                                          int.tryParse(
                                            row['prix_jr'].toString(),
                                          ) ??
                                          0;
                                      valeur = formatNombreStr(
                                        (ttalJr * prixJr).toString(),
                                      );
                                    } else if (cle == 'prix_jr') {
                                      valeur = formatNombreStr(
                                        row[cle].toString(),
                                      );
                                    } else {
                                      valeur = row[cle]?.toString() ?? '';
                                    }
                                    return DataCell(
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          valeur,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              }),

                              // ✅ Ligne Grand Totaux
                              DataRow(
                                color: WidgetStateProperty.all(
                                  Colors.grey[300],
                                ),
                                cells: clesAffichees.map((cle) {
                                  if (cle == 'nom') {
                                    return const DataCell(
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Grand Totaux',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else if (cle.startsWith('jr')) {
                                    final total = ouvriers
                                        .where(
                                          (row) => row[cle]?.toString() == '1',
                                        )
                                        .length;
                                    return DataCell(
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          total.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else if (cle == 'paiement') {
                                    final totalPaiement = ouvriers.fold<int>(
                                      0,
                                      (sum, row) {
                                        final int jours =
                                            int.tryParse(
                                              row['ttal_jr'].toString(),
                                            ) ??
                                            0;
                                        final int prix =
                                            int.tryParse(
                                              row['prix_jr'].toString(),
                                            ) ??
                                            0;
                                        return sum + (jours * prix);
                                      },
                                    );
                                    return DataCell(
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          formatNombreStr(
                                            totalPaiement.toString(),
                                          ),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return const DataCell(Text(''));
                                  }
                                }).toList(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
