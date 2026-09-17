`timescale 1ns / 1ps

module button_conditioner (
    input  wire clk,
    input  wire reset,
    input  wire button_in,

    output wire press_pulse
);

    // Two-stage synchronizer
    reg button_meta = 1'b0;
    reg button_sync = 1'b0;

    // Debounced button state
    reg button_stable = 1'b0;
    reg button_previous = 1'b0;

    // 1,000,000 cycles at 100 MHz = 10 ms
    reg [19:0] debounce_counter = 20'd0;


    always @(posedge clk) begin
        if (reset) begin
            button_meta     <= 1'b0;
            button_sync     <= 1'b0;
            button_stable   <= 1'b0;
            button_previous <= 1'b0;
            debounce_counter <= 20'd0;
        end
        else begin
            // Synchronize the physical button
            button_meta <= button_in;
            button_sync <= button_meta;

            // Check whether the synchronized button changed
            if (button_sync == button_stable) begin
                debounce_counter <= 20'd0;
            end
            else begin
                if (debounce_counter == 20'd999_999) begin
                    button_stable    <= button_sync;
                    debounce_counter <= 20'd0;
                end
                else begin
                    debounce_counter <= debounce_counter + 1'b1;
                end
            end

            // Remember the previous debounced value
            button_previous <= button_stable;
        end
    end


    // High for one clock cycle when a new press is accepted
    assign press_pulse = button_stable & ~button_previous;

endmodule
