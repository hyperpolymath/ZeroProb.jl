# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell <jonathan.jewell@open.ac.uk>

"""
Pedagogical examples of zero-probability paradoxes.

These functions demonstrate counterintuitive properties of zero-probability events
for teaching and exploration.
"""

"""
    continuum_paradox(dist::Distribution, examples::Int=5) -> Dict

Demonstrate the continuum paradox: the unit interval (or any continuous distribution)
can be decomposed as a union of disjoint zero-probability points, yet P(Ω) = 1, not 0.

# Returns
A dictionary with:
- `:points` - Sample points (each has P = 0)
- `:individual_probs` - All zeros
- `:union_prob` - 1.0 (the whole space)
- `:explanation` - Why this isn't a contradiction

# Examples

```julia
result = continuum_paradox(Normal(0, 1), 5)
@assert all(result[:individual_probs] .== 0.0)
@assert result[:union_prob] == 1.0
println(result[:explanation])
```
"""
function continuum_paradox(dist::Distribution, examples::Int=5)
    # Sample some points from the distribution
    points = rand(dist, examples)

    # Each point has zero probability
    individual_probs = [probability(ContinuousZeroProbEvent(dist, p)) for p in points]

    # But the whole space has probability 1
    union_prob = 1.0

    explanation = """
    The Continuum Paradox:

    Each individual point has P(X = x) = 0.
    Yet the entire space (union of ALL such points) has P(Ω) = 1.

    Resolution:
    - Probability is σ-additive (countably additive), not fully additive
    - You cannot sum uncountably many numbers (even zeros) and expect 0
    - The sum of uncountably many zeros is not defined
    - Measure theory resolves this: Lebesgue measure of a point is 0,
      but Lebesgue measure of [a,b] is b-a

    Key Insight:
    Zero-probability ≠ impossibility in continuous spaces.
    """

    return Dict(
        :points => points,
        :individual_probs => individual_probs,
        :union_prob => union_prob,
        :explanation => explanation
    )
end

"""
    borel_kolmogorov_paradox() -> Dict

Demonstrate the Borel-Kolmogorov paradox: conditioning on a zero-probability
event can lead to ambiguous results depending on how you approach the limit.

The classic example: Given (X, Y) ~ Uniform(unit circle), what is the conditional
distribution of X given Y = 0?

# Returns
A dictionary explaining the paradox and showing different limits give different answers.

# Examples

```julia
result = borel_kolmogorov_paradox()
println(result[:explanation])
println("Approach 1 (horizontal): ", result[:approach_1])
println("Approach 2 (radial): ", result[:approach_2])
```
"""
function borel_kolmogorov_paradox()
    explanation = """
    Borel-Kolmogorov Paradox:

    Setup: (X, Y) uniformly distributed on the unit circle.
    Question: What is P(X | Y = 0)?

    The problem: Y = 0 is a zero-probability event!
    Conditioning on P = 0 events is ambiguous.

    Approach 1 (Horizontal limit):
    Condition on Y ∈ [-ε, ε] and take ε → 0.
    Result: X is uniform on the intersection (two points on circle).

    Approach 2 (Radial limit):
    Condition on angle θ ∈ [-ε, ε] and take ε → 0.
    Result: X is concentrated at (1, 0) and (-1, 0) differently.

    Different limits → different conditional distributions!

    Resolution:
    You must specify HOW you condition (which σ-algebra).
    There's no unique "right" conditional probability on zero-probability events.

    Key Insight:
    P(A | B) when P(B) = 0 requires extra structure beyond probability alone.
    """

    return Dict(
        :explanation => explanation,
        :approach_1 => "Horizontal limit: X ~ depends on limiting process",
        :approach_2 => "Radial limit: X ~ depends on limiting process",
        :resolution => "Must specify the limiting σ-algebra"
    )
end

