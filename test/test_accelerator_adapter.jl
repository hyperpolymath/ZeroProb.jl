# SPDX-License-Identifier: MPL-2.0

@testset "AcceleratorGate simulator adapter" begin
    gate_root = get(ENV, "ACCELERATOR_GATE_ROOT", "")
    if isempty(gate_root)
        @test true # Optional local integration; base package remains standalone.
    else
        pushfirst!(LOAD_PATH, gate_root)
        try
            @eval using AcceleratorGate
            include(joinpath(@__DIR__, "..", "ext", "ZeroProbTPUExt.jl"))
            AcceleratorGate.clear_provider_registry!()

            request = AcceleratorGate.OperationRequest(
                "enaction.tensor.f32.matmul";
                layout=(m=2, k=3, n=2),
                allow_simulation=true,
            )
            ZeroProbTPUExt.register_zero_prob_tpu_simulator!()
            output, evidence = AcceleratorGate.execute_operation(
                request,
                Float32[1 2 3; 4 5 6],
                Float32[7 8; 9 10; 11 12],
            )
            @test output == Float32[58 64; 139 154]
            @test evidence.implementation == :simulation
            @test evidence.provider_id == ZeroProbTPUExt.PROVIDER_ID

            refused = AcceleratorGate.OperationRequest(
                "enaction.tensor.f32.matmul";
                layout=(m=2, k=3, n=2),
                allow_simulation=false,
            )
            @test_throws ErrorException AcceleratorGate.plan_operation(refused)
            AcceleratorGate.clear_provider_registry!()
        finally
            popfirst!(LOAD_PATH)
        end
    end
end
