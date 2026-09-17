`timescale 1ns / 1ps

module alu_4bit (
    input  wire [3:0] operand_a,
    input  wire [3:0] operand_b,
    input  wire [2:0] opcode,

    output reg  [7:0] result,
    output reg        negative,
    output reg        divide_by_zero
);

    always @(*) begin
        // Default values
        result         = 8'd0;
        negative       = 1'b0;
        divide_by_zero = 1'b0;

        case (opcode)
            3'b000: begin
                // Addition
                result = {4'd0, operand_a}
                       + {4'd0, operand_b};
            end

            3'b001: begin
                // Subtraction
                if (operand_a >= operand_b) begin
                    result = {4'd0, operand_a}
                           - {4'd0, operand_b};

                    negative = 1'b0;
                end
                else begin
                    result = {4'd0, operand_b}
                           - {4'd0, operand_a};

                    negative = 1'b1;
                end
            end

            3'b010: begin
                // Multiplication
                result = {4'd0, operand_a}
                       * {4'd0, operand_b};
            end

            3'b011: begin
                // Integer division
                if (operand_b == 4'd0) begin
                    result         = 8'd0;
                    divide_by_zero = 1'b1;
                end
                else begin
                    result = {4'd0, operand_a}
                           / {4'd0, operand_b};
                end
            end

            default: begin
                result         = 8'd0;
                negative       = 1'b0;
                divide_by_zero = 1'b0;
            end
        endcase
    end

endmodule