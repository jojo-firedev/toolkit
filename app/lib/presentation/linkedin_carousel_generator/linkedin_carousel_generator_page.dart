import 'dart:html' as html;
import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class LinkedInCarouselGeneratorPage extends StatefulWidget {
  const LinkedInCarouselGeneratorPage({super.key});

  @override
  State<LinkedInCarouselGeneratorPage> createState() =>
      _LinkedInCarouselGeneratorPageState();
}

class _LinkedInCarouselGeneratorPageState
    extends State<LinkedInCarouselGeneratorPage> {
  List<Uint8List> imageBytesList = []; // Store images as byte arrays
  late DropzoneViewController dropzoneController;

  // 📌 Handle Drag & Drop for Multiple Files
  Future<void> onDropMultiple(List<DropzoneFileInterface>? events) async {
    try {
      if (events == null) return;
      for (var event in events) {
        final bytes = await dropzoneController.getFileData(event);
        setState(() {
          imageBytesList.add(bytes);
        });
      }
      print("${events.length} files added successfully!");
    } catch (e) {
      print("Error processing dropped files: $e");
    }
  }

  // 📌 Pick Multiple Images Using File Picker
  Future<void> pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true, // ✅ Allow multiple file selection
    );

    if (result != null) {
      setState(() {
        imageBytesList.addAll(result.files.map((file) => file.bytes!).toList());
      });
      print("${result.files.length} files added successfully!");
    }
  }

  // 📌 Generate PDF from Selected Images (1:1 format)
  Future<void> generatePdf() async {
    if (imageBytesList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bitte wählen Sie mindestens ein Bild aus!")),
      );
      return;
    }

    final pdf = pw.Document();

    for (Uint8List imageBytes in imageBytesList) {
      final pdfImage = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(1080, 1080), // ✅ Square Format (1:1)
          build: (pw.Context context) => pw.Center(
            child: pw.Image(pdfImage, fit: pw.BoxFit.cover), // ✅ Ensure Fit
          ),
        ),
      );
    }

    // 📌 Convert PDF to Bytes & Download
    final pdfBytes = await pdf.save();
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    // ignore: unused_local_variable
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "LinkedIn_Carousel.pdf")
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "LinkedIn Carousel Generator",
                style: Theme.of(context).textTheme.displayLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          SizedBox(height: 50),

          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Text(
              "Erstellen Sie einen LinkedIn Carousel-Beitrag. "
              "Hierfür können Sie Bilder per Drag & Drop oder über den Dateiauswähler hinzufügen. "
              "Klicken Sie auf 'Als PDF exportieren', um die Bilder als PDF herunterzuladen.",
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 10),
          // 📌 Drag & Drop Multiple Files Area
          InkWell(
            onTap: pickImages,
            child: DottedBorder(
              color: Colors.grey,
              strokeWidth: 1,
              dashPattern: [5, 5],
              child: SizedBox(
                height: 300,
                width: 600,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    DropzoneView(
                      onCreated: (controller) =>
                          dropzoneController = controller,
                      onDropFiles: (events) => onDropMultiple(events),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 18,
                      children: [
                        Icon(Icons.upload, size: 40),
                        Text("Ziehe Bilder hierher oder klicke zum Hochladen"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          if (imageBytesList.isNotEmpty)
            Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imageBytesList.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Image.memory(imageBytesList[index],
                      width: 80, height: 80),
                ),
              ),
            ),
          SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilledButton.icon(
                onPressed: generatePdf,
                icon: Icon(Icons.picture_as_pdf),
                label: Text("Als PDF exportieren"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
