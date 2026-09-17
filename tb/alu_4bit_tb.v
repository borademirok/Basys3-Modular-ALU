`timescale 1ns / 1ps

module alu_4bit_tb;

    reg  [3:0] operand_a;
    reg  [3:0] operand_b;
    reg  [2:0] opcode;

    wire [7:0] result;
    wire       negative;
    wire       divide_by_zero;

    integer a_index;
    integer b_index;
    integer opcode_index;
    integer error_count;


    // Device under test
    alu_4bit dut (
        .operand_a      (operand_a),
        .operand_b      (operand_b),
        .opcode         (opcode),
        .result         (result),
        .negative       (negative),
        .divide_by_zero (divide_by_zero)
    );


    task check_operation;
        input [3:0] test_a;
        input [3:0] test_b;
        input [2:0] test_opcode;

        reg [7:0] expected_result;
        reg       expected_negative;
        reg       expected_divide_by_zero;

        begin
            operand_a = test_a;
            operand_b = test_b;
            opcode    = test_opcode;

            expected_result         = 8'd0;
            expected_negative       = 1'b0;
            expected_divide_by_zero = 1'b0;

            case (test_opcode)
                3'b000: begin
                    expected_result =
                        {4'd0, test_a} + {4'd0, test_b};
                end

                3'b001: begin
                    if (test_a >= test_b) begin
                        expected_result =
                            {4'd0, test_a} - {4'd0, test_b};

                        expected_negative = 1'b0;
                    end
                    else begin
                        expected_result =
                            {4'd0, test_b} - {4'd0, test_a};

                        expected_negative = 1'b1;
                    end
                end

                3'b010: begin
                    expected_result =
                        {4'd0, test_a} * {4'd0, test_b};
                end

                3'b011: begin
                    if (test_b == 4'd0) begin
                        expected_result         = 8'd0;
                        expected_divide_by_zero = 1'b1;
                    end
                    else begin
                        expected_result =
                            {4'd0, test_a} / {4'd0, test_b};
                    end
                end

                // Currently unsupported opcodes
                default: begin
                    expected_result         = 8'd0;
                    expected_negative       = 1'b0;
                    expected_divide_by_zero = 1'b0;
                end
            endcase

            // Allow combinational logic to settle
            #1;

            if ((result !== expected_result) ||
                (negative !== expected_negative) ||
                (divide_by_zero !== expected_divide_by_zero)) begin

                $display(
                    "ERROR: opcode=%b A=%0d B=%0d | result=%0d expected=%0d | negative=%b expected_negative=%b | div0=%b expected_div0=%b",
                    test_opcode,
                    test_a,
                    test_b,
                    result,
                    expected_result,
                    negative,
                    expected_negative,
                    divide_by_zero,
                    expected_divide_by_zero
                );

                error_count = error_count + 1;
            end
        end
    endtask


    initial begin
        operand_a  = 4'd0;
        operand_b  = 4'd0;
        opcode     = 3'd0;
        error_count = 0;

        // Test every opcode and every operand combination
        for (opcode_index = 0;
             opcode_index < 8;
             opcode_index = opcode_index + 1) begin

            for (a_index = 0;
                 a_index < 16;
                 a_index = a_index + 1) begin

                for (b_index = 0;
                     b_index < 16;
                     b_index = b_index + 1) begin

                    check_operation(
                        a_index,
                        b_index,
                        opcode_index
                    );
                end
            end
        end

        if (error_count == 0) begin
            $display("================================");
            $display("ALL 2048 ALU TESTS PASSED");
            $display("================================");
        end
        else begin
            $display("================================");
            $display("ALU TEST FAILED: %0d errors", error_count);
            $display("================================");
        end

        $finish;
    end

endmodule