"""
    rational_points_paradox(interval=(0.0, 1.0), samples::Int=1000) -> Dict

Demonstrate that rational numbers in [0,1] have zero probability yet are infinite.

# Examples

```julia
result = rational_points_paradox((0.0, 1.0), 1000)
println(result[:explanation])
@assert result[:prob_rational] == 0.0
@assert result[:count_rationals] == Inf
```
"""
function rational_points_paradox(interval=(0.0, 1.0), samples::Int=1000)
    a, b = interval

    # Sample from uniform distribution
    dist = Uniform(a, b)
    samples_drawn = rand(dist, samples)

    # Check how many are rational (in practice, none due to Float64 representation)
    # But mathematically, rationals are dense in reals
    count_rational = 0  # In practice, floating point numbers aren't truly rational

    explanation = """
    Rational Points Paradox:

    Facts:
    1. Rational numbers ℚ are countably infinite
    2. Rational numbers are dense in ℝ (between any two reals, there's a rational)
    3. Yet P(X ∈ ℚ) = 0 for X ~ Uniform[0,1]

    Why?
    - Probability depends on measure, not cardinality
    - Countable sets have Lebesgue measure zero
    - ℚ is countable, so μ(ℚ ∩ [0,1]) = 0

    Intuition:
    - If you pick a random real in [0,1], you'll "almost surely" get an irrational
    - The rationals are "too sparse" to have positive probability
    - Yet they're everywhere (dense)!

    Key Insight:
    Dense ≠ positive measure. Cardinality ≠ probability.
    """

    return Dict(
        :samples => samples_drawn,
        :count_sampled_rationals => count_rational,
        :prob_rational => 0.0,  # Theoretical probability
        :count_rationals => Inf,  # But infinitely many of them!
        :are_rationals_dense => true,
        :explanation => explanation
    )
end

"""
    uncountable_union_paradox(dist::Distribution, num_points::Int=10) -> Dict

Show that the union of uncountably many zero-probability events can have probability 1.

# Examples

```julia
result = uncountable_union_paradox(Normal(0, 1), 10)
println(result[:explanation])
```
"""
function uncountable_union_paradox(dist::Distribution, num_points::Int=10)
    # Sample some points
    points = rand(dist, num_points)

    # Each has zero probability
    point_probs = zeros(num_points)

    explanation = """
    Uncountable Union Paradox:

    Consider the sample space Ω of a continuous distribution.
    - Ω = ⋃{x} for all x in the support (uncountable union)
    - Each individual point {x} has P({x}) = 0
    - Yet P(Ω) = 1

    Why doesn't 0 + 0 + 0 + ... = 0?

    Resolution:
    - You cannot sum uncountably many numbers
    - Probability is only σ-additive (countably additive)
    - For uncountable unions, you need measure theory, not arithmetic

    Countable additivity:
    If A₁, A₂, ... are disjoint and countable:
    P(⋃ Aᵢ) = Σ P(Aᵢ)

    Uncountable unions:
    This rule does NOT extend to uncountable unions!

    Key Insight:
    The sum of uncountably many zeros is NOT zero.
    Countable vs. uncountable is a fundamental divide.
    """

    return Dict(
        :sample_points => points,
        :individual_probs => point_probs,
        :union_prob => 1.0,
        :countable_additivity => true,
        :uncountable_additivity => false,
        :explanation => explanation
    )
end

"""
    almost_sure_vs_sure() -> String

Explain the crucial distinction between "almost sure" and "sure" events.

# Examples

```julia
println(almost_sure_vs_sure())
```
"""
function almost_sure_vs_sure()
    return """
    Almost Surely vs. Surely: The Critical Distinction

    SURE EVENT:
    - Holds for ALL sample points, without exception
    - P(E) = 1 AND E contains the entire sample space
    - Example: "A real number is either rational or irrational" (sure)

    ALMOST SURE (a.s.) EVENT:
    - Holds except possibly on a zero-probability set
    - P(E) = 1 BUT there exist exceptions (just with P = 0)
    - Example: "A random real in [0,1] is irrational" (almost sure, not sure)

    Key Examples:

    1. X ~ Uniform[0,1]
       - "X ∈ [0,1]" is SURE (no exceptions)
       - "X is irrational" is ALMOST SURE (rationals are exceptions, but P(ℚ) = 0)

    2. Continuous random walks
       - "Walk visits every point" is NOT sure (won't hit specific points)
       - "Walk gets arbitrarily close to every point" is ALMOST SURE

    3. Strong Law of Large Numbers
       - Sample mean converges to expectation ALMOST SURELY
       - Not SURELY (pathological sequences exist, but have P = 0)

    Why It Matters:

    In practice, "almost surely" and "surely" are often treated the same
    (zero-probability exceptions don't occur in finite samples).

    But theoretically, the distinction is crucial:
    - Formal proofs require careful handling
    - Conditioning on zero-probability events is problematic
    - Foundations of probability theory depend on this

    Rule of Thumb:
    If you can say "P = 1", you have "almost surely".
    If you can say "no exceptions possible", you have "surely".
    """
end
