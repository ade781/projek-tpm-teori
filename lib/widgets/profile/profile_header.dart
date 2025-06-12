import 'dart:io';
import 'package:flutter/material.dart';
import 'package:projek_akhir_teori/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final User user;
  final VoidCallback onEditImage;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.onEditImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = user.imagePath != null && user.imagePath!.isNotEmpty;

    return SliverAppBar(
      expandedHeight: 300.0, // Slightly increased height
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: theme.colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        stretchModes: const [StretchMode.zoomBackground],
        title: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 300),
          child: Text(
            user.username,
            style: TextStyle(
              fontSize: 24, // Slightly larger font
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onPrimary,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 6,
                  offset: const Offset(1, 2),
                ),
              ],
            ),
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Animated gradient background
            AnimatedContainer(
              duration: const Duration(seconds: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.9),
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
            ),

            // Decorative circles with subtle animation
            Positioned(
              top: -100,
              left: -100,
              child: AnimatedContainer(
                duration: const Duration(seconds: 15),
                curve: Curves.linear,
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Positioned(
              bottom: -50,
              right: -120,
              child: AnimatedContainer(
                duration: const Duration(seconds: 20),
                curve: Curves.linear,
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Profile picture with enhanced styling
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    // Outer glow effect
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 70, // Slightly larger
                        backgroundColor: Colors.white.withOpacity(0.3),
                        child: CircleAvatar(
                          radius: 66,
                          backgroundColor: theme.colorScheme.surface,
                          backgroundImage:
                              hasImage
                                  ? FileImage(File(user.imagePath!))
                                  : null,
                          child:
                              !hasImage
                                  ? Icon(
                                    Icons.person_rounded,
                                    size: 80,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  )
                                  : null,
                        ),
                      ),
                    ),

                    AnimatedScale(
                      scale: 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: GestureDetector(
                        onTap: onEditImage,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.tertiary,
                                theme.colorScheme.tertiaryContainer,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.9),
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

        
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.1)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
