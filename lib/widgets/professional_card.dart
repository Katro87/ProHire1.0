import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mini_fiverr/models/user_model.dart';
import 'package:mini_fiverr/utils/theme.dart';

class ProfessionalCard extends StatelessWidget {
  final UserModel professional;
  final VoidCallback onTap;

  const ProfessionalCard({
    super.key,
    required this.professional,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rating = professional.rating ?? 5.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.cardGradient1Start.withOpacity(0.05),
            AppColors.cardGradient1End.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1.2,
        ),
        boxShadow: [AppShadows.mediumShadow],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((professional.rating ?? 0) >= 4.8)
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.accent, AppColors.accentDark],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [AppShadows.glowShadow],
                          ),
                          child: const Text(
                            '🏆 TOP RATED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.35),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                            child: CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(professional.profilePicUrl),
                            backgroundColor: AppColors.primary.withOpacity(0.08),
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                professional.name,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                professional.professionalTitle ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  ...List.generate(5, (i) => Icon(
                                    i < rating.floor() ? Icons.star : Icons.star_half,
                                    size: 16,
                                    color: AppColors.warning,
                                  )),
                                  const SizedBox(width: 6),
                                  Text(
                                    '\$${(professional.hourlyRate ?? 0).toStringAsFixed(0)}/hr',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [AppShadows.glowShadow],
                      ),
                      child: Text(
                        '💵 \$${(professional.hourlyRate ?? 0).toStringAsFixed(0)}/hr',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (professional.skills ?? []).take(4).map<Widget>((skill) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          skill.toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )).toList(),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      professional.bio ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.primary.withOpacity(0.5),
                        ),
                        child: const Text(
                          '🚀  VIEW PROFILE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
  }
}
