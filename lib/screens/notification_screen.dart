import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/controller/notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});
  final controller = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1D29),
              Color(0xFF0D4D4D),
              Color(0xFF1A1D29),
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    Expanded(
                      child: Text(
                        'Notifications',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Common Section
                        _buildSectionHeader('Common'),
                        SizedBox(height: 16),
                        _buildNotificationTile(
                          title: 'General Notification',
                          value: controller.generalNotification,
                          onChanged: (val) => controller.generalNotification.value = val,
                        ),
                        _buildNotificationTile(
                          title: 'Sound',
                          value: controller.sound,
                          onChanged: (val) => controller.sound.value = val,
                        ),
                        _buildNotificationTile(
                          title: 'Vibrate',
                          value: controller.vibrate,
                          onChanged: (val) => controller.vibrate.value = val,
                        ),
                        
                        SizedBox(height: 24),
                        
                        // System & services update Section
                        _buildSectionHeader('System & services update'),
                        SizedBox(height: 16),
                        _buildNotificationTile(
                          title: 'App updates',
                          value: controller.appUpdates,
                          onChanged: (val) => controller.appUpdates.value = val,
                        ),
                        _buildNotificationTile(
                          title: 'Bill Reminder',
                          value: controller.billReminder,
                          onChanged: (val) => controller.billReminder.value = val,
                        ),
                        _buildNotificationTile(
                          title: 'Promotion',
                          value: controller.promotion,
                          onChanged: (val) => controller.promotion.value = val,
                        ),
                        _buildNotificationTile(
                          title: 'Discount Avaiable',
                          value: controller.discountAvailable,
                          onChanged: (val) => controller.discountAvailable.value = val,
                        ),
                        _buildNotificationTile(
                          title: 'Payment Request',
                          value: controller.paymentRequest,
                          onChanged: (val) => controller.paymentRequest.value = val,
                        ),
                        
                        SizedBox(height: 24),
                        
                        // Others Section
                        _buildSectionHeader('Others'),
                        SizedBox(height: 16),
                        _buildNotificationTile(
                          title: 'New Service Available',
                          value: controller.newServiceAvailable,
                          onChanged: (val) => controller.newServiceAvailable.value = val,
                        ),
                        _buildNotificationTile(
                          title: 'New Tips Available',
                          value: controller.newTipsAvailable,
                          onChanged: (val) => controller.newTipsAvailable.value = val,
                        ),
                        
                        SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _buildNotificationTile({
    required String title,
    required RxBool value,
    required Function(bool) onChanged,
  }) {
    return Obx(() => Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              letterSpacing: 0.25,
            ),
          ),
          Transform.scale(
            scale: 0.75,
            child: Switch(
              value: value.value,
              onChanged: onChanged,
              activeColor: Color.fromARGB(255, 1, 250, 254),
              activeTrackColor: Color.fromARGB(255, 1, 250, 254).withValues(alpha: .5),
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[700],
            ),  
          ),
        ],
      ),
    ));
  }
}