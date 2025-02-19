import 'dart:js_interop';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:web/web.dart' as web;

class LinkedInCarouselGeneratorPage extends StatefulWidget {
  const LinkedInCarouselGeneratorPage({super.key});

  @override
  State<LinkedInCarouselGeneratorPage> createState() =>
      _LinkedInCarouselGeneratorPageState();
}

class _LinkedInCarouselGeneratorPageState
    extends State<LinkedInCarouselGeneratorPage> {
  bool useSquareFormat = true; // Default to 1:1 format
  bool loading = false;

  List<Uint8List> imageBytesList = []; // Store images as byte arrays
  late DropzoneViewController dropzoneController;

  // Handle Drag & Drop for Multiple Files
  Future<void> onDropMultiple(List<DropzoneFileInterface>? events) async {
    if (events == null) return;
    for (var event in events) {
      final bytes = await dropzoneController.getFileData(event);
      setState(() {
        imageBytesList.add(bytes);
      });
    }
  }

  // Pick Multiple Images Using File Picker
  Future<void> pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true, // ✅ Allow multiple file selection
    );

    if (result != null) {
      setState(() {
        imageBytesList.addAll(result.files.map((file) => file.bytes!).toList());
      });
    }
  }

  // Generate PDF from Selected Images (1:1 format)
  Future<void> generatePdf() async {
    if (imageBytesList.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Bitte wählen Sie mindestens ein Bild aus!')),
        );
      }
      return;
    }

    setState(() {
      loading = true;
    });

    final pdf = pw.Document();
    int minResolution = double.maxFinite.toInt();
    double pageWidth = 1080;
    double pageHeight = 1080;

    if (useSquareFormat) {
      // Find the smallest resolution but ensure it's at least 1080x1080
      for (Uint8List imageBytes in imageBytesList) {
        final decodedImage = await decodeImageFromList(imageBytes);
        int minSide = decodedImage.width < decodedImage.height
            ? decodedImage.width
            : decodedImage.height;
        if (minSide < minResolution) {
          minResolution = minSide;
        }
      }
      minResolution = minResolution < 1080 ? 1080 : minResolution;
      pageWidth = pageHeight = minResolution.toDouble();
    } else {
      // Use the first image's aspect ratio
      final firstImage = await decodeImageFromList(imageBytesList.first);
      pageWidth = firstImage.width.toDouble();
      pageHeight = firstImage.height.toDouble();

      // Ensure at least 1080 in width
      if (pageWidth < 1080) {
        double scaleFactor = 1080 / pageWidth;
        pageWidth = 1080;
        pageHeight *= scaleFactor;
      }
    }

    for (Uint8List imageBytes in imageBytesList) {
      final pdfImage = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(pageWidth, pageHeight), // Dynamic format
          build: (pw.Context context) => pw.Center(
            child: pw.Image(pdfImage,
                fit: pw.BoxFit.cover), // Ensure full coverage
          ),
        ),
      );
    }

    final pdfBytes = await pdf.save();

    // Convert to JS-friendly format
    final jsBlob = web.Blob(
        [pdfBytes.toJS].toJS, web.BlobPropertyBag(type: 'application/pdf'));

    // Create and trigger a download link
    final url = web.URL.createObjectURL(jsBlob);
    web.HTMLAnchorElement()
      ..href = url
      ..download = 'LinkedIn_Carousel.pdf'
      ..click();
    web.URL.revokeObjectURL(url);

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(
        label: 'LinkedIn Carousel - FD Toolkit',
        primaryColor:
            Theme.of(context).primaryColor.value, // This line is required
      ),
    );

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'LinkedIn Carousel Generator',
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
              'Erstellen Sie einen LinkedIn Carousel-Beitrag. '
              'Hierfür können Sie Bilder per Drag & Drop oder über den Dateiauswähler hinzufügen. '
              'Klicken Sie auf "Als PDF exportieren", um die Bilder als PDF herunterzuladen.,',
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: 10),
          // Drag & Drop Multiple Files Area
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
                        Text('Ziehe Bilder hierher oder klicke zum Hochladen'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          if (imageBytesList.isNotEmpty)
            SizedBox(
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Seitenverhältnis',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Seitenverhältnis\ndes 1. Bildes'),
              SizedBox(width: 10),
              Switch(
                value: useSquareFormat,
                onChanged: (value) {
                  setState(() {
                    useSquareFormat = value;
                  });
                },
              ),
              SizedBox(width: 10),
              Text('Quadratisch (1:1)'),
            ],
          ),

          SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (loading)
                CircularProgressIndicator()
              else
                FilledButton.icon(
                  onPressed: generatePdf,
                  icon: Icon(Icons.picture_as_pdf),
                  label: Text('Als PDF exportieren'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
