import 'dart:math' as math;
import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';

class SpringCurve extends Curve {
  final double damping;
  final double stiffness;
  final double mass;
  
  const SpringCurve({
    this.damping = 10,
    this.stiffness = 100,
    this.mass = 1,
  });

  @override
  double transform(double t) {
    if (t == 0 || t == 1) return t;
    
    final omega = math.sqrt(stiffness / mass);
    final zeta = damping / (2 * math.sqrt(stiffness * mass));
    
    if (zeta < 1) {
      final omegaD = omega * math.sqrt(1 - zeta * zeta);
      final x = math.exp(-zeta * omega * t) * 
                (math.cos(omegaD * t) + (zeta * omega / omegaD) * math.sin(omegaD * t));
      return 1 - x;
    } else if (zeta == 1) {
      final x = math.exp(-omega * t) * (1 + omega * t);
      return 1 - x;
    } else {
      final r1 = -omega * (zeta - math.sqrt(zeta * zeta - 1));
      final r2 = -omega * (zeta + math.sqrt(zeta * zeta - 1));
      final c2 = (r1 - omega) / (r1 - r2);
      final c1 = 1 - c2;
      final x = c1 * math.exp(r1 * t) + c2 * math.exp(r2 * t);
      return 1 - x;
    }
  }
}

class ElasticCurve extends Curve {
  final double period;
  final double amplitude;
  
  const ElasticCurve({
    this.period = 0.4,
    this.amplitude = 1.0,
  });

  @override
  double transform(double t) {
    if (t == 0 || t == 1) return t;
    
    final s = period / 4;
    final t1 = t - 1;
    return -amplitude * math.pow(2, 10 * t1) * 
           math.sin((t1 - s) * (2 * math.pi) / period);
  }
}

class MagneticCurve extends Curve {
  final double attraction;
  final double range;
  
  const MagneticCurve({
    this.attraction = 2.0,
    this.range = 0.3,
  });

  @override
  double transform(double t) {
    if (t < range) {
      return math.pow(t / range, 1 / attraction) * range;
    } else if (t > 1 - range) {
      final adjustedT = (t - (1 - range)) / range;
      return 1 - range + math.pow(adjustedT, attraction) * range;
    }
    return t;
  }
}

class LiquidCurve extends Curve {
  final double tension;
  final double friction;
  
  const LiquidCurve({
    this.tension = 500,
    this.friction = 20,
  });

  @override
  double transform(double t) {
    if (t == 0 || t == 1) return t;
    
    final dampingRatio = friction / (2 * math.sqrt(tension));
    final angularFreq = math.sqrt(tension - friction * friction / 4);
    
    if (dampingRatio < 1) {
      final envelope = math.exp(-friction * t / 2);
      final oscillation = math.cos(angularFreq * t);
      return 1 - envelope * oscillation;
    } else {
      final a = -friction / 2 + math.sqrt(friction * friction / 4 - tension);
      final b = -friction / 2 - math.sqrt(friction * friction / 4 - tension);
      final envelope = math.exp(a * t) - math.exp(b * t);
      return 1 - envelope;
    }
  }
}

class GlitchCurve extends Curve {
  final int glitches;
  final double intensity;
  
  const GlitchCurve({
    this.glitches = 3,
    this.intensity = 0.1,
  });

  @override
  double transform(double t) {
    if (t == 0 || t == 1) return t;
    
    double result = t;
    for (int i = 0; i < glitches; i++) {
      final glitchPoint = (i + 1) / (glitches + 1);
      final distance = (t - glitchPoint).abs();
      if (distance < 0.05) {
        final random = math.sin(t * 1000 + i * 100);
        result += random * intensity * (1 - distance / 0.05);
      }
    }
    return result.clamp(0.0, 1.0);
  }
}

class WaveCurve extends Curve {
  final double frequency;
  final double amplitude;
  final double phase;
  
  const WaveCurve({
    this.frequency = 3,
    this.amplitude = 0.1,
    this.phase = 0,
  });

  @override
  double transform(double t) {
    final wave = math.sin((t * frequency + phase) * 2 * math.pi) * amplitude;
    return (t + wave).clamp(0.0, 1.0);
  }
}

class BounceCurve extends Curve {
  final int bounces;
  final double decay;
  
  const BounceCurve({
    this.bounces = 3,
    this.decay = 0.5,
  });

  @override
  double transform(double t) {
    if (t == 0 || t == 1) return t;
    
    double value = t;
    double amplitude = 1.0;
    
    for (int i = 0; i < bounces; i++) {
      final bounceStart = i / bounces;
      final bounceEnd = (i + 1) / bounces;
      
      if (t >= bounceStart && t < bounceEnd) {
        final localT = (t - bounceStart) / (bounceEnd - bounceStart);
        final bounce = 4 * localT * (1 - localT);
        value = t + bounce * amplitude * (1 - t);
        break;
      }
      amplitude *= decay;
    }
    
    return value;
  }
}

class AnimationSequence {
  final List<AnimationSpec> animations;
  
  AnimationSequence(this.animations);
  
  Animation<double> build(AnimationController controller) {
    if (animations.isEmpty) {
      return controller;
    }
    
    Animation<double> result = controller;
    double start = 0;
    
    for (final spec in animations) {
      final end = start + spec.duration;
      result = Tween<double>(
        begin: spec.from,
        end: spec.to,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: spec.curve),
      ));
      start = end;
    }
    
    return result;
  }
}

class AnimationSpec {
  final double from;
  final double to;
  final double duration;
  final Curve curve;
  
  const AnimationSpec({
    required this.from,
    required this.to,
    required this.duration,
    this.curve = Curves.linear,
  });
}

class ParallaxAnimation {
  final double depth;
  final double speed;
  final Offset offset;
  
  const ParallaxAnimation({
    this.depth = 1.0,
    this.speed = 1.0,
    this.offset = Offset.zero,
  });
  
  Offset calculate(Offset scrollOffset) {
    return Offset(
      scrollOffset.dx * speed / depth + offset.dx,
      scrollOffset.dy * speed / depth + offset.dy,
    );
  }
}

class PhysicsSimulation {
  final double mass;
  final double stiffness;
  final double damping;
  
  double position;
  double velocity;
  double acceleration;
  
  PhysicsSimulation({
    this.mass = 1.0,
    this.stiffness = 100.0,
    this.damping = 10.0,
    this.position = 0.0,
    this.velocity = 0.0,
    this.acceleration = 0.0,
  });
  
  void applyForce(double force) {
    acceleration = force / mass;
  }
  
  void update(double dt, double target) {
    final springForce = -stiffness * (position - target);
    final dampingForce = -damping * velocity;
    final totalForce = springForce + dampingForce;
    
    acceleration = totalForce / mass;
    velocity += acceleration * dt;
    position += velocity * dt;
  }
  
  bool isSettled(double target, {double threshold = 0.01}) {
    return (position - target).abs() < threshold && velocity.abs() < threshold;
  }
}