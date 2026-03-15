import 'package:ctnh_wiki/features/structure_preview/controllers/structure_step_controller.dart';
import 'package:flutter/material.dart';

class StructureStepTimeline extends StatelessWidget {
  const StructureStepTimeline({super.key, required this.controller});

  final StructureStepController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.hasSteps) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final currentStep = controller.currentStep;
        final currentIndex = controller.currentIndex;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFCF6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE7DCCB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '搭建步骤',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF201A16),
                      ),
                    ),
                  ),
                  _StepArrowButton(
                    icon: Icons.arrow_back_rounded,
                    enabled: currentIndex > 0,
                    onTap: controller.previousStep,
                  ),
                  const SizedBox(width: 8),
                  _StepArrowButton(
                    icon: Icons.arrow_forward_rounded,
                    enabled: currentIndex < controller.stepCount - 1,
                    onTap: controller.nextStep,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                currentStep?.description ?? '当前结构还没有配置步骤信息。',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Color(0xFF5F554D),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(controller.steps.length, (index) {
                  final step = controller.steps[index];
                  final isActive = index == currentIndex;
                  final isReached = index <= currentIndex;

                  return _StepCard(
                    index: index,
                    title: step.title,
                    isActive: isActive,
                    isReached: isReached,
                    onTap: () => controller.goToStep(index),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StepArrowButton extends StatelessWidget {
  const _StepArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFF5E8D5) : const Color(0xFFF4F0EA),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? const Color(0xFF6B4F2D) : const Color(0xFFB0A59A),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.index,
    required this.title,
    required this.isActive,
    required this.isReached,
    required this.onTap,
  });

  final int index;
  final String title;
  final bool isActive;
  final bool isReached;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        width: 190,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF6E4C7) : const Color(0xFFF9F4EC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? const Color(0xFFC88A3D) : const Color(0xFFE7DCCB),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFC88A3D)
                    : isReached
                    ? const Color(0xFFE5D3B8)
                    : const Color(0xFFEFE8DE),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isActive ? Colors.white : const Color(0xFF6B4F2D),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF201A16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
