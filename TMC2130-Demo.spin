{
    --------------------------------------------
    Filename:
    Author:
    Copyright (c) 20__
    See end of file for terms of use.
    --------------------------------------------
}

CON

    _clkmode = cfg#_clkmode
    _xinfreq = cfg#_xinfreq
    #16, SDI_PIN, SCK_PIN, CS_PIN, SDO_PIN

OBJ

    cfg     : "core.con.client.flip"
    ser     : "com.serial.terminal"
    time    : "time"
    tmc     : "motor.stepper.tmc2130"

VAR

    byte _ser_cog

PUB Main

    Setup
        ser.Position (0, 3)
        ser.Str (string("Chip version: "))
        ser.Hex (tmc.ChipVersion, 2)

        ser.Position (0, 4)
        ser.Str (string("Status: "))
        ser.Bin (tmc.Status, 3)

        ser.Position (0, 5)
        ser.Str (string("SPI Mode: "))
        ser.Hex (tmc.SPIMode, 8)

    repeat
        GCONF
'        ChopperCfg

PUB GCONF

    tmc.Diag0Stall (TRUE)
    tmc.Diag1Stall (TRUE)
    tmc.InvertShaftDir (FALSE)
    ser.Position (0, 7)
    ser.Str (string("GCONF: "))
    ser.Bin (tmc.GCONF, 32)
    time.Sleep (1)

    tmc.Diag0Stall (FALSE)
    tmc.Diag1Stall (FALSE)
    tmc.InvertShaftDir (TRUE)
    ser.Position (0, 7)
    ser.Str (string("GCONF: "))
    ser.Bin (tmc.GCONF, 32)
    time.Sleep (1)

PUB ChopperCfg

    tmc.ShortProtect (TRUE)

    tmc.Interpolate (TRUE)
    ser.Position (0, 8)
    ser.Str (string("Chopper/driver cfg: "))
    ser.bin (tmc.ChopConf, 32)

    time.Sleep (1)

    tmc.Interpolate (FALSE)
    ser.Position (0, 8)
    ser.Str (string("Chopper/driver cfg: "))
    ser.bin (tmc.ChopConf, 32)

    time.Sleep (1)

{
 X.begin(); // Init
 X.rms_current(500); // Current in mA
DONE X.microsteps(16); // Behave like the original Pololu A4988 driver
DONE X.interpolate(1); // But generate intermediate steps
DONE X.shaft_dir(1); // Invert direction to mimic original driver
WIP  X.diag0_stall(1); // diag0 will pull low on stall
WIP  X.diag1_stall(1); 
 X.diag1_active_high(1); // diag1 will pull high on stall
WIP X.coolstep_min_speed(25000); // avoid false stall detection at low speeds
 X.sg_stall_value(14); // figured out by trial and error
 
 Y.begin();
 Y.rms_current(1000);
 Y.microsteps(16);
 Y.interpolate(1);
 Y.shaft_dir(1);
 Y.diag0_stall(1);
 Y.diag1_stall(1);
 Y.diag1_active_high(1);
 Y.coolstep_min_speed(25000);
 Y.sg_stall_value(15);
 }
PUB Setup

    repeat until _ser_cog := ser.Start (115_200)
    ser.Clear
    ser.Str(string("Serial terminal started", ser#NL))
    repeat until tmc.Start (SDI_PIN, SCK_PIN, CS_PIN, SDO_PIN)
    ser.Str (string("TMC2130 driver started"))

DAT
{
    --------------------------------------------------------------------------------------------------------
    TERMS OF USE: MIT License

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
    associated documentation files (the "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
    following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial
    portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
    LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    --------------------------------------------------------------------------------------------------------
}
