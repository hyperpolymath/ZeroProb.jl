# SPDX-License-Identifier: MPL-2.0
# (PMPL-1.0-or-later preferred; MPL-2.0 required for Julia ecosystem)
# Property-based invariant tests for ZeroProb.jl

using Test
using ZeroProb
using Distributions

@testset "Property-Based Tests" begin

    @testset "Invariant: probability at any point is always 0.0" begin
        for _ in 1:50
            x = randn()
            dist = Normal(randn(), rand() + 0.1)
            event = ContinuousZeroProbEvent(dist, x)
            @test probability(event) == 0.0
        end
    end

    @testset "Invariant: epsilon_neighborhood is monotone in ε" begin
        for _ in 1:50
            dist = Normal(randn(), rand() + 0.1)
            x = randn()
            event = ContinuousZeroProbEvent(dist, x, :epsilon)
            eps1 = rand() * 0.5
            eps2 = eps1 + rand() * 0.5
            p1 = epsilon_neighborhood(event, eps1)
            p2 = epsilon_neighborhood(event, eps2)
            @test p1 <= p2
        end
    end

    @testset "Invariant: epsilon_neighborhood is in [0, 1]" begin
        for _ in 1:50
            dist = Normal(0.0, 1.0)
            x = randn()
            ε = rand() * 3.0
            event = ContinuousZeroProbEvent(dist, x, :epsilon)
            p = epsilon_neighborhood(event, ε)
            @test 0.0 <= p <= 1.0
        end
    end

    @testset "Invariant: hausdorff_measure at dim 0 is 1 for any point" begin
        for _ in 1:50
            dist = Normal(randn(), rand() + 0.1)
            x = randn()
            event = ContinuousZeroProbEvent(dist, x, :hausdorff)
            @test hausdorff_measure(event, 0) == 1.0
        end
    end

    @testset "Invariant: density_ratio is non-negative" begin
        for _ in 1:50
            dist = Normal(0.0, rand() + 0.1)
            x = randn()
            event = ContinuousZeroProbEvent(dist, x, :density)
            @test density_ratio(event) >= 0.0
        end
    end

end
