`timescale 1ns / 1ps

module operand_controller_tb;

    reg        clk;
    reg        reset;
    reg        enter_pulse;
    reg  [3:0] switch_value;

    wire [3:0] operand_a;
    wire [3:0] operand_b;
    wire       show_result;

    integer error_count;


    operand_controller dut (
        .clk          (clk),
        .reset        (reset),
        .enter_pulse  (enter_pulse),
        .switch_value (switch_value),
        .operand_a    (operand_a),
        .operand_b    (operand_b),
        .show_result  (show_result)
    );


    // 100 MHz clock: 10 ns period
    initial begin
        clk = 1'b0;

        forever begin
            #5 clk = ~clk;
        end
    end


    // Generate a pulse lasting exactly one clock cycle
    task press_enter;
        begin
            @(negedge clk);
            enter_pulse = 1'b1;

            @(negedge clk);
            enter_pulse = 1'b0;

            #1;
        end
    endtask


    // Check the controller outputs
    task check_outputs;
        input [3:0] expected_a;
        input [3:0] expected_b;
        input       expected_show_result;
        input [255:0] test_name;

        begin
            if ((operand_a !== expected_a) ||
                (operand_b !== expected_b) ||
                (show_result !== expected_show_result)) begin

                $display(
                    "ERROR: %0s | A=%0d expected=%0d | B=%0d expected=%0d | show_result=%b expected=%b",
                    test_name,
                    operand_a,
                    expected_a,
                    operand_b,
                    expected_b,
                    show_result,
                    expected_show_result
                );

                error_count = error_count + 1;
            end
            else begin
                $display("PASS: %0s", test_name);
            end
        end
    endtask


    initial begin
        reset        = 1'b1;
        enter_pulse  = 1'b0;
        switch_value = 4'd0;
        error_count  = 0;

        // Apply reset
        repeat (2) @(negedge clk);
        reset = 1'b0;
        #1;

        check_outputs(
            4'd0,
            4'd0,
            1'b0,
            "Reset state"
        );


        // Enter A = 5
        switch_value = 4'd5;
        press_enter();

        check_outputs(
            4'd5,
            4'd0,
            1'b0,
            "Capture first operand A=5"
        );


        // Enter B = 9
        switch_value = 4'd9;
        press_enter();

        check_outputs(
            4'd5,
            4'd9,
            1'b1,
            "Capture second operand B=9"
        );


        // Start another calculation with A = 3
        switch_value = 4'd3;
        press_enter();

        check_outputs(
            4'd3,
            4'd9,
            1'b0,
            "Start new calculation with A=3"
        );


        // Enter the new B = 4
        switch_value = 4'd4;
        press_enter();

        check_outputs(
            4'd3,
            4'd4,
            1'b1,
            "Capture new operand B=4"
        );


        // Reset again
        @(negedge clk);
        reset = 1'b1;

        @(negedge clk);
        reset = 1'b0;

        #1;

        check_outputs(
            4'd0,
            4'd0,
            1'b0,
            "Final reset"
        );


        if (error_count == 0) begin
            $display("================================");
            $display("ALL CONTROLLER TESTS PASSED");
            $display("================================");
        end
        else begin
            $display("================================");
            $display(
                "CONTROLLER TEST FAILED: %0d errors",
                error_count
            );
            $display("================================");
        end

        $finish;
    end

endmodule