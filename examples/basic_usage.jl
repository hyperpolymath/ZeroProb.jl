# SPDX-License-Identifier: PMPL-1.0-or-later

"""
Basic usage example for ZeroProb.jl

Demonstrates:
1. Zero-probability continuous events
2. Relevance vs. probability
3. The continuum paradox
4. Black swan event modeling
"""

using ZeroProb
using Distributions

println("=== Zero-Probability Events ===\n")

# Example 1: Continuous zero-probability event
dist = Normal(100, 10)
event = ContinuousZeroProbEvent(dist, 100.0)

println("Event: X = 100 where X ~ Normal(100, 10)")
println("Probability P(X = 100): ", probability(event))
println("Relevance (PDF value): ", relevance(event))
println("Density ratio: ", density_ratio(event))
println()

# Example 2: Continuum paradox
println("=== The Continuum Paradox ===\n")
explanation = continuum_paradox()
println(explanation)
println()

# Example 3: Black swan event
println("=== Black Swan Modeling ===\n")
crash = MarketCrashEvent(loss_threshold=1_000_000)
println("Market crash event (loss > \$1M)")
println("Expected impact: \$", expected_impact(crash))
println("Severity: ", impact_severity(crash))
println()

# Example 4: Discrete zero-probability event
println("=== Discrete Zero-Probability ===\n")
discrete_event = DiscreteZeroProbEvent("Fair dice rolls 7", 0.0)
println("Event: ", discrete_event.description)
println("Probability: ", probability(discrete_event))
println("Relevance: ", relevance(discrete_event))
println()

println("✓ All examples complete")
