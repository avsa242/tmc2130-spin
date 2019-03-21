{
    --------------------------------------------
    Filename: TMC2130-Test.spin
    Description: Test object for TMC2130 driver
    Author: Jesse Burt
    Copyright (c) 2019
    Created Dec 2, 2018
    Updated Mar 21, 2019
    See end of file for terms of use.
    --------------------------------------------
}

CON

    _clkmode    = cfg#_clkmode
    _xinfreq    = cfg#_xinfreq
    #16, SDI_PIN, SCK_PIN, CS_PIN, SDO_PIN

    DELAY       = 500

    COL_REG     = 0
    COL_SET     = 12
    COL_READ    = 24
    COL_PF      = 40

OBJ

    cfg     : "core.con.boardcfg.flip"
    ser     : "com.serial.terminal"
    time    : "time"
    tmc     : "motor.stepper.tmc2130"
    types   : "system.types"

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

    Test_CoolStepMin (1)
    repeat

PUB Test_CoolStepMin(reps) | tmp, read

    repeat reps
        repeat tmp from 0 to 1024
            tmc.CoolStepMin (tmp)
            read := tmc.CoolStepMin (-2)
            ser.PositionY (7)
            Message (string("CoolStepMin"), tmp, read)

PUB Message(field, arg1, arg2)

    ser.PositionX (COL_REG)
    ser.Str (field)

    ser.PositionX ( COL_SET)
    ser.Str (string("SET: "))
    ser.Dec (arg1)

    ser.PositionX ( COL_READ)
    ser.Str (string("   READ: "))
    ser.Dec (arg2)

    ser.PositionX (COL_PF)
    PassFail (arg1 == arg2)
    ser.NewLine

PUB PassFail(num)

    case num
        0: ser.Str (string("FAIL"))
        -1: ser.Str (string("PASS"))
        OTHER: ser.Str (string("???"))

PUB Setup

    repeat until _ser_cog := ser.Start (115_200)
    ser.Clear
    ser.Str(string("Serial terminal started", ser#NL))
    if tmc.Start (SDI_PIN, SCK_PIN, CS_PIN, SDO_PIN)
        ser.Str (string("TMC2130 driver started"))
    else
        ser.Str (string("TMC2130 driver failed to start - halting"))
        tmc.Stop
        time.MSleep (500)
        ser.Stop
        repeat

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
