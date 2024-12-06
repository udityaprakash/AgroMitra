import 'package:agromitra/constant/color.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SoilAnalysisScreen extends StatefulWidget {
  final List<String> images;

  SoilAnalysisScreen({required this.images});

  @override
  _SoilAnalysisScreenState createState() => _SoilAnalysisScreenState();
}

class _SoilAnalysisScreenState extends State<SoilAnalysisScreen> {
  double progress = 0.5;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    simulateProgress();
    cycleImages();
  }

  void simulateProgress() {
    Future.delayed(Duration(milliseconds: 1), () {
      setState(() {
        progress += 0.005;
        if (progress > 1.0) progress = 0.0;
        simulateProgress();
      });
    });
  }

  void cycleImages() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % widget.images.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.newbackground,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 250,
            margin: EdgeInsets.all(50),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
              image: DecorationImage(
                image: NetworkImage(widget.images[currentIndex]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(
                  'https://image-resource.creatie.ai/144550874980048/144550874980050/bbb02b6b263acc62063bd42c246941ca.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Icon(Icons.science, size: 36, color: Colors.black),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Analyzing soil images...",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                "Processing your samples for detailed analysis",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4B5563),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Did you know? A single gram of healthy soil can",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  "contain up to 1 billion bacteria!",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Container(
            width: 250,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9999),
              color: Color(0xFFE5E7EB),
            ),
            child: FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9999),
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Text(
            "This process may take a few moments",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
