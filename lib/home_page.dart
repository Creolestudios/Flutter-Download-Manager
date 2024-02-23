import 'package:download_progress/category/batch_download.dart';
import 'package:download_progress/category/batch_upload.dart';
import 'package:download_progress/category/enque_download.dart';
import 'package:download_progress/category/signle_download.dart';
import 'package:download_progress/category/single_upload.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home Page',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          ElevatedButton(
            onPressed: () {
              navigator(const SingleDownload());
            },
            child: const Text("Single Download"),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              navigator(const EnqueueDownload());
            },
            child: const Text("Enqueue Download"),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              navigator(const BatchDownload());
            },
            child: const Text("Batch Download"),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              navigator(const SingleUpload());
            },
            child: const Text("Single Upload"),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              navigator(const BatchUpload());
            },
            child: const Text("Batch Upload"),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  navigator(page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }
}
