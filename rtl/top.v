`timescale 1ns / 1ps

module top (
    input  wire        clk,
    input  wire        btnC,
    input  wire        btnU,
    input  wire [15:0] sw,

    output wire [6:0]  seg,
    output wire [3:0]  an,
    output wire        dp
);

    // Clean one-clock pulse generated from btnC
    wire enter_pulse;

    // Stored operands
    wire [3:0] operand_a;
    wire [3:0] operand_b;

    // ALU operation selection
    wire [2:0] opcode;

    // ALU outputs
    wire [7:0] alu_result;
    wire       alu_negative;
    wire       divide_by_zero;

    // Controller status
    wire show_result;

    // Values sent to the display module
    wire [7:0] display_value;
    wire       display_negative;
    wire       display_error;


    // SW6–SW4 select the ALU operation
    assign opcode = sw[6:4];


    // While entering operands, display the live switch value.
    // After both operands are submitted, display the ALU result.
    assign display_value =
        show_result ? alu_result : {4'd0, sw[3:0]};

    // Show the sign/error only while displaying the result
    assign display_negative =
        show_result && alu_negative;

    assign display_error =
        show_result && divide_by_zero;


    // Physical button processing
    button_conditioner enter_button (
        .clk         (clk),
        .reset       (btnU),
        .button_in   (btnC),
        .press_pulse (enter_pulse)
    );


    // Operand capture and state control
    operand_controller controller (
        .clk          (clk),
        .reset        (btnU),
        .enter_pulse  (enter_pulse),
        .switch_value (sw[3:0]),
        .operand_a    (operand_a),
        .operand_b    (operand_b),
        .show_result  (show_result)
    );


    // Arithmetic and logic unit
    alu_4bit alu (
        .operand_a      (operand_a),
        .operand_b      (operand_b),
        .opcode         (opcode),
        .result         (alu_result),
        .negative       (alu_negative),
        .divide_by_zero (divide_by_zero)
    );


    // Decimal seven-segment display controller
    seven_segment_display display (
        .clk      (clk),
        .reset    (btnU),
        .value    (display_value),
        .negative (display_negative),
        .error    (display_error),
        .seg      (seg),
        .an       (an),
        .dp       (dp)
    );

endmodule