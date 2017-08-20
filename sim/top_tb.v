`timescale 1 ns / 10 ps

////////////////////////////////////////////////////////////////////////////////
//
// Author:        Ryan Clarke
//
// Create Date:   08/12/2017
// Module Name:   top_tb
//
// Description:   Verilog Test Fixture for module top
//
// Dependencies:  top
// 
////////////////////////////////////////////////////////////////////////////////

module top_tb;
    
    
// INPUTS //////////////////////////////////////////////////////////////////////
    
    reg clk;
    reg rst_n;
    reg snes_data;
    
    
// OUTPUTS /////////////////////////////////////////////////////////////////////

    wire snes_latch;
    wire snes_clk;
    wire [15:0] led;
	
	
// CONSTANTS ///////////////////////////////////////////////////////////////////
    
    localparam T_clk = 10;  // clock period (ns)
    
    
// SIGNAL DECLARATION //////////////////////////////////////////////////////////
    
    reg gamepad [0:15];
    integer i;
    
    
// MODULES /////////////////////////////////////////////////////////////////////
        
    top uut
        (
        .clk(clk),
        .rst_n(rst_n),
        .snes_latch(snes_latch),
        .snes_clk(snes_clk),
        .snes_data(snes_data),
        .led(led)
        );
    
    
// CLOCK ///////////////////////////////////////////////////////////////////////
    
    // 100 MHz clock
    always
        begin
            clk = 1;
            #(T_clk / 2);
            
            clk = 0;
            #(T_clk / 2);
        end
    
    
// MAIN ////////////////////////////////////////////////////////////////////////
            
    initial
        begin
            initialize();
            
            #(1700000 * T_clk) $stop;   // 17 ms delay and then stop
        end
    
    
// GAMEPAD SIMULATION //////////////////////////////////////////////////////////
        
    // button data
    initial
        begin
            gamepad[0] = 0;
            gamepad[1] = 1;
            gamepad[2] = 1;
            gamepad[3] = 1;
            gamepad[4] = 1;
            gamepad[5] = 1;
            gamepad[6] = 1;
            gamepad[7] = 1;
            gamepad[8] = 0;
            gamepad[9] = 1;
            gamepad[10] = 1;
            gamepad[11] = 1;
            gamepad[12] = 1;
            gamepad[13] = 1;
            gamepad[14] = 1;
            gamepad[15] = 0;
        end
    
    // SNES gamepad shift register simulation
    always
        begin
            wait(snes_latch);   // wait for the latch signal
            
            // first button (B) on the SNES data signal after latch complete
            @(negedge snes_latch) snes_data = gamepad[0];
            
            // shift the SNES buttons on each SNES clock posedge
            for(i = 1; i < 16; i = i + 1)
                @(posedge snes_clk) snes_data = gamepad[i];
            
            // always end with SNES data high
            @(posedge snes_clk) snes_data = 1;
        end
    
    
// TASKS ///////////////////////////////////////////////////////////////////////
            
    // initialize
    task initialize;
        begin
            rst_n = 1;
            snes_data = 1;
            
            reset_async();
        end
    endtask
    
    // asynchronous reset
    task reset_async;
        begin
            rst_n = 0;
            #(T_clk / 2) rst_n = 1;
        end
    endtask
    
endmodule
