import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ParticleField extends StatefulWidget {
  final int particleCount;
  final bool enableFlocking;
  final bool enableGravity;
  final bool enableMouseInteraction;
  final Color particleColor;
  final double connectionDistance;
  
  const ParticleField({
    Key? key,
    this.particleCount = 100,
    this.enableFlocking = true,
    this.enableGravity = true,
    this.enableMouseInteraction = true,
    this.particleColor = Colors.cyan,
    this.connectionDistance = 150,
  }) : super(key: key);

  @override
  State<ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<ParticleField>
    with SingleTickerProviderStateMixin {
  late List<AdvancedParticle> particles;
  late Ticker ticker;
  Duration lastTime = Duration.zero;
  Offset mousePosition = Offset.zero;
  bool isMouseActive = false;
  
  final List<GravityWell> gravityWells = [];
  
  @override
  void initState() {
    super.initState();
    _initializeParticles();
    
    ticker = createTicker((elapsed) {
      final dt = elapsed - lastTime;
      lastTime = elapsed;
      _updateParticles(dt.inMilliseconds / 1000.0);
      setState(() {});
    });
    ticker.start();
    
    // Add some gravity wells for interesting movement
    gravityWells.add(GravityWell(
      position: const Offset(0.3, 0.3),
      strength: 50,
      radius: 0.2,
    ));
    gravityWells.add(GravityWell(
      position: const Offset(0.7, 0.7),
      strength: -30,
      radius: 0.15,
    ));
  }

  void _initializeParticles() {
    particles = List.generate(widget.particleCount, (index) {
      return AdvancedParticle(
        position: Offset(
          math.Random().nextDouble(),
          math.Random().nextDouble(),
        ),
        velocity: Offset(
          (math.Random().nextDouble() - 0.5) * 0.1,
          (math.Random().nextDouble() - 0.5) * 0.1,
        ),
        mass: 0.5 + math.Random().nextDouble() * 1.5,
        radius: 1 + math.Random().nextDouble() * 2,
      );
    });
  }

  void _updateParticles(double dt) {
    if (dt <= 0 || dt > 0.1) return; // Skip invalid or large time steps
    
    for (var particle in particles) {
      // Apply flocking behavior
      if (widget.enableFlocking) {
        _applyFlocking(particle, dt);
      }
      
      // Apply gravity wells
      if (widget.enableGravity) {
        _applyGravityWells(particle, dt);
      }
      
      // Apply mouse interaction
      if (widget.enableMouseInteraction && isMouseActive) {
        _applyMouseForce(particle, dt);
      }
      
      // Update physics
      particle.update(dt);
      
      // Wrap around edges
      particle.wrapAround();
    }
  }

  void _applyFlocking(AdvancedParticle particle, double dt) {
    const double visualRange = 0.1;
    const double protectedRange = 0.03;
    const double centeringFactor = 0.0005;
    const double avoidFactor = 0.05;
    const double matchingFactor = 0.05;
    const double maxSpeed = 0.2;
    
    Offset centerOfMass = Offset.zero;
    Offset avoidVector = Offset.zero;
    Offset avgVelocity = Offset.zero;
    int neighbors = 0;
    
    for (var other in particles) {
      if (other == particle) continue;
      
      final distance = (particle.position - other.position).distance;
      
      if (distance < visualRange) {
        // Cohesion
        centerOfMass += other.position;
        neighbors++;
        
        // Alignment
        avgVelocity += other.velocity;
        
        // Separation
        if (distance < protectedRange && distance > 0) {
          avoidVector += (particle.position - other.position) / distance;
        }
      }
    }
    
    if (neighbors > 0) {
      // Apply cohesion
      centerOfMass = centerOfMass / neighbors.toDouble();
      particle.velocity += (centerOfMass - particle.position) * centeringFactor;
      
      // Apply alignment
      avgVelocity = avgVelocity / neighbors.toDouble();
      particle.velocity += (avgVelocity - particle.velocity) * matchingFactor;
    }
    
    // Apply separation
    particle.velocity += avoidVector * avoidFactor;
    
    // Limit speed
    final speed = particle.velocity.distance;
    if (speed > maxSpeed) {
      particle.velocity = particle.velocity / speed * maxSpeed;
    }
  }

  void _applyGravityWells(AdvancedParticle particle, double dt) {
    for (var well in gravityWells) {
      final distance = (particle.position - well.position).distance;
      if (distance < well.radius && distance > 0.01) {
        final force = well.strength / (distance * distance);
        final direction = (well.position - particle.position) / distance;
        particle.applyForce(direction * force * dt);
      }
    }
  }

  void _applyMouseForce(AdvancedParticle particle, double dt) {
    final distance = (particle.position - mousePosition).distance;
    if (distance < 0.2 && distance > 0.01) {
      const double mouseStrength = -100;
      final force = mouseStrength / (distance * distance);
      final direction = (particle.position - mousePosition) / distance;
      particle.applyForce(direction * force * dt);
    }
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isMouseActive = true),
      onExit: (_) => setState(() => isMouseActive = false),
      onHover: (event) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final size = box.size;
        setState(() {
          mousePosition = Offset(
            event.localPosition.dx / size.width,
            event.localPosition.dy / size.height,
          );
        });
      },
      child: CustomPaint(
        painter: ParticleFieldPainter(
          particles: particles,
          particleColor: widget.particleColor,
          connectionDistance: widget.connectionDistance,
          gravityWells: gravityWells,
          showGravityWells: widget.enableGravity,
        ),
        child: Container(),
      ),
    );
  }
}

