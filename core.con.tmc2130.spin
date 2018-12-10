{
    --------------------------------------------
    Filename: core.con.tmc2130.spin
    Author: Jesse Burt
    Copyright (c) 2018
    Started: Dec 2, 2018
    Updated: Dec 2, 2018
    See end of file for terms of use.
    --------------------------------------------
}

CON

    CPOL                        = 1
    CPHS                        = 2
    CLKDELAY                    = 1
'' Register definitions
    REG_GCONF                   = $00
    REG_GCONF_MASK              = $1_FF_FF
        FLD_DIAG1_PUSHPULL      = 13
        FLD_DIAG1_PUSHPULL_BITS = %1
        FLD_DIAG1_PUSHPULL_MASK = ($FF_FF_FF_FF - (FLD_DIAG1_PUSHPULL_BITS << FLD_DIAG1_PUSHPULL))

        FLD_DIAG1_STALL         = 8
        FLD_DIAG1_STALL_BITS    = %1
        FLD_DIAG1_STALL_MASK    = ($FF_FF_FF_FF - (FLD_DIAG1_STALL_BITS << FLD_DIAG1_STALL))

        FLD_DIAG0_STALL         = 7
        FLD_DIAG0_STALL_BITS    = %1
        FLD_DIAG0_STALL_MASK    = ($FF_FF_FF_FF - (FLD_DIAG0_STALL_BITS << FLD_DIAG0_STALL))

        FLD_SHAFT               = 4
        FLD_SHAFT_BITS          = %1
        FLD_SHAFT_MASK          = ($FF_FF_FF_FF - (FLD_SHAFT_BITS << FLD_SHAFT))
    REG_GSTAT                   = $01
    REG_IOIN                    = $04
    REG_IHOLD_IRUN              = $10
    REG_IHOLD_IRUN_MASK         = $F_1F_1F
        FLD_IHOLD               = 0
        FLD_IHOLD_BITS          = %11111
        FLD_IHOLD_MASK          = ($FF_FF_FF_FF - (FLD_IHOLD_BITS << FLD_IHOLD))

        FLD_IRUN                = 8
        FLD_IRUN_BITS           = %11111
        FLD_IRUN_MASK           = ($FF_FF_FF_FF - (FLD_IRUN_BITS << FLD_IRUN))

        FLD_IHOLDDELAY         = 16
        FLD_IHOLDDELAY_BITS    = %1111
        FLD_IHOLDDELAY_MASK    = ($FF_FF_FF_FF - (FLD_IHOLDDELAY_BITS << FLD_IRUN))

    REG_TPOWERDOWN              = $11
    REG_TSTEP                   = $12
    REG_TPWMTHRS                = $13
    REG_TCOOLTHRS               = $14
        REG_TCOOLTHRS_BITS      = %1111_1111_1111_1111_1111
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
        FLD_DISS2G_BITS         = %1
        FLD_DISS2G_MASK         = ($FF_FF_FF_FF - (FLD_DISS2G_BITS << FLD_DISS2G))
        FLD_INTPOL              = 28
        FLD_INTPOL_BITS         = %1
        FLD_INTPOL_MASK         = ($FF_FF_FF_FF - (FLD_INTPOL_BITS << FLD_INTPOL))
        FLD_MRES                = 24
        FLD_MRES_BITS           = %1111
        FLD_MRES_MASK           = ($FF_FF_FF_FF - (FLD_MRES_BITS << FLD_MRES))
        FLD_VSENSE              = 17
        FLD_VSENSE_BITS         = %1
        FLD_VSENSE_MASK         = ($FF_FF_FF_FF - (FLD_VSENSE_BITS << FLD_VSENSE))

    REG_COOLCONF                = $6D
    REG_COOLCONF_MASK           = $1_7F_EF_6F
        FLD_SGT                 = 16
        FLD_SGT_BITS            = %1111111
        FLD_SGT_MASK            = ($FF_FF_FF_FF - (FLD_SGT_BITS << FLD_SGT))

    REG_DCCTRL                  = $6E
    REG_DRV_STATUS              = $6F
    REG_PWMCONF                 = $70
    REG_PWM_SCALE               = $71
    REG_ENCM_CTRL               = $72
    REG_LOST_STEPS              = $73

PUB Null
'' This is not a top-level object
