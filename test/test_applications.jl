# SPDX-License-Identifier: PMPL-1.0-or-later

@testset "Applications" begin
    @testset "BlackSwanEvent" begin
        returns = Normal(0.001, 0.02)
        crash = BlackSwanEvent(
            returns,
            -0.5,
            x -> x < -0.5 ? 1_000_000 : 0
        )

        @test crash.threshold == -0.5
        @test impact_severity(crash, -0.6) == 1_000_000
        @test impact_severity(crash, 0.0) == 0

        # Probability should be tiny but non-zero
        p = probability(crash)
        @test p > 0.0
        @test p < 0.001
    end

    @testset "MarketCrashEvent" begin
        crash = MarketCrashEvent(loss_threshold = 1_000_000, severity = :catastrophic)

        @test crash.threshold == -0.5
        @test impact_severity(crash, -0.6) == 1_000_000
    end

    @testset "expected_impact" begin
        crash = MarketCrashEvent(loss_threshold = 100_000, severity = :high)
        exp_impact = expected_impact(crash, 1000)

        # Should be non-negative
        @test exp_impact >= 0.0
    end

    @testset "BettingEdgeCase" begin
        game = Normal(100, 10)
        bet = BettingEdgeCase(game, 100.0, 1000.0, 1.0)

        @test probability(bet) == 0.0

        # Expected value should be computable
        ev_epsilon = expected_value(bet, method=:epsilon, ε=0.1)
        ev_density = expected_value(bet, method=:density, ε=0.1)

        @test typeof(ev_epsilon) == Float64
        @test typeof(ev_density) == Float64
    end

    @testset "handles_black_swan" begin
        crash = MarketCrashEvent()
        model = nothing  # Dummy model

        # Stub implementation always returns true
        @test handles_black_swan(model, crash) == true
    end

    @testset "handles_zero_prob_events" begin
        events = [
            ContinuousZeroProbEvent(Normal(0, 1), 0.0),
            ContinuousZeroProbEvent(Normal(0, 1), 1.0)
        ]
        model = nothing  # Dummy model

        @test handles_zero_prob_events(model, events) == true
    end
end
