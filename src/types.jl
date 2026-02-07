# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell <jonathan.jewell@open.ac.uk>

"""
Core type system for zero-probability events.

Defines the hierarchy of events and their properties in continuous and discrete
probability spaces.
"""

# Abstract base type
"""
    ZeroProbEvent

Abstract base type for all zero-probability events.

A zero-probability event is an event E where P(E) = 0, but which can still occur
in the sample space. This is common in continuous distributions where individual
points have measure zero.
"""
abstract type ZeroProbEvent end

"""
    ContinuousZeroProbEvent{T<:Real} <: ZeroProbEvent

A zero-probability event in a continuous distribution.

# Fields
- `distribution::Distribution`: The probability distribution
- `point::T`: The specific point with P(X = point) = 0
- `relevance_measure::Symbol`: Which measure to use for relevance (:density, :hausdorff, :epsilon)

# Examples

```julia
# Exact value in a normal distribution
event = ContinuousZeroProbEvent(Normal(0, 1), 0.0, :density)
@assert probability(event) == 0.0
@assert relevance(event) ≈ pdf(Normal(0, 1), 0.0)

# Hitting exactly £100 in a gambling scenario
gambling_event = ContinuousZeroProbEvent(Normal(100, 10), 100.0, :density)
```
"""
struct ContinuousZeroProbEvent{T<:Real} <: ZeroProbEvent
    distribution::Distribution
    point::T
    relevance_measure::Symbol

    function ContinuousZeroProbEvent{T}(dist::Distribution, point::T,
                                        measure::Symbol=:density) where T<:Real
        @assert measure in [:density, :hausdorff, :epsilon] "Invalid relevance measure"
        new{T}(dist, point, measure)
    end
end

# Convenience constructor
ContinuousZeroProbEvent(dist::Distribution, point::T, measure::Symbol=:density) where T<:Real =
    ContinuousZeroProbEvent{T}(dist, point, measure)

"""
    DiscreteZeroProbEvent{T} <: ZeroProbEvent

A zero-probability event in a discrete distribution.

In truly discrete distributions, zero-probability events don't typically manifest
unless they are outside the support. This type is provided for completeness and
edge cases.

# Fields
- `distribution::Distribution`: The discrete distribution
- `point::T`: The point outside the support
"""
struct DiscreteZeroProbEvent{T} <: ZeroProbEvent
    distribution::Distribution
    point::T

    function DiscreteZeroProbEvent{T}(dist::Distribution, point::T) where T
        # Verify it's actually zero-probability
        if hasmethod(pdf, (typeof(dist), typeof(point)))
            p = pdf(dist, point)
            @assert p == 0.0 "Point $point has non-zero probability $p in discrete distribution"
        end
        new{T}(dist, point)
    end
end

DiscreteZeroProbEvent(dist::Distribution, point::T) where T =
    DiscreteZeroProbEvent{T}(dist, point)

"""
    AlmostSureEvent{T<:ZeroProbEvent}

An event that is "almost sure" - it has probability 1, but there exists a
zero-probability set where it doesn't hold.

This captures the distinction between "P(E) = 1" and "E is certain".

# Fields
- `event::ZeroProbEvent`: The zero-probability exception set
- `description::String`: What property holds almost surely

# Examples

```julia
# Hitting ANY point in a continuous distribution is almost sure
hitting_something = AlmostSureEvent(
    ContinuousZeroProbEvent(Normal(0, 1), NaN),  # No specific point
    "Sample will take some value"
)

# A random real in [0,1] is almost surely irrational
irrational = AlmostSureEvent(
    ContinuousZeroProbEvent(Uniform(0, 1), NaN),
    "Sample is irrational (rationals have measure zero)"
)
```
"""
struct AlmostSureEvent{T<:ZeroProbEvent}
    exception_set::T
    description::String
end

"""
    SureEvent

An event that holds with absolute certainty - no exceptions, not even on
zero-probability sets.

This is the stronger form of certainty, distinct from "almost sure".
"""
struct SureEvent
    description::String
end

# Display methods
function Base.show(io::IO, e::ContinuousZeroProbEvent{T}) where T
    print(io, "ContinuousZeroProbEvent{$T}(")
    print(io, "$(typeof(e.distribution)), point=$(e.point), measure=:$(e.relevance_measure))")
end

function Base.show(io::IO, e::DiscreteZeroProbEvent{T}) where T
    print(io, "DiscreteZeroProbEvent{$T}($(typeof(e.distribution)), point=$(e.point))")
end

function Base.show(io::IO, e::AlmostSureEvent)
    print(io, "AlmostSureEvent: \"$(e.description)\"")
end

function Base.show(io::IO, e::SureEvent)
    print(io, "SureEvent: \"$(e.description)\"")
end
