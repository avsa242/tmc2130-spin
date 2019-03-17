{
    --------------------------------------------
    Filename: core.con.tmc2130.spin
    Author: Jesse Burt
    Description: Low-level constants
    Copyright (c) 2018
    Started: Dec 2, 2018
    Updated: Mar 17, 2019
    See end of file for terms of use.
    --------------------------------------------
}

CON

' SPI configuration
    CPOL                        = 1
    CPHS                        = 2
    CLKDELAY                    = 10

' Register definitions
    REG_GCONF                   = $00
    REG_GCONF_MASK              = $00_01_FF_FF
        FLD_DIAG1_PUSHPULL      = 13
        BITS_DIAG1_PUSHPULL     = %1
        MASK_DIAG1_PUSHPULL     = REG_GCONF_MASK ^ (BITS_DIAG1_PUSHPULL << FLD_DIAG1_PUSHPULL)

        FLD_DIAG1_STALL         = 8
        BITS_DIAG1_STALL        = %1
        MASK_DIAG1_STALL        = REG_GCONF_MASK ^ (BITS_DIAG1_STALL << FLD_DIAG1_STALL)

        FLD_DIAG0_STALL         = 7
        BITS_DIAG0_STALL        = %1
        MASK_DIAG0_STALL        = REG_GCONF_MASK ^ (BITS_DIAG0_STALL << FLD_DIAG0_STALL)

        FLD_SHAFT               = 4
        BITS_SHAFT              = %1
        MASK_SHAFT              = REG_GCONF_MASK ^ (BITS_SHAFT << FLD_SHAFT)

    REG_GSTAT                   = $01

    REG_IOIN                    = $04
    REG_IOIN_MASK               = $FF_00_00_7F
        FLD_VERSION             = 24
        BITS_VERSION            = %1111_1111
        MASK_VERSION            = REG_IOIN_MASK ^ (BITS_VERSION << FLD_VERSION)

    REG_IHOLD_IRUN              = $10
    REG_IHOLD_IRUN_MASK         = $F_1F_1F
        FLD_IHOLD               = 0
        BITS_IHOLD              = %11111
        MASK_IHOLD              = REG_IHOLD_IRUN_MASK ^ (BITS_IHOLD << FLD_IHOLD)

        FLD_IRUN                = 8
        BITS_IRUN               = %11111
        MASK_IRUN               = REG_IHOLD_IRUN_MASK ^ (BITS_IRUN << FLD_IRUN)

        FLD_IHOLDDELAY          = 16
        BITS_IHOLDDELAY         = %1111
        MASK_IHOLDDELAY         = REG_IHOLD_IRUN_MASK ^ (BITS_IHOLDDELAY << FLD_IRUN)

    REG_TPOWERDOWN              = $11
    REG_TSTEP                   = $12
    REG_TPWMTHRS                = $13
    REG_TCOOLTHRS               = $14
        BITS_TCOOLTHRS          = %1111_1111_1111_1111_1111
    REG_THIGH                   = $15

'' SPI MODE
    REG_XDIRECT                 = $2D

'' dcStep MIN VELOCITY REG    
    REG_VDCMIN                  = $33

'' MOTOR DRIVER REGISTERS
    REG_MSLUT                   = $60
    REG_MSLUT1                  = $61
    REG_MSLUT2                  = $62
    REG_MSLUT3                  = $63
    REG_MSLUT4                  = $64
    REG_MSLUT5                  = $65
    REG_MSLUT6                  = $66
    REG_MSLUT7                  = $67
    REG_MSLUTSEL                = $68
    REG_MSLUTSTART              = $69
    REG_MSCNT                   = $6A
    REG_MSCURACT                = $6B
    REG_CHOPCONF                = $6C
    REG_CHOPCONF_MASK           = $7F_FF_FF_FF
        FLD_DISS2G              = 30
        BITS_DISS2G             = %1
        MASK_DISS2G             = REG_CHOPCONF_MASK ^ (BITS_DISS2G << FLD_DISS2G)
        FLD_INTPOL              = 28
        BITS_INTPOL             = %1
        MASK_INTPOL             = REG_CHOPCONF_MASK ^ (BITS_INTPOL << FLD_INTPOL)
        FLD_MRES                = 24
        BITS_MRES               = %1111
        MASK_MRES               = REG_CHOPCONF_MASK ^ (BITS_MRES << FLD_MRES)
        FLD_VSENSE              = 17
        BITS_VSENSE             = %1
        MASK_VSENSE             = REG_CHOPCONF_MASK ^ (BITS_VSENSE << FLD_VSENSE)

    REG_COOLCONF                = $6D
    REG_COOLCONF_MASK           = $1_7F_EF_6F
        FLD_SGT                 = 16
        BITS_SGT                = %1111111
        MASK_SGT                = REG_COOLCONF_MASK ^ (BITS_SGT << FLD_SGT)

    REG_DCCTRL                  = $6E
    REG_DRV_STATUS              = $6F
    REG_PWMCONF                 = $70
    REG_PWM_SCALE               = $71
    REG_ENCM_CTRL               = $72
    REG_LOST_STEPS              = $73

PUB Null
'' This is not a top-level object
