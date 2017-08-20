# SNES Gamepad Module
Verilog module to read SNES gamepad status.

This module reads the status of the buttons on a SNES gamepad. The user interacts with the module via three signals:

* rd
* busy
* buttons

The *rd* signal is used to command the module to begin the read operation. The *busy* signal is active high when the module is executing a read. Lastly, the *buttons* signal contains the status of the SNES buttons at the completion of the read.

The module interacts with the SNES controller via three signals:

* snes_latch
* snes_clk
* snes_data

The read process is initiated by holding the *snes_latch* signal high for 12 us. At the end of the *snes_latch* signal, the first button status (B) is available on *snes_data* and the *snes_clk* cycles through sixteen rising edge transitions with a 12 us clock period. The *snes_data* signal is read on the falling edge of *snes_clk*. The *snes_data* signal is active low and the module inverts the result.

```
rd    _│-│____________________________________________
busy  ___|--------------------------------------------
latch ___|----|_______________________________________
clk   -----------|__|--|__|--|__|--|__|--|__|--|__|--|
data  --------|_____|-----------|_____|---------------
              |  B  |  Y  | Sel |Start|  Up |  Dn |  L
```

Realistically, the module could operate faster than 12 us for the latch and clock period, however the original SNES gamepad protocol used 12 us. The entire operation takes 204 us.

For more information, please see the Hackaday.io [page](https://hackaday.io/project/26911-snes-gamepad-fpga-module).
