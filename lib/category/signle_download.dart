import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class SingleDownload extends StatefulWidget {
  const SingleDownload({super.key});

  @override
  State<SingleDownload> createState() => _SingleDownloadState();
}

class _SingleDownloadState extends State<SingleDownload> {
  double progressPer = 0;
  late DownloadTask task;
  bool isPause = false;

  @override
  void dispose() {
    FileDownloader().destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Single Download',
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
                          if (progressPer > 0) {
                            if (!isPause) {
                              await pauseDownload();
                            } else {
                              resumeDownload();
                            }
                          }
                        },
                        icon: Icon(isPause ? Icons.play_arrow : Icons.pause))),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                    child: IconButton(
                        onPressed: () async {
                          await cancelDownload();
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
          await downloadFile();
        },
        child: const Icon(Icons.download),
      ),
    );
  }

  downloadFile() async {
    try {
      // FileDownloader().reset();
      // FileDownloader().destroy();
      task = DownloadTask(
          url:
              "https://jsoncompare.org/LearningContainer/SampleFiles/Video/MP4/Sample-MP4-Video-File-Download.mp4",
          filename: "sampleVideo",
          directory: 'my_sub_directory',
          updates: Updates.statusAndProgress,
          requiresWiFi: true,
          retries: 5,
          allowPause: true,
          metaData: 'data for me');

      await FileDownloader().download(
        task,
        onProgress: (value) {
          if (!value.isNegative) {
            progressPer = value;
            setState(() {});
          }
        },
        onStatus: (status) {
          print(status);
        },
      );
    } catch (e) {
      print(e.toString());
    }
  }

  pauseDownload() async {
    setState(() {
      isPause = true;
    });
    await FileDownloader().pause(task);
  }

  cancelDownload() async {
    setState(() {
      isPause = false;
    });
    await FileDownloader().cancelTaskWithId(task.taskId).whenComplete(() {
      setState(() {
        progressPer = 0;
      });
    });
  }

  resumeDownload() async {
    setState(() {
      isPause = false;
    });
    await FileDownloader().resume(task);
  }
}
