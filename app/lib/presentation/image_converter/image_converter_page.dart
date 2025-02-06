// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:dotted_border/dotted_border.dart';

class ImageCompressorPage extends StatefulWidget {
  const ImageCompressorPage({super.key});

  @override
  State<ImageCompressorPage> createState() => _ImageCompressorPageState();
}

class _ImageCompressorPageState extends State<ImageCompressorPage> {
  List<Uint8List> imageBytesList = []; // Store original images
  List<Uint8List> compressedImages = []; // Store converted WebP images
  List<String> fileNames = []; // Store original file names
  List<int> originalSizes = []; // Store original file sizes
  List<int> compressedSizes = []; // Store compressed file sizes
  late DropzoneViewController dropzoneController;
  bool compressTo1080p = false; // Toggle for 1080p compression
  double compressionQuality = 80; // Slider-controlled compression quality

  // 📌 Pick & Convert Images (PNG/JPG → WebP)
  Future<void> pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      for (var file in result.files) {
        Uint8List? bytes = file.bytes;
        String fileName = file.name.split('.').first; // Remove file extension
        if (bytes != null) {
          await processImage(bytes, fileName);
        }
      }
    }
  }

  // 📌 Handle Drag & Drop Images
  Future<void> onDropMultiple(List<dynamic>? events) async {
    if (events == null) return;
    for (var event in events) {
      final bytes = await dropzoneController.getFileData(event);
      final fileName = await dropzoneController.getFilename(event);
      String cleanFileName = fileName.split('.').first; // Remove extension
      await processImage(bytes, cleanFileName);
    }
  }

  // 📌 Process Image (Compress or Convert)
  Future<void> processImage(Uint8List imageBytes, String fileName) async {
    setState(() {
      imageBytesList.add(imageBytes);
      fileNames.add(fileName);
      originalSizes.add(imageBytes.length);
    });

    Uint8List webpBytes = await convertToWebP(imageBytes);
    setState(() {
      compressedImages.add(webpBytes);
      compressedSizes.add(webpBytes.length);
    });
  }

  // 📌 Convert PNG/JPG to WebP (With or Without Compression)
  Future<Uint8List> convertToWebP(Uint8List imageBytes) async {
    final decodedImage = await decodeImageFromList(imageBytes);
    int originalHeight = decodedImage.height;
    int originalWidth = decodedImage.width;

    return await FlutterImageCompress.compressWithList(
      imageBytes,
      minHeight: compressTo1080p ? 1080 : originalHeight,
      minWidth: compressTo1080p ? 1080 : originalWidth,
      quality: compressionQuality.toInt(),
      format: CompressFormat.webp,
    );
  }

  // 📌 Download WebP File with Original File Name
  void downloadWebP(Uint8List webpBytes, String originalFileName) {
    final blob = html.Blob([webpBytes], 'image/webp');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', '$originalFileName.webp')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 📌 Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bild Kompressor und WebP Konverter',
                style: Theme.of(context).textTheme.displayLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // 📌 Drag & Drop Area
          InkWell(
            onTap: pickImages,
            child: DottedBorder(
              color: Colors.grey,
              strokeWidth: 1,
              dashPattern: [5, 5],
              child: SizedBox(
                height: 250,
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

          // 📌 Preview List of Uploaded Images
          if (imageBytesList.isNotEmpty)
            SizedBox(
              height: 200,
              child: Center(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageBytesList.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Image.memory(
                          imageBytesList[index],
                          width: 120,
                          height: 120,
                          fit: BoxFit.scaleDown,
                        ),
                        Text(fileNames[index], style: TextStyle(fontSize: 12)),
                      ],
                    );
                  },
                  separatorBuilder: (context, index) => SizedBox(width: 10),
                ),
              ),
            ),

          SizedBox(height: 20),

          // 📌 Compression Quality Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Komprimierungslevel: ${compressionQuality.toInt()}%'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Slider(
                value: compressionQuality,
                min: 1,
                max: 100,
                divisions: 99,
                label: '${compressionQuality.toInt()}%',
                onChanged: (double value) {
                  setState(() {
                    compressionQuality = value;
                  });
                },
              ),
              SizedBox(width: 10),

              // 📌 Toggle Compression
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Konvertiere zu 1080p'),
                  Switch(
                    value: compressTo1080p,
                    onChanged: (bool value) {
                      setState(() {
                        compressTo1080p = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 20),

          // 📌 Download Button
          FilledButton.icon(
            onPressed: () {
              for (int i = 0; i < compressedImages.length; i++) {
                downloadWebP(compressedImages[i], fileNames[i]);
              }
            },
            icon: Icon(Icons.download),
            label: Text('Download WebP'),
          ),
        ],
      ),
    );
  }
}
