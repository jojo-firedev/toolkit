import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class LinkedInCarouselGeneratorPage extends StatefulWidget {
  @override
  _LinkedInCarouselGeneratorPageState createState() =>
      _LinkedInCarouselGeneratorPageState();
}

class _LinkedInCarouselGeneratorPageState
    extends State<LinkedInCarouselGeneratorPage> {
  List<Uint8List> imageBytesList = []; // Store images as byte arrays
  late DropzoneViewController dropzoneController;

  // 📌 FIXED: Handle Drag & Drop Properly
  Future<void> onDrop(DropzoneFileInterface event) async {
    try {
      // Retrieve Dropzone file
      // final dropzoneFile = await dropzoneController.getFileData(event);

      // Get file bytes from Dropzone
      final bytes = await dropzoneController.getFileData(event);

      setState(() {
        imageBytesList.add(bytes);
      });

      print("File added successfully");
    } catch (e) {
      print("Error processing dropped file: $e");
    }
  }

  // 📌 Pick Images Using File Picker
  Future<void> pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        imageBytesList.addAll(result.files.map((file) => file.bytes!).toList());
      });
    }
  }

  // 📌 Generate PDF from Selected Images
  Future<void> generatePdf() async {
    if (imageBytesList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please add at least one image")),
      );
      return;
    }

    final pdf = pw.Document();

    for (Uint8List imageBytes in imageBytesList) {
      final pdfImage = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(1080, 1080), // ✅ 1:1 Square Format
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
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "LinkedIn_Carousel.pdf")
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("LinkedIn Carousel PDF Generator")),
      body: Column(
        children: [
          // 📌 Drag & Drop Area
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.grey[200],
              child: Stack(
                alignment: Alignment.center,
                children: [
                  DropzoneView(
                    onCreated: (controller) => dropzoneController = controller,
                    onDropFile: (DropzoneFileInterface event) => onDrop(event),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload, size: 60, color: Colors.blue),
                        Text("Drag & Drop Images Here"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 📌 Image Previews
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

          // 📌 Buttons for Upload & PDF Generation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: pickImages,
                icon: Icon(Icons.folder_open),
                label: Text("Pick Images"),
              ),
              ElevatedButton.icon(
                onPressed: generatePdf,
                icon: Icon(Icons.picture_as_pdf),
                label: Text("Generate PDF"),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
