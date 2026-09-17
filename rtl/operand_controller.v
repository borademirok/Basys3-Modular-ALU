`timescale 1ns / 1ps

module operand_controller (
    input  wire       clk,
    input  wire       reset,
    input  wire       enter_pulse,
    input  wire [3:0] switch_value,

    output reg  [3:0] operand_a,
    output reg  [3:0] operand_b,
    output wire       show_result
);

    localparam ENTER_A     = 2'd0;
    localparam ENTER_B     = 2'd1;
    localparam SHOW_RESULT = 2'd2;

    reg [1:0] state = ENTER_A;


    // Tell the top module when the result should be displayed
    assign show_result = (state == SHOW_RESULT);


    always @(posedge clk) begin
        if (reset) begin
            state     <= ENTER_A;
            operand_a <= 4'd0;
            operand_b <= 4'd0;
        end
        else if (enter_pulse) begin
            case (state)
                ENTER_A: begin
                    // First press: store operand A
                    operand_a <= switch_value;
                    state     <= ENTER_B;
                end

                ENTER_B: begin
                    // Second press: store operand B
                    operand_b <= switch_value;
                    state     <= SHOW_RESULT;
                end

                SHOW_RESULT: begin
                    // Next press starts a new calculation
                    // and immediately stores the new operand A
                    operand_a <= switch_value;
                    state     <= ENTER_B;
                end

                default: begin
                    state     <= ENTER_A;
                    operand_a <= 4'd0;
                    operand_b <= 4'd0;
                end
            endcase
        end
    end

endmodule