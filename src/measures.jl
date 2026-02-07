# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell <jonathan.jewell@open.ac.uk>

"""
Alternative measures for quantifying the "relevance" of zero-probability events.

While P(E) = 0 for individual points in continuous distributions, these events
can still have significance that we capture through alternative measures.
"""

"""
    probability(event::ZeroProbEvent) -> Float64

Return the actual probability of the event (always 0.0 for true zero-probability events).

This is the baseline measure - the event has zero probability in the classical sense.
"""
function probability(event::ContinuousZeroProbEvent{T}) where T
    return 0.0  # By definition
end

function probability(event::DiscreteZeroProbEvent{T}) where T
    return pdf(event.distribution, event.point)
end

"""
    density_ratio(event::ContinuousZeroProbEvent{T}) -> Float64

Use the probability density function (PDF) value as a relevance measure.

While P(X = x) = 0 in continuous distributions, pdf(X, x) > 0 represents the
"density" of probability mass near that point. This is useful for comparing
the relative importance of different zero-probability events.

# Examples

```julia
# Normal distribution - center has highest density
dist = Normal(0, 1)
center = ContinuousZeroProbEvent(dist, 0.0)
tail = ContinuousZeroProbEvent(dist, 3.0)

@assert density_ratio(center) > density_ratio(tail)  # Center is "more relevant"
```
"""
function density_ratio(event::ContinuousZeroProbEvent{T}) where T
    return pdf(event.distribution, event.point)
end

"""
    hausdorff_measure(event::ContinuousZeroProbEvent{T}, dimension::Int=0) -> Float64

Compute the Hausdorff measure of the event.

For a single point in ℝⁿ, the Hausdorff measure with dimension 0 is 1.
This is a measure-theoretic way to assign "size" to sets that have zero Lebesgue measure.

# Arguments
- `event`: The zero-probability event
- `dimension`: Hausdorff dimension (default 0 for points)

# Examples

```julia
event = ContinuousZeroProbEvent(Normal(0, 1), 0.0)
@assert hausdorff_measure(event, 0) == 1.0  # Point has unit 0-dimensional measure
@assert hausdorff_measure(event, 1) == 0.0  # But zero 1-dimensional measure
```
"""
function hausdorff_measure(event::ContinuousZeroProbEvent{T}, dimension::Int=0) where T
    if dimension == 0
        return 1.0  # Single point has unit 0-dimensional Hausdorff measure
    elseif dimension == 1
        return 0.0  # But zero 1-dimensional measure
    else
        throw(ArgumentError("Only dimensions 0 and 1 currently supported"))
    end
end

"""
    epsilon_neighborhood(event::ContinuousZeroProbEvent{T}, ε::Float64) -> Float64

Compute P(|X - x| < ε) - the probability of being within ε of the zero-probability point.

This is a practical measure: while P(X = x) = 0, we can ask "what's the probability
of getting close enough?" This is useful in applications where approximate equality
matters (betting, auctions, physical measurements).

# Examples

```julia
dist = Normal(0, 1)
event = ContinuousZeroProbEvent(dist, 0.0)

# Probability of being within 0.1 of 0
prob_near = epsilon_neighborhood(event, 0.1)
@assert prob_near ≈ cdf(dist, 0.1) - cdf(dist, -0.1)
```
"""
function epsilon_neighborhood(event::ContinuousZeroProbEvent{T}, ε::Float64) where T
    @assert ε > 0.0 "ε must be positive"

    dist = event.distribution
    x = event.point

    # P(|X - x| < ε) = P(x - ε < X < x + ε) = cdf(x + ε) - cdf(x - ε)
    return cdf(dist, x + ε) - cdf(dist, x - ε)
end

"""
    relevance(event::ZeroProbEvent; kwargs...) -> Float64

Compute a relevance score for the zero-probability event using the configured measure.

This dispatches to the appropriate measure based on the event's `relevance_measure` field:
- `:density` → `density_ratio(event)`
- `:hausdorff` → `hausdorff_measure(event, dimension)`
- `:epsilon` → `epsilon_neighborhood(event, ε)`

# Keyword Arguments
- `dimension::Int=0`: Hausdorff dimension (for :hausdorff measure)
- `ε::Float64=0.01`: Neighborhood radius (for :epsilon measure)

# Examples

```julia
# Default: density ratio
event = ContinuousZeroProbEvent(Normal(0, 1), 0.0, :density)
@assert relevance(event) ≈ pdf(Normal(0, 1), 0.0)

# Hausdorff measure
event_h = ContinuousZeroProbEvent(Normal(0, 1), 0.0, :hausdorff)
@assert relevance(event_h) == 1.0

# Epsilon neighborhood
event_e = ContinuousZeroProbEvent(Normal(0, 1), 0.0, :epsilon)
@assert relevance(event_e, ε=0.1) > 0.0
```
"""
function relevance(event::ContinuousZeroProbEvent{T};
                   dimension::Int=0, ε::Float64=0.01) where T
    measure = event.relevance_measure

    if measure == :density
        return density_ratio(event)
    elseif measure == :hausdorff
        return hausdorff_measure(event, dimension)
    elseif measure == :epsilon
        return epsilon_neighborhood(event, ε)
    else
        error("Unknown relevance measure: $measure")
    end
end

"""
    relevance_score(event::ZeroProbEvent, application::Symbol) -> Float64

Compute an application-specific relevance score.

Different applications care about different aspects of zero-probability events:
- `:black_swan` - How catastrophic would this event be?
- `:betting` - How much edge would this give in a betting system?
- `:decision_theory` - How should this influence decisions under uncertainty?

# Examples

```julia
crash = MarketCrashEvent(loss_threshold = 1_000_000)
score = relevance_score(crash, :black_swan)
# Returns high score because even P=0 events matter when catastrophic
```
"""
function relevance_score(event::ContinuousZeroProbEvent{T}, application::Symbol) where T
    if application == :black_swan
        # For black swans, even tiny probabilities of extreme events matter
        # Use a combination of density and tail behavior
        density = density_ratio(event)
        tail_weight = 1.0 / (1.0 + abs(event.point))  # Penalize extreme tails
        return density * tail_weight
    elseif application == :betting
        # For betting, we care about the density near the bet point
        return density_ratio(event)
    elseif application == :decision_theory
        # General decision-theoretic relevance
        return epsilon_neighborhood(event, 0.05)  # 5% neighborhood
    else
        error("Unknown application: $application")
    end
end
