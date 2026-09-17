`timescale 1ns / 1ps

module seven_segment_display (
    input  wire       clk,
    input  wire       reset,
    input  wire [7:0] value,
    input  wire       negative,
    input  wire       error,

    output reg  [6:0] seg,
    output reg  [3:0] an,
    output wire       dp
);

    // Counter used to scan across the four digits
    reg [17:0] refresh_counter = 18'd0;

    // Decimal digits
    reg [3:0] hundreds;
    reg [3:0] tens;
    reg [3:0] ones;

    // Values assigned to the four physical digits
    reg [3:0] digit_3;
    reg [3:0] digit_2;
    reg [3:0] digit_1;
    reg [3:0] digit_0;

    reg [3:0] digit_to_display;


    // Display scanning counter
    always @(posedge clk) begin
        if (reset)
            refresh_counter <= 18'd0;
        else
            refresh_counter <= refresh_counter + 1'b1;
    end


    // Convert the binary value into decimal digits
    always @(*) begin
        hundreds = value / 8'd100;
        tens     = (value % 8'd100) / 8'd10;
        ones     = value % 8'd10;

        // Blank unnecessary leading zeroes
        if (value < 8'd100)
            hundreds = 4'd10;

        if (value < 8'd10)
            tens = 4'd10;
    end


    // Decide what each physical digit should contain
    always @(*) begin
        // Normal numeric display
        digit_0 = ones;
        digit_1 = tens;
        digit_2 = hundreds;

        if (negative)
            digit_3 = 4'd11; // Minus sign
        else
            digit_3 = 4'd10; // Blank

        // Division-by-zero error overrides the normal result
        if (error) begin
            digit_3 = 4'd10; // Blank
            digit_2 = 4'd12; // E
            digit_1 = 4'd13; // r
            digit_0 = 4'd13; // r
        end
    end


    // Select one of the four physical digits
    always @(*) begin
        case (refresh_counter[17:16])
            2'b00: begin
                an = 4'b1110;
                digit_to_display = digit_0;
            end

            2'b01: begin
                an = 4'b1101;
                digit_to_display = digit_1;
            end

            2'b10: begin
                an = 4'b1011;
                digit_to_display = digit_2;
            end

            2'b11: begin
                an = 4'b0111;
                digit_to_display = digit_3;
            end

            default: begin
                an = 4'b1111;
                digit_to_display = 4'd10;
            end
        endcase
    end


    // Convert the selected character into segment controls
    always @(*) begin
        case (digit_to_display)
            4'd0:  seg = 7'b1000000;
            4'd1:  seg = 7'b1111001;
            4'd2:  seg = 7'b0100100;
            4'd3:  seg = 7'b0110000;
            4'd4:  seg = 7'b0011001;
            4'd5:  seg = 7'b0010010;
            4'd6:  seg = 7'b0000010;
            4'd7:  seg = 7'b1111000;
            4'd8:  seg = 7'b0000000;
            4'd9:  seg = 7'b0010000;

            4'd10: seg = 7'b1111111; // Blank
            4'd11: seg = 7'b0111111; // Minus sign
            4'd12: seg = 7'b0000110; // E
            4'd13: seg = 7'b0101111; // r

            default: seg = 7'b1111111;
        endcase
    end


    // Decimal point permanently off
    assign dp = 1'b1;

endmodule