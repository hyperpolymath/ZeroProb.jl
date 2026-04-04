# SPDX-License-Identifier: MPL-2.0
# (PMPL-1.0-or-later preferred; MPL-2.0 required for Julia ecosystem)
# E2E pipeline tests for ZeroProb.jl

using Test
using ZeroProb
using Distributions
using LinearAlgebra

@testset "E2E Pipeline Tests" begin

    @testset "Full zero-probability analysis pipeline" begin
        # Create a distribution, construct events, compute measures
        dist = Normal(0.0, 1.0)
        center  = ContinuousZeroProbEvent(dist, 0.0, :density)
        tail3   = ContinuousZeroProbEvent(dist, 3.0, :density)

        # Probability at a point is always zero
        @test probability(center) == 0.0
        @test probability(tail3) == 0.0

        # Density ratio: center should exceed tail
        @test density_ratio(center) > density_ratio(tail3)

        # Epsilon neighbourhood
        p_small = epsilon_neighborhood(center, 0.1)
        p_large = epsilon_neighborhood(center, 0.5)
        @test 0.0 < p_small < p_large < 1.0

        # Hausdorff measure at dimension 0 is 1 (a point)
        @test hausdorff_measure(center, 0) == 1.0
        @test hausdorff_measure(center, 1) == 0.0
    end

    @testset "AlmostSureEvent → relevance_score pipeline" begin
        dist = Normal(0.0, 1.0)
        exc  = ContinuousZeroProbEvent(dist, 0.0, :density)
        ase  = AlmostSureEvent(exc, "X ≠ 0 almost surely")

        @test ase.description == "X ≠ 0 almost surely"
        @test ase.exception_set isa ZeroProbEvent
    end

    @testset "SureEvent construction pipeline" begin
        ev = SureEvent("X ∈ ℝ")
        @test ev.description == "X ∈ ℝ"
    end

    @testset "Error handling: invalid relevance_measure raises AssertionError" begin
        dist = Normal(0.0, 1.0)
        @test_throws AssertionError ContinuousZeroProbEvent(dist, 0.0, :nonexistent_measure)
    end

end
