import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class SingleUpload extends StatefulWidget {
  const SingleUpload({super.key});

  @override
  State<SingleUpload> createState() => _SingleUploadState();
}

class _SingleUploadState extends State<SingleUpload> {
  double progressPer = 0;
  late UploadTask task;
  String path = '';

  @override
  void initState() {
    super.initState();
    pickFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Single Upload',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 50,
          ),
          CircularPercentIndicator(
            radius: 130.0,
            animation: true,
            animationDuration: 100,
            lineWidth: 15.0,
            percent: progressPer.toDouble(),
            animateFromLastPercent: true,
            center: Text(
              "${(progressPer * 100).toStringAsFixed(2)}%",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            backgroundColor: Colors.grey.shade300,
            progressColor: Colors.green,
          ),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                    child: IconButton(
                        onPressed: () async {
                          await cancelUpload();
                        },
                        icon: const Icon(Icons.close))),
                const SizedBox(
                  width: 20,
                )
              ],
            ),
          )
        ],
      )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await uploadFile();
        },
        child: const Icon(Icons.download),
      ),
    );
  }

  pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        path = file.path;
      });
    } else {}
  }

  uploadFile() async {
    try {
      const String url =
          'https://upload-image-and-return-url-by-thichthicodeteam.p.rapidapi.com/api/upload-image';

      task = UploadTask(
        url: url,
        //'fileName' Field can create trouble if it is not same as the picked file's name.
        //So be careful to assign fileName. It must be a picked file's name with file extension.
        filename: path.toString().split('/').last,
        headers: {
          'Accept': '*/*',
          "content-type":
              "multipart/form-data; boundary=---011000010111000001101001",
          'content-Type': "multipart/form-data",
          'X-RapidAPI-Key':
              'c4dacdbc17msh870ca87b1de6fadp136c52jsn70bd723f4658',
          'X-RapidAPI-Host':
              'upload-image-and-return-url-by-thichthicodeteam.p.rapidapi.com',
        },
        httpRequestMethod: 'POST',
        updates: Updates.statusAndProgress,
        //Select Root Directory as it will return custom path
        baseDirectory: BaseDirectory.root,
        /* Provide custom path of your file e.g. File Picker will
          create /data/user/0/com.example.download_progress/cache/file_picker/.
          This path can be changed according to selected file so be careful */
        directory:
            '/data/user/0/com.example.download_progress/cache/file_picker/',
        fields: {
          'file': path.toString(),
        },
      );

      //Perform Upload Task
      await FileDownloader().upload(task, onProgress: (value) {
        setState(() {
          if (!value.isNegative) {
            progressPer = value;
          }
        });
      }).then((value) => print(value.responseBody));
    } catch (e) {
      print(e.toString());
    }
  }

  cancelUpload() async {
    await FileDownloader().cancelTaskWithId(task.taskId).whenComplete(() {
      setState(() {
        progressPer = 0;
      });
    });
  }
}
