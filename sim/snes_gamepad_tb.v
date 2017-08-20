`timescale 1 ns / 10 ps

////////////////////////////////////////////////////////////////////////////////
//
// Author:        Ryan Clarke
//
// Create Date:   08/09/2017
// Module Name:   snes_gamepad_tb
//
// Description:   Verilog Test Fixture for module snes_gamepad
//
// Dependencies:  snes_gamepad_ctrl
// 
////////////////////////////////////////////////////////////////////////////////

module snes_gamepad_tb;
    
    
// INPUTS //////////////////////////////////////////////////////////////////////
    
    reg clk;
    reg rst;
    reg rd;
    reg snes_data;
    
    
// OUTPUTS /////////////////////////////////////////////////////////////////////

    wire busy;
    wire snes_latch;
    wire snes_clk;
    wire [15:0] buttons;
	
	
// CONSTANTS ///////////////////////////////////////////////////////////////////
    
    localparam T_clk = 10;  // clock period (ns)
    
    
// SIGNAL DECLARATION //////////////////////////////////////////////////////////
    
    reg gamepad [0:15];
    integer i;
    
    
// MODULES /////////////////////////////////////////////////////////////////////
    
    snes_gamepad uut
        (
        .clk(clk),
        .rst(rst),
        .rd(rd),
        .busy(busy),
        .snes_latch(snes_latch),
        .snes_clk(snes_clk),
        .snes_data(snes_data),
        .buttons(buttons)
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
            
            // read command
            @(posedge clk) rd = 1;
            @(posedge clk) rd = 0;
            
            @(negedge busy) $stop;  // wait until busy signal clear and stop
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
            rst = 0;
            rd = 0;
            snes_data = 1;
            
            reset_async();
        end
    endtask
    
    // asynchronous reset
    task reset_async;
        begin
            rst = 1;
            #(T_clk / 2) rst = 0;
        end
    endtask
    
endmodule
