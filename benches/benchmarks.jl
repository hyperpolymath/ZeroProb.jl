# SPDX-License-Identifier: MPL-2.0
# (PMPL-1.0-or-later preferred; MPL-2.0 required for Julia ecosystem)
# BenchmarkTools benchmarks for ZeroProb.jl

using BenchmarkTools
using ZeroProb
using Distributions

const SUITE = BenchmarkGroup()

SUITE["construction"] = BenchmarkGroup()

SUITE["construction"]["continuous_event_density"] = let
    dist = Normal(0.0, 1.0)
    @benchmarkable ContinuousZeroProbEvent($dist, 0.0, :density)
end

SUITE["construction"]["continuous_event_epsilon"] = let
    dist = Normal(0.0, 1.0)
    @benchmarkable ContinuousZeroProbEvent($dist, 0.0, :epsilon)
end

SUITE["construction"]["almost_sure_event"] = let
    dist = Normal(0.0, 1.0)
    exc = ContinuousZeroProbEvent(dist, 0.0, :density)
    @benchmarkable AlmostSureEvent($exc, "X ≠ 0")
end

SUITE["measures"] = BenchmarkGroup()

SUITE["measures"]["probability"] = let
    dist = Normal(0.0, 1.0)
    event = ContinuousZeroProbEvent(dist, 0.0)
    @benchmarkable probability($event)
end

SUITE["measures"]["density_ratio"] = let
    dist = Normal(0.0, 1.0)
    event = ContinuousZeroProbEvent(dist, 0.0, :density)
    @benchmarkable density_ratio($event)
end

SUITE["measures"]["epsilon_neighborhood_small"] = let
    dist = Normal(0.0, 1.0)
    event = ContinuousZeroProbEvent(dist, 0.0, :epsilon)
    @benchmarkable epsilon_neighborhood($event, 0.1)
end

SUITE["measures"]["epsilon_neighborhood_large"] = let
    dist = Normal(0.0, 1.0)
    event = ContinuousZeroProbEvent(dist, 0.0, :epsilon)
    @benchmarkable epsilon_neighborhood($event, 2.0)
end

SUITE["measures"]["hausdorff_measure_dim0"] = let
    dist = Normal(0.0, 1.0)
    event = ContinuousZeroProbEvent(dist, 0.0, :hausdorff)
    @benchmarkable hausdorff_measure($event, 0)
end

if abspath(PROGRAM_FILE) == @__FILE__
    tune!(SUITE)
    results = run(SUITE, verbose=true)
    BenchmarkTools.save("benchmarks_results.json", results)
end
