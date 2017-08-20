////////////////////////////////////////////////////////////////////////////////
//
// Author:          Ryan Clarke
// 
// Create Date:     08/12/2017 
// Module Name:     top
//
// Description:     SNES Gamepad Controller Test for the Nexys 4 DDR
//
// Inputs:          clk         - 100 MHz clock input
//                  rst_n       - Asynchronous reset (active low)
//                  snes_data   - SNES data signal
//
// Outputs:         snes_clk    - SNES clock signal
//                  snes_latch  - SNES latch signal
//                  led         - 16 LEDs
//
////////////////////////////////////////////////////////////////////////////////

module top
    (
    input clk,
    input rst_n,
    
    output snes_clk,    // Pmod JA[4]
    output snes_latch,  // Pmod JA[3]
    input snes_data,    // Pmod JA[2]
    
    output [15:0] led
    );
    
    
// CONSTANTS ///////////////////////////////////////////////////////////////////
    
    localparam RD_COUNTER_MAX = 21'd1666666;    // ~47 Hz @ 100 MHz clock
    
    
// SIGNAL DECLARATION //////////////////////////////////////////////////////////
    
    wire rst;
    
    wire rd, busy;
    wire [15:0] buttons;
    
    reg [20:0] rd_counter_ff;
    wire [20:0] rd_counter_ns;
    
    reg busy_ff;
    wire negedge_busy;
    
    reg [15:0] led_ff;
    wire [15:0] led_ns;
    
    
// SIGNALS /////////////////////////////////////////////////////////////////////
    
    assign rst = ~rst_n;
    
    // negative edge detector for the snes_gamepad_ctrl busy signal
    assign negedge_busy = busy_ff & ~busy;
    
    
// MODULES /////////////////////////////////////////////////////////////////////
    
    snes_gamepad gamepad
        (
        .clk(clk),
        .rst(rst),
        .rd(rd),
        .busy(busy),
        .snes_clk(snes_clk),
        .snes_latch(snes_latch),
        .snes_data(snes_data),
        .buttons(buttons)
        );
    
    
// REGISTERS ///////////////////////////////////////////////////////////////////
    
    always @(posedge clk, posedge rst)
        if(rst)
            begin
                rd_counter_ff <= RD_COUNTER_MAX;
                busy_ff <= 1'b0;
                led_ff <= 16'd0;
            end
        else
            begin
                rd_counter_ff <= rd_counter_ns;
                busy_ff <= busy;
                led_ff <= led_ns;
            end
    
    
// NEXT STATE LOGIC ////////////////////////////////////////////////////////////
    
    // Read command triggers when the read counter is zero
    assign rd = (rd_counter_ff) ? 1'b0 : 1'b1;
    
    // Read command interval counter (~47 Hz)
    assign rd_counter_ns = (rd_counter_ff) ? rd_counter_ff - 21'd1
                                           : RD_COUNTER_MAX;
    
    // clock the buttons into the LEDs on the negative edge of the busy signal
    assign led_ns = (negedge_busy) ? buttons : led_ff;
    
    
// OUTPUT LOGIC ////////////////////////////////////////////////////////////////
    
    assign led = led_ff;
    
endmodule
