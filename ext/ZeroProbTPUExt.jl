# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Historical filename retained for migration compatibility. This is explicitly
# a software simulator adapter, not evidence of a physical TPU backend.

module ZeroProbTPUExt

using AcceleratorGate

export zero_prob_tpu_simulator, register_zero_prob_tpu_simulator!

const PROVIDER_ID = "zeroprob.simulator.tpu-style-matmul"
const OPERATION_ID = "enaction.tensor.f32.matmul"

"""
    _tpu_style_matmul(request, left, right)

Reference simulation of 128×128 tiled/systolic dataflow in ordinary Julia on
the host CPU. It exists for algorithm experiments and conformance comparisons.
It does not probe, submit to, or execute on TPU hardware.
"""
function _tpu_style_matmul(
    request::OperationRequest,
    left::AbstractMatrix{Float32},
    right::AbstractMatrix{Float32},
)
    request.operation == OPERATION_ID || throw(ArgumentError("unsupported operation"))
    request.allow_simulation || throw(ArgumentError("simulation was not explicitly admitted"))
    m, k = size(left)
    k2, n = size(right)
    k == k2 || throw(DimensionMismatch("matrix inner dimensions must match"))
    request.layout == (m=m, k=k, n=n) || throw(DimensionMismatch("request layout does not match matrices"))
    all(isfinite, left) && all(isfinite, right) || throw(ArgumentError("inputs must be finite"))

    output = zeros(Float32, m, n)
    tile_size = 128
    for row_start in 1:tile_size:m
        row_end = min(row_start + tile_size - 1, m)
        for column_start in 1:tile_size:n
            column_end = min(column_start + tile_size - 1, n)
            for inner_start in 1:tile_size:k
                inner_end = min(inner_start + tile_size - 1, k)
                @views output[row_start:row_end, column_start:column_end] .+=
                    left[row_start:row_end, inner_start:inner_end] *
                    right[inner_start:inner_end, column_start:column_end]
            end
        end
    end
    all(isfinite, output) || throw(OverflowError("simulation produced a non-finite result"))
    output
end

"""
    zero_prob_tpu_simulator() -> FunctionProvider

Construct the opt-in simulation provider. The claim is limited to advisory,
tolerance-bounded `f32` matmul at conformant support. It deliberately claims no
probability evaluation, Bayesian update, sampling, marginalisation, or physical
TPU availability.
"""
function zero_prob_tpu_simulator()
    claim = CapabilityEvidence(
        PROVIDER_ID,
        v"1.0.0",
        OPERATION_ID,
        v"1.0.0";
        lanes=(:advisory,),
        support=:conformant,
        determinism=:tolerance_bounded,
        implementation=:simulation,
        device_class=:cpu,
    )
    FunctionProvider(PROVIDER_ID, v"1.0.0", [claim], _tpu_style_matmul)
end

"""Register the simulator explicitly; module loading alone makes no claim."""
register_zero_prob_tpu_simulator!() = register_provider!(zero_prob_tpu_simulator())

end # module ZeroProbTPUExt
