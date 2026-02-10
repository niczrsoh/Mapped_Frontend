import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/controller/trainer_controller.dart';

class DailyCoachingScreen extends StatelessWidget {
  const DailyCoachingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final TrainerController trainerController = Get.isRegistered<TrainerController>() 
        ? Get.find<TrainerController>() 
        : Get.put(TrainerController());

    return Scaffold(
      backgroundColor: const Color(0xFF1a1d2e),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Text(
                    'Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Title
              const Center(
                child: Text(
                  'Daily Coaching Strategy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Today's Focus Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF252836),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF5eead4).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text(
                          'Today\'s Focus',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '🥋',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildBulletPoint(
                      'Warm-up: ankle + hip mobility (5 min)',
                    ),
                    const SizedBox(height: 12),
                    _buildBulletPoint(
                      'Technique: roundhouse -\nchamber → snap → recoil',
                    ),
                    const SizedBox(height: 12),
                    _buildBulletPoint(
                      'Safety: no partner contact for White belts',
                    ),
                    const SizedBox(height: 12),
                    _buildBulletPoint(
                      'Finish: calf/hip stretch 3x20s',
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Ask Coachbot Button
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await trainerController.incrementRecommendationCount();
                    
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5eead4),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.smart_toy, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'ASK COACHBOT',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}