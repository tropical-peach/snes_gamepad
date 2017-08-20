////////////////////////////////////////////////////////////////////////////////
//
// Author:          Ryan Clarke
// 
// Create Date:     08/05/2017 
// Module Name:     snes_gamepad
//
// Description:     SNES Gamepad Controller
//
// Inputs:          clk         - 100 MHz clock input
//                  rst         - Asynchronous reset (active low)
//                  rd          - Read command
//                  snes_data   - SNES data signal
//
// Outputs:         busy        - Busy flag
//                  snes_clk    - SNES clock signal
//                  snes_latch  - SNES latch signal
//                  buttons     - 16 buttons
//
////////////////////////////////////////////////////////////////////////////////

module snes_gamepad
    (
    input wire clk,
    input wire rst,
    
    input wire rd,
    output reg busy,
    
    output wire snes_clk,
    output reg snes_latch,
    input wire snes_data,
    
    output wire [15:0] buttons
    );
    
    
// CONSTANTS ///////////////////////////////////////////////////////////////////
    
    localparam S_IDLE  = 2'b00,
               S_LATCH = 2'b01,
               S_CLOCK = 2'b10;
    
    localparam CLOCK_VALUE = 11'd599,   // 6 us @ 100 MHz clock
               LATCH_VALUE = 11'd1199;  // 12 us @ 100 MHz clock
    
    
// SIGNAL DECLARATION //////////////////////////////////////////////////////////
    
    reg [1:0] state_ff, state_ns;
    reg [10:0] counter_ff, counter_ns;
    
    reg snes_clk_ff, snes_clk_ns;
    
    reg [3:0] btn_counter_ff, btn_counter_ns;
    reg [15:0] buttons_ff, buttons_ns;
    
    
// REGISTERS ///////////////////////////////////////////////////////////////////
    
    always @(posedge clk, posedge rst)
        if(rst)
            begin
                state_ff <= S_IDLE;
                counter_ff <= 11'd0;
                
                snes_clk_ff <= 1'b1;
                
                btn_counter_ff <= 4'd0;
                buttons_ff <= {16{1'b1}};
            end
        else
            begin
                state_ff <= state_ns;
                counter_ff <= counter_ns;
                
                snes_clk_ff <= snes_clk_ns;
                
                btn_counter_ff <= btn_counter_ns;
                buttons_ff <= buttons_ns;
            end
    
    
// NEXT STATE LOGIC ////////////////////////////////////////////////////////////
    
    always @*
        begin
            state_ns = state_ff;
            counter_ns = counter_ff;
            
            busy = 1'b0;
            
            snes_latch = 1'b0;
            snes_clk_ns = snes_clk_ff;
            
            btn_counter_ns = btn_counter_ff;
            buttons_ns = buttons_ff;
            
            case(state_ff)
                S_IDLE:
                    begin                    
                        if(rd)
                            begin
                                // reset counters and button status
                                counter_ns = LATCH_VALUE;
                                btn_counter_ns = 4'd0;
                                buttons_ns = {16{1'b1}};
                                
                                state_ns = S_LATCH;
                            end
                    end
                
                S_LATCH:
                    begin
                        busy = 1'b1;
                        snes_latch = 1'b1;
                    
                        // 12 us counter
                        if(counter_ff)
                            begin
                                counter_ns = counter_ff - 11'd1;
                            end
                        else
                            begin
                                counter_ns = CLOCK_VALUE;
                                state_ns = S_CLOCK;
                            end
                    end
                
                S_CLOCK:
                    begin
                        busy = 1'b1;
                        
                        // 6 us counter
                        if(counter_ff)
                            begin
                                counter_ns = counter_ff - 11'd1;
                            end
                        else
                            begin
                                // reset counter and invert the clock output
                                counter_ns = CLOCK_VALUE;
                                snes_clk_ns = ~snes_clk_ff;
                                
                                if(snes_clk_ff)
                                    // read the SNES data signal on negative edge
                                    buttons_ns = {snes_data, buttons_ff[15:1]};
                                else
                                    // 16 button counter toggles on positive edge
                                    if(btn_counter_ff == 4'd15)
                                        state_ns = S_IDLE;
                                    else
                                        btn_counter_ns = btn_counter_ff + 5'd1;
                            end
                    end
                
                default:
                    begin
                        state_ns = S_IDLE;
                    end
            endcase
        end
    
    
// OUTPUT LOGIC ////////////////////////////////////////////////////////////////
    
    assign snes_clk = snes_clk_ff;
    assign buttons = ~buttons_ff;   // invert button status for active high
    
endmodule