class ParticleFieldPainter extends CustomPainter {
  final List<AdvancedParticle> particles;
  final Color particleColor;
  final double connectionDistance;
  final List<GravityWell> gravityWells;
  final bool showGravityWells;

  ParticleFieldPainter({
    required this.particles,
    required this.particleColor,
    required this.connectionDistance,
    required this.gravityWells,
    this.showGravityWells = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw gravity wells (subtle)
    if (showGravityWells) {
      for (var well in gravityWells) {
        final center = Offset(
          well.position.dx * size.width,
          well.position.dy * size.height,
        );
        final radius = well.radius * size.width;
        
        final paint = Paint()
          ..style = PaintingStyle.fill
          ..shader = RadialGradient(
            colors: [
              well.strength > 0
                  ? Colors.purple.withOpacity(0.05)
                  : Colors.orange.withOpacity(0.05),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius));
        
        canvas.drawCircle(center, radius, paint);
      }
    }
    
    // Draw particle connections
    final connectionPaint = Paint()
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final p1 = particles[i];
        final p2 = particles[j];
        
        final pos1 = Offset(p1.position.dx * size.width, p1.position.dy * size.height);
        final pos2 = Offset(p2.position.dx * size.width, p2.position.dy * size.height);
        
        final distance = (pos1 - pos2).distance;
        
        if (distance < connectionDistance) {
          final opacity = math.pow(1 - (distance / connectionDistance), 2).toDouble();
          connectionPaint.color = particleColor.withOpacity(opacity * 0.2);
          
          // Draw curved connection for more organic look
          final midPoint = Offset(
            (pos1.dx + pos2.dx) / 2,
            (pos1.dy + pos2.dy) / 2,
          );
          
          final controlPoint = Offset(
            midPoint.dx + math.sin(distance * 0.1) * 10,
            midPoint.dy + math.cos(distance * 0.1) * 10,
          );
          
          final path = Path()
            ..moveTo(pos1.dx, pos1.dy)
            ..quadraticBezierTo(
              controlPoint.dx,
              controlPoint.dy,
              pos2.dx,
              pos2.dy,
            );
          
          canvas.drawPath(path, connectionPaint);
        }
      }
    }
    
    // Draw particles with glow effect
    for (var particle in particles) {
      final position = Offset(
        particle.position.dx * size.width,
        particle.position.dy * size.height,
      );
      
      // Outer glow
      final glowPaint = Paint()
        ..color = particleColor.withOpacity(0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
      canvas.drawCircle(
        position,
        particle.radius * 3,
        glowPaint,
      );
      
      // Core particle
      final particlePaint = Paint()
        ..color = particleColor.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        position,
        particle.radius,
        particlePaint,
      );
      
      // Inner bright spot
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.9)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        position,
        particle.radius * 0.3,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AdvancedParticle {
  Offset position;
  Offset velocity;
  Offset acceleration;
  double mass;
  double radius;
  Color color;
  double life;
  
  AdvancedParticle({
    required this.position,
    required this.velocity,
    this.acceleration = Offset.zero,
    this.mass = 1.0,
    this.radius = 2.0,
    this.color = Colors.cyan,
    this.life = 1.0,
  });
  
  void applyForce(Offset force) {
    acceleration += force / mass;
  }
  
  void update(double dt) {
    velocity += acceleration * dt;
    position += velocity * dt;
    acceleration = Offset.zero;
    
    // Add some turbulence
    final turbulence = Offset(
      (math.Random().nextDouble() - 0.5) * 0.001,
      (math.Random().nextDouble() - 0.5) * 0.001,
    );
    velocity += turbulence;
    
    // Apply damping
    velocity *= 0.99;
  }
  
  void wrapAround() {
    if (position.dx < 0) position = Offset(1.0, position.dy);
    if (position.dx > 1) position = Offset(0.0, position.dy);
    if (position.dy < 0) position = Offset(position.dx, 1.0);
    if (position.dy > 1) position = Offset(position.dx, 0.0);
  }
}

class GravityWell {
  final Offset position;
  final double strength;
  final double radius;
  
  GravityWell({
    required this.position,
    required this.strength,
    required this.radius,
  });
}