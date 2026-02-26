import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'recommendation_controller.dart';

class RecommendationDetailsScreen extends StatelessWidget {
  const RecommendationDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RecommendationController controller =
        Get.find<RecommendationController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1a1d2e),
      appBar: AppBar(
        backgroundColor: const Color(0xFF252836),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'rec_details_title'.tr(),
          style: const TextStyle(color: Colors.white),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.share, color: Color(0xFF5eead4)),
        //     onPressed: () {
        //       // Implement share functionality
        //     },
        //   ),
        // ],
      ),
      body: Obx(() {
        if (controller.currentRecommendation.value == null) {
          return Center(
            child: Text(
              'rec_details_empty'.tr(),
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        final rec = controller.currentRecommendation.value!;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(rec),
                const SizedBox(height: 32),

                // Primary Goal
                _buildSection(
                  title: 'section_primary'.tr(),
                  child: Text(
                    rec.recommendation.goals.primary,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Secondary Goals
                if (rec.recommendation.goals.secondary.isNotEmpty) ...[
                  _buildSection(
                    title: 'section_secondary'.tr(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: rec.recommendation.goals.secondary
                          .map(
                            (goal) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '• ',
                                    style: TextStyle(
                                      color: Color(0xFF5eead4),
                                      fontSize: 16,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      goal,
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Reasoning
                _buildSection(
                  title: 'section_reasoning'.tr(),
                  child: Text(
                    rec.recommendation.goals.reasoning,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Session Breakdown
                _buildSectionTitle('section_breakdown'.tr()),
                const SizedBox(height: 16),

                // Warmup
                _buildPhaseCard(
                  emoji: '🏃',
                  title: 'rec_details_phase_warmup'.tr(),
                  time: rec.recommendation.warmup.suggestedTime,
                  description: rec.recommendation.warmup.description,
                  exercises: rec.recommendation.warmup.keyExercises,
                ),
                const SizedBox(height: 16),

                // Main Activity
                _buildActivityCard(rec.recommendation.activity),
                const SizedBox(height: 16),

                // Cooldown
                _buildPhaseCard(
                  emoji: '🧘',
                  title: 'rec_details_phase_cooldown'.tr(),
                  time: rec.recommendation.cooldown.suggestedTime,
                  description: rec.recommendation.cooldown.description,
                  exercises: rec.recommendation.cooldown.keyExercises,
                ),
                const SizedBox(height: 32),

                // Risk Assessment
                if (rec.recommendation.riskAssessment.keyRisks.isNotEmpty) ...[
                  _buildSectionTitle('section_safety'.tr()),
                  const SizedBox(height: 12),
                  _buildRiskCard(rec.recommendation.riskAssessment),
                  const SizedBox(height: 24),
                ],

                // Resources
                if (rec.recommendation.resources.required.isNotEmpty) ...[
                  _buildSectionTitle('section_resources'.tr()),
                  const SizedBox(height: 12),
                  _buildResourcesCard(rec.recommendation.resources),
                  const SizedBox(height: 24),
                ],

                // Contingencies
                if (rec.recommendation.contingencies.scenarios.isNotEmpty) ...[
                  _buildSectionTitle('section_backup'.tr()),
                  const SizedBox(height: 12),
                  _buildContingenciesCard(rec.recommendation.contingencies),
                  const SizedBox(height: 24),
                ],

                // Tips for Today
                if (rec.insights.tipsForToday.isNotEmpty) ...[
                  _buildSectionTitle('section_tips'.tr()),
                  const SizedBox(height: 12),
                  _buildTipsCard(rec.insights.tipsForToday),
                  const SizedBox(height: 24),
                ],

                // Analysis Context
                _buildAnalysisContext(rec.analysisContext),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader(rec) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF5eead4).withOpacity(0.2),
            const Color(0xFF5eead4).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'level'.tr(),
                  rec.recommendation.suggestedLevel,
                  Icons.trending_up,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey[700]),
              Expanded(
                child: _buildStatItem(
                  'duration'.tr(),
                  '${rec.recommendation.suggestedDuration} min',
                  Icons.timer,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey[700]),
              Expanded(
                child: _buildStatItem(
                  'rec_details_stat_trainees'.tr(),
                  '${rec.recommendation.suggestedTraineeCount}',
                  Icons.group,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF5eead4), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildSectionTitle(title), const SizedBox(height: 12), child],
    );
  }

  Widget _buildPhaseCard({
    required String emoji,
    required String title,
    required int time,
    required String description,
    required List<String> exercises,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF252836),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF5eead4).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF5eead4).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$time min',
                  style: const TextStyle(
                    color: Color(0xFF5eead4),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
          if (exercises.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'rec_details_lbl_exercises'.tr(),
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...exercises
                .map(
                  (exercise) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(color: Color(0xFF5eead4)),
                        ),
                        Expanded(
                          child: Text(
                            exercise,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityCard(activity) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF252836),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF5eead4).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🥋', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'rec_details_phase_activity'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF5eead4).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${activity.suggestedTime} min',
                  style: const TextStyle(
                    color: Color(0xFF5eead4),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            activity.description,
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          if (activity.focusAreas.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'rec_details_lbl_focus'.tr(),
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: activity.focusAreas
                  .map<Widget>(
                    (area) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5eead4).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF5eead4).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        area,
                        style: const TextStyle(
                          color: Color(0xFF5eead4),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (activity.drills.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'rec_details_lbl_drills'.tr(),
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...activity.drills
                .map(
                  (drill) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(color: Color(0xFF5eead4)),
                        ),
                        Expanded(
                          child: Text(
                            drill,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildRiskCard(riskAssessment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252836),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (riskAssessment.keyRisks.isNotEmpty) ...[
            Text(
              'rec_details_lbl_risks'.tr(),
              style: TextStyle(
                color: Colors.grey[300],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...riskAssessment.keyRisks
                .map(
                  (risk) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('⚠️ ', style: TextStyle(fontSize: 14)),
                        Expanded(
                          child: Text(
                            risk,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
          if (riskAssessment.mitigationStrategies.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'rec_details_lbl_mitigation'.tr(),
              style: TextStyle(
                color: Colors.grey[300],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...riskAssessment.mitigationStrategies
                .map(
                  (strategy) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '✓ ',
                          style: TextStyle(color: Colors.green, fontSize: 14),
                        ),
                        Expanded(
                          child: Text(
                            strategy,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildResourcesCard(resources) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252836),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...resources.required
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildContingenciesCard(contingencies) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252836),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: contingencies.scenarios
            .map<Widget>(
              (scenario) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('📌 ', style: TextStyle(fontSize: 14)),
                        Expanded(
                          child: Text(
                            scenario.situation,
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        '→ ${scenario.solution}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildTipsCard(List<String> tips) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252836),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF5eead4).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: tips
            .map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡 ', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(color: Colors.grey[300], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildAnalysisContext(context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252836).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'rec_details_analysis_title'.tr(),
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'rec_details_analysis_summary'.tr(
              namedArgs: {
                'sessions': context.totalSessionsAnalyzed.toString(),
                'belt': context.userBeltLevel,
                'days': context.daysSinceLastSession.toString(),
              },
            ),
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
