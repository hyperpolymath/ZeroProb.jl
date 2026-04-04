# SPDX-License-Identifier: MPL-2.0
# (PMPL-1.0-or-later preferred; MPL-2.0 required for Julia ecosystem)
# Copyright (c) 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>

using Test
using ZeroProb
using Distributions
using LinearAlgebra

@testset "ZeroProb.jl Tests" begin
    # Original test suites
    include("test_types.jl")
    include("test_measures.jl")
    include("test_paradoxes.jl")
    include("test_applications.jl")

    # Extended test suites (Phase 2, 3, 4, 5, 7)
    include("test_new_types.jl")
    include("test_new_measures.jl")
    include("test_new_paradoxes.jl")

    # Coverage gap tests (display methods, relevance_score, extended type handlers)
    include("test_coverage_gaps.jl")

    # CRG Grade C tests
    include("e2e_test.jl")
    include("property_test.jl")

end
