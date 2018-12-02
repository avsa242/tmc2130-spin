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

    CPOL            = 1
    CPHS            = 2
    CLKDELAY        = 1
'' Register definitions
    REG_GCONF       = $00
    REG_GSTAT       = $01
    REG_IOIN        = $04
    REG_IHOLD_IRUN  = $10
    REG_TPOWERDOWN  = $11
    REG_TSTEP       = $12
    REG_TPWMTHRS    = $13
    REG_TCOOLTHRS   = $14
    REG_THIGH       = $15

'' SPI MODE
    REG_XDIRECT     = $2D

'' dcStep MIN VELOCITY REG    
    REG_VDCMIN      = $33

'' MOTOR DRIVER REGISTERS
    REG_MSLUT               = $60
    REG_MSLUT1              = $61
    REG_MSLUT2              = $62
    REG_MSLUT3              = $63
    REG_MSLUT4              = $64
    REG_MSLUT5              = $65
    REG_MSLUT6              = $66
    REG_MSLUT7              = $67
    REG_MSLUTSEL            = $68
    REG_MSLUTSTART          = $69
    REG_MSCNT               = $6A
    REG_MSCURACT            = $6B
    REG_CHOPCONF            = $6C
        FLD_DISS2G          = 30
        FLD_DISS2G_MASK     = ($FF_FF_FF_FF - (1 << FLD_DISS2G))
        FLD_INTPOL          = 28
        FLD_INTPOL_MASK     = ($FF_FF_FF_FF - (1 << FLD_INTPOL))
    REG_COOLCONF            = $6D
    REG_DCCTRL              = $6E
    REG_DRV_STATUS          = $6F
    REG_PWMCONF             = $70
    REG_PWM_SCALE           = $71
    REG_ENCM_CTRL           = $72
    REG_LOST_STEPS          = $73

PUB Null
'' This is not a top-level object
