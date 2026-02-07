# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell <jonathan.jewell@open.ac.uk>

using Test
using ZeroProb
using Distributions

@testset "ZeroProb.jl Tests" begin
    include("test_types.jl")
    include("test_measures.jl")
    include("test_paradoxes.jl")
    include("test_applications.jl")
end
