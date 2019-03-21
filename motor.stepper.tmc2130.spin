{
    --------------------------------------------
    Filename: motor.stepper.tmc2130.spin
    Author: Jesse Burt
    Description: Driver for Trinamic TMC2130 stepper-motor driver IC
    Copyright (c) 2018
    Started Dec 2, 2018
    Updated Mar 17, 2019
    See end of file for terms of use.
    --------------------------------------------
}

CON
' Register addresses must be OR'd with $80 to signal intent to write
    WR_REG  = $80

    LOW     = 0
    HIGH    = 1

VAR

' Variables needed for shadow registers
'   (for those on the device that are write-only)
    long _shreg_COOLCONF
    long _shreg_IHOLD_IRUN

    byte _spi_cog
    byte _SDI, _SCK, _CS, _SDO
    byte _SS


OBJ

    core    : "core.con.tmc2130"
    spi     : "SPI_Asm"
    type    : "system.types"

PUB Null
''This is not a top-level object

PUB Start(SDI_PIN, SCK_PIN, CS_PIN, SDO_PIN)

    if lookup(SDI_PIN: 0..31) and lookup(SCK_PIN: 0..31) and lookup(CS_PIN: 0..31) and lookup(SDO_PIN: 0..31)
        if _spi_cog := spi.start (core#CLKDELAY, core#CPOL)
            _SDI := SDI_PIN
            _SCK := SCK_PIN
            _CS := CS_PIN
            _SDO := SDO_PIN
            dira[_CS] := 1
            return _spi_cog
    else
        return FALSE

PUB Stop

    if _spi_cog
        spi.stop
        dira[_CS] := 0

PUB ChipVersion | tmp
' Polls the chip and returns the version
    result := (readRegX (core#REG_IOIN) >> 24) & $FF

PUB CHOPCONF

    result := readRegX (core#REG_CHOPCONF) & core#REG_CHOPCONF_MASK

PUB COOLCONF

    return _shreg_COOLCONF

PUB CoolStepMin(threshold) | tmp'XXX add shadow reg for reading
' Set lower threshold velocity for switching on coolStep and stallGuard features
'   Valid values are 0..1048576
'   Any other value is ignored
    case threshold
        0..1048576: threshold &= core#BITS_TCOOLTHRS
        OTHER:
            return
    writeRegX (core#REG_TCOOLTHRS, threshold)

PUB Diag0Stall(enabled) | tmp
' Should DIAG0 pin be active when a motor stalls?
'   Valid values are TRUE (-1 or 1) or FALSE
'   Any other value polls the chip and returns the current setting
    tmp := readRegX (core#REG_GCONF)
    case ||enabled
        0, 1: enabled := ||enabled << core#FLD_DIAG0_STALL
        OTHER:
            return ((tmp >> core#FLD_DIAG0_STALL) & core#BITS_DIAG0_STALL) * TRUE

    tmp &= core#MASK_DIAG0_STALL
    tmp := (tmp | enabled) & core#REG_GCONF_MASK
    writeRegX (core#REG_GCONF, tmp)

PUB Diag1Stall(enabled) | tmp
' Should DIAG1 pin be active when a motor stalls?
'   Valid values are TRUE (-1 or 1) or FALSE
'   Any other value polls the chip and returns the current setting
    tmp := readRegX (core#REG_GCONF)
    case ||enabled
        0, 1: enabled := ||enabled << core#FLD_DIAG1_STALL
        OTHER:
            return ((tmp >> core#FLD_DIAG1_STALL) & core#BITS_DIAG1_STALL) * TRUE
    tmp &= core#MASK_DIAG1_STALL
    tmp := (tmp | enabled) & core#REG_GCONF_MASK
    writeRegX (core#REG_GCONF, tmp)

PUB Diag1ActiveState(state) | tmp
' Set active state of DIAG1 pin
'   Valid values are HIGH/1 for push-pull, or LOW/0 for open-collector
'   Any other value polls the chip and returns the current setting
    tmp := readRegX (core#REG_GCONF)
    case state
        0, 1: state := state << core#FLD_DIAG1_PUSHPULL
        OTHER:
            return ((tmp >> core#FLD_DIAG1_PUSHPULL) & core#BITS_DIAG1_PUSHPULL) * TRUE
    tmp &= core#MASK_DIAG1_PUSHPULL
    tmp := (tmp | state) & core#REG_GCONF_MASK
    writeRegX (core#REG_GCONF, tmp)

PUB DriveCurrent(mA, Rsense_mOhm) | CS
' Set Driver current
'   mA - Drive current in milliamperes
'   Rsense_mOhm - Value of your driver board's sense resistor, in milliohms
'   Example:
'       mA = 500, Rsense = 110 (for 0.11 Ohm)
    CS := (32 * 1414 * mA / 1000 * (Rsense_mOhm + 20) / 325 - 1000) / 1000

    case CS
        0..15:
            VSense (HIGH)
            CS := (32 * 1414 * mA / 1000 * (Rsense_mOhm + 20) / 180 - 1000) / 1000
        16..31:
            VSense (LOW)
        OTHER:
            return

    _shreg_IHOLD_IRUN &= core#MASK_IRUN
    _shreg_IHOLD_IRUN |= (CS & core#BITS_IRUN) << core#FLD_IRUN

    _shreg_IHOLD_IRUN &= core#MASK_IHOLD
    _shreg_IHOLD_IRUN |= (CS/2 & core#BITS_IHOLD) << core#FLD_IHOLD

    _shreg_IHOLD_IRUN &= core#REG_IHOLD_IRUN_MASK
    writeRegX (core#REG_IHOLD_IRUN, _shreg_IHOLD_IRUN)

PUB RunCurrent
' Returns the motor run current
    return (_shreg_IHOLD_IRUN >> core#FLD_IRUN) & core#BITS_IRUN

PUB HoldCurrent
' Returns the motor standstill current
    return (_shreg_IHOLD_IRUN >> core#FLD_IHOLD) & core#BITS_IHOLD

PUB GCONF

    result := readRegX (core#REG_GCONF) & core#REG_GCONF_MASK

PUB IHOLD_IRUN

    result := _shreg_IHOLD_IRUN & core#REG_IHOLD_IRUN_MASK
    
PUB Interpolate(enabled) | tmp
' Dis/Enable interpolation to 256 microsteps
'   Valid values are TRUE (-1 or 1) or FALSE
'   Any other value polls the chip and returns the current setting
    tmp := readRegX (core#REG_CHOPCONF)
    case ||enabled
        0, 1: enabled := ||enabled << core#FLD_INTPOL
        OTHER:
            return ((tmp >> core#FLD_INTPOL) & core#BITS_INTPOL) * TRUE

    tmp &= core#MASK_INTPOL
    tmp := (tmp | enabled) & core#REG_CHOPCONF_MASK
    writeRegX (core#REG_CHOPCONF, tmp)

PUB InvertShaftDir(enabled) | tmp
' Invert motor direction
'   Valid values are TRUE (-1 or 1) or FALSE
'   Any other value polls the chip and returns the current setting
    tmp := readRegX (core#REG_GCONF)
    case ||enabled
        0, 1: enabled := ||enabled << core#FLD_SHAFT
        OTHER:
            return ((tmp >> core#FLD_SHAFT) & core#BITS_SHAFT) * TRUE

    tmp &= core#MASK_SHAFT
    tmp := (tmp | enabled) & core#REG_GCONF_MASK
    writeRegX (core#REG_GCONF, tmp)

PUB Microsteps(resolution) | tmp
' Set micro-step resolution
'   Valid values are 1, 2, 4, 8, 16, 32, 64, 128 or 256 (power-on default)
'   Any other value polls the chip and returns the current setting
    tmp := readRegX (core#REG_CHOPCONF)
    case resolution
        1, 2, 4, 8, 16, 32, 64, 128, 256:
            resolution := lookdownz(resolution: 256, 1, 2, 4, 8, 16, 32, 64, 128) << core#FLD_MRES
        OTHER:
            result := (tmp >> core#FLD_MRES) & core#BITS_MRES
            return result := lookupz(result: 256, 1, 2, 4, 8, 16, 32, 64, 128)

    tmp &= core#MASK_MRES
    tmp := (tmp | resolution) & core#REG_CHOPCONF_MASK
    writeRegX (core#REG_CHOPCONF, tmp)

PUB ShortProtect(enabled) | tmp
' Short to GND protection
'   Valid values are TRUE (-1 or 1) or FALSE
'   Any other value polls the chip and returns the current setting
    tmp := readRegX (core#REG_CHOPCONF)
    case ||enabled
        0, 1: enabled := ||enabled << core#FLD_DISS2G
        OTHER:
            return ((tmp >> core#FLD_DISS2G) & core#BITS_DISS2G) * TRUE

    tmp &= core#MASK_DISS2G
    tmp := (tmp | enabled) & core#REG_CHOPCONF_MASK
    writeRegX (core#REG_CHOPCONF, tmp)

PUB SPIMode

    result := (readRegX (core#REG_XDIRECT))

PUB Status

    result := readRegX (core#REG_GSTAT)

PUB StallThreshold(level)
' Set stallGuard2 threshold level
'   Valid values are -64 (most sensitive) to 63 (least sensitive)
'   Any other value returns the current setting (*shadow register)
    case level
        -64..63:
            level := (level & %111_1111) << core#FLD_SGT
        OTHER:
            return type.s7((_shreg_COOLCONF >> core#FLD_SGT) & core#BITS_SGT)

    _shreg_COOLCONF &= core#MASK_SGT
    _shreg_COOLCONF |= level
    _shreg_COOLCONF &= core#REG_COOLCONF_MASK
    writeRegX (core#REG_COOLCONF, _shreg_COOLCONF)

PUB VSense(sensitivity) | tmp
' Set sensitivity of sense resistor voltage for use in current scaling
'   Valid values are:
'       0 or LOW - Low sensitivity, for higher sense resistor voltages
'       1 or HIGH - High sensitivity, for lower sense resistor voltages
'   Any other value returns the current setting
    tmp := readRegX (core#REG_CHOPCONF)
    case sensitivity
        0, 1: sensitivity := sensitivity << core#FLD_VSENSE
        OTHER:
            return ((tmp >> core#FLD_VSENSE) & core#BITS_VSENSE)

    tmp &= core#MASK_VSENSE
    tmp := (tmp | sensitivity) & core#REG_CHOPCONF_MASK
    writeRegX (core#REG_CHOPCONF, tmp)

PUB writeRegX(reg, val) | i, cmd_packet[2]

    cmd_packet.long[0] := val
    cmd_packet.byte[4] := reg | WR_REG

    outa[_CS] := 0
   
    repeat i from 4 to 0
        spi.SHIFTOUT (_SDI, _SCK, spi#MSBFIRST, 8, cmd_packet.byte[i])

    outa[_CS] := 1

PUB readRegX(reg) | i, cmd_packet[2]

    cmd_packet.long[0] := $00_00_00_00
    cmd_packet.byte[4] := reg

    outa[_CS] := 0
    repeat i from 4 to 0
        spi.SHIFTOUT (_SDI, _SCK, spi#MSBFIRST, 8, cmd_packet.byte[i])
    outa[_CS] := 1

    outa[_CS] := 0
    repeat i from 4 to 0
        cmd_packet.byte[i] := spi.SHIFTIN (_SDO, _SCK, core#CPHS, 8)
    outa[_CS] := 1

    _SS := cmd_packet.byte[4]  'SPI Status
    result := cmd_packet & $FF_FF_FF_FF

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
