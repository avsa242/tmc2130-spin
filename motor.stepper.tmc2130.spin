{
    --------------------------------------------
    Filename: motor.stepper.tmc2130.spin
    Author: Jesse Burt
    Description: Driver for Trinamic TMC2130 stepper-motor driver IC
    Copyright (c) 2018
    See end of file for terms of use.
    --------------------------------------------
}

CON
' Register addresses must be OR'd with $80 to signal intent to write
    WR_REG  = $80

    LOW     = 0
    HIGH    = 1

VAR

    byte _spi_cog
    byte _SDI, _SCK, _CS, _SDO
    byte _SS

' Variables needed for shadow registers
'   (for those on the device that are write-only)
    long _shreg_COOLCONF

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

    result := (tmc_rdDataGram (core#REG_IOIN) >> 24) & $FF

PUB ChopConf

    result := tmc_rdDataGram (core#REG_CHOPCONF) & $FF_FF_FF_FF

PUB COOLCONF

    return _shreg_COOLCONF

PUB CoolStepMin(threshold) | tmp
' Set lower threshold velocity for switching on coolStep and stallGuard features
'   Valid values are 0..1048576
'   Any other value is ignored
    case threshold
        0..1048576: threshold &= core#REG_TCOOLTHRS_BITS
        OTHER:
            return
    tmc_wrDataGram (core#REG_TCOOLTHRS, threshold)

PUB Diag0Stall(enabled) | tmp
' Should DIAG0 pin be active when a motor stalls?
'   Valid values are TRUE, 1 or FALSE
'   Any other value polls the chip and returns the current setting
    case ||enabled
        0, 1: enabled := ||enabled << core#FLD_DIAG0_STALL
        OTHER:
            return (tmc_rdDataGram(core#REG_GCONF) >> core#FLD_DIAG0_STALL & core#FLD_DIAG0_STALL_BITS) * TRUE
    tmp := tmc_rdDataGram (core#REG_GCONF) & core#FLD_DIAG0_STALL_MASK
    tmp |= enabled
    tmc_wrDataGram (core#REG_GCONF, tmp)

PUB Diag1Stall(enabled) | tmp
' Should DIAG1 pin be active when a motor stalls?
'   Valid values are TRUE, 1 or FALSE
'   Any other value polls the chip and returns the current setting
    case ||enabled
        0, 1: enabled := ||enabled << core#FLD_DIAG1_STALL
        OTHER:
            return (tmc_rdDataGram(core#REG_GCONF) >> core#FLD_DIAG1_STALL & core#FLD_DIAG1_STALL_BITS) * TRUE
    tmp := tmc_rdDataGram (core#REG_GCONF) & core#FLD_DIAG1_STALL_MASK
    tmp |= enabled
    tmc_wrDataGram (core#REG_GCONF, tmp)

PUB Diag1ActiveState(state) | tmp
' Set active state of DIAG1 pin
'   Valid values are HIGH/1 for push-pull, or LOW/0 for open-collector
'   Any other value polls the chip and returns the current setting
    case state
        0, 1: state := state << core#FLD_DIAG1_PUSHPULL
        OTHER:
            return (tmc_rdDataGram(core#REG_GCONF) >> core#FLD_DIAG1_PUSHPULL & core#FLD_DIAG1_PUSHPULL_BITS) * TRUE
    tmp := tmc_rdDataGram (core#REG_GCONF) & core#FLD_DIAG1_PUSHPULL_MASK
    tmp |= state
    tmc_wrDataGram (core#REG_GCONF, tmp)

PUB GCONF

    result := tmc_rdDataGram (core#REG_GCONF) & $FF_FF_FF_FF
    
PUB Interpolate(enabled) | tmp
' Dis/Enable interpolation to 256 microsteps
'   Valid values are TRUE, 1 or FALSE
'   Any other value polls the chip and returns the current setting
    case ||enabled
        0, 1: enabled := ||enabled << core#FLD_INTPOL
        OTHER:
            return (tmc_rdDataGram(core#REG_CHOPCONF) >> core#FLD_INTPOL & core#FLD_INTPOL_BITS) * TRUE
    tmp := tmc_rdDataGram (core#REG_CHOPCONF) & core#FLD_INTPOL_MASK
    tmp |= enabled
    tmc_wrDataGram (core#REG_CHOPCONF, tmp)

PUB InvertShaftDir(enabled) | tmp
' Invert motor direction
'   Valid values are TRUE, 1 or FALSE
'   Any other value polls the chip and returns the current setting
    case ||enabled
        0, 1: enabled := ||enabled << core#FLD_SHAFT
        OTHER:
            return (tmc_rdDataGram(core#REG_GCONF) >> core#FLD_SHAFT & core#FLD_SHAFT_BITS) * TRUE
    tmp := tmc_rdDataGram (core#REG_GCONF) & core#FLD_SHAFT_MASK
    tmp |= enabled
    tmc_wrDataGram (core#REG_GCONF, tmp)

PUB Microsteps(resolution) | tmp
' Set micro-step resolution
'   Valid values are 1, 2, 4, 8, 16, 32, 64, 128 or 256 (power-on default)
'   Any other value polls the chip and returns the current setting
    case resolution
        1, 2, 4, 8, 16, 32, 64, 128, 256:
            resolution := lookdownz(resolution: 256, 1, 2, 4, 8, 16, 32, 64, 128) << core#FLD_MRES
        OTHER:
            result := (tmc_rdDataGram(core#REG_CHOPCONF) >> core#FLD_MRES) & core#FLD_MRES_BITS
            return result := lookupz(result: 256, 1, 2, 4, 8, 16, 32, 64, 128)

    tmp := tmc_rdDataGram (core#REG_CHOPCONF) & core#FLD_MRES_MASK
    tmp |= resolution
    tmc_wrDataGram (core#REG_CHOPCONF, tmp)

PUB ShortProtect(enabled) | tmp
' Short to GND protection
'   Valid values are TRUE, 1 or FALSE
'   Any other value polls the chip and returns the current setting
    case ||enabled
        0, 1: enabled := ||enabled << core#FLD_DISS2G
        OTHER:
            return tmc_rdDataGram((core#REG_CHOPCONF >> core#FLD_DISS2G) & core#FLD_DISS2G_BITS) * TRUE
    tmp := tmc_rdDataGram (core#REG_CHOPCONF) & core#FLD_DISS2G_MASK
    tmp |= enabled
    tmc_wrDataGram (core#REG_CHOPCONF, tmp)

PUB SPIMode

    result := (tmc_rdDataGram (core#REG_XDIRECT))

PUB Status

    result := tmc_rdDataGram (core#REG_GSTAT)

PUB StallThreshold(level)
' Set stallGuard2 threshold level
'   Valid values are -64 (most sensitive) to 63 (least sensitive)
'   Any other value returns the current setting (*shadow register)
    case level
        -64..63:
            level := (level & %111_1111) << core#FLD_SGT
        OTHER:
            return type.s7((_shreg_COOLCONF >> core#FLD_SGT) & core#FLD_SGT_BITS)

    _shreg_COOLCONF &= core#FLD_SGT_MASK
    _shreg_COOLCONF |= level
    tmc_wrDataGram (core#REG_COOLCONF, _shreg_COOLCONF)

PRI tmc_wrDataGram(reg, val) | i, dgram[2]

    dgram.byte[4] := reg | WR_REG
    dgram.long[0] := val

    outa[_CS] := 0
   
    repeat i from 4 to 0
        spi.SHIFTOUT (_SDI, _SCK, spi#MSBFIRST, 8, dgram.byte[i])

    outa[_CS] := 1

PRI tmc_rdDataGram(reg) | i, tmp[2]

'    tmc_wrDataGram (reg, $00_00_00_00)
    tmp.byte[4] := reg
    tmp.long[0] := $00_00_00_00

    outa[_CS] := 0
    repeat i from 4 to 0
        spi.SHIFTOUT (_SDI, _SCK, spi#MSBFIRST, 8, tmp.byte[i])
    outa[_CS] := 1

    outa[_CS] := 0
    repeat i from 4 to 0
        tmp.byte[i] := spi.SHIFTIN (_SDO, _SCK, core#CPHS, 8)'Dpin, Cpin, Mode, Bits)
    outa[_CS] := 1

    _SS := tmp.byte[4]  'SPI Status
    result := tmp & $FF_FF_FF_FF

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
