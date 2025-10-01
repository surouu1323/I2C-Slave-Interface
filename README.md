# I2C Slave Interface

## Introduction

This is a Verilog I2C Slave module designed for communication with Microcontroller
to register in FPGA.\
The protocol format is: 
- Slave address: configurable via parameter `SLAVE_ADDR` (7-bit). 
- Access format: - Write: 2-byte register address + 4-byte data 
                 - Read: 2-byte register address, followed by 4-byte data returned

Tested and working in I2C Fast Mode (400kHz).

## Specifications

-   Register Address: 16-bit\
-   Data: 32-bit\
-   Supports Standard mode (100kHz) and Fast mode (400kHz)\
-   Internal signals:
    -   `addr [15:0]` -- register address
    -   `wdata [31:0]` -- write data
    -   `rdata [31:0]` -- read data from backend
    -   `wr_en` -- write enable
    -   `rd_en` -- read enable

## Repository Structure

    src/
      i2c_slave_if.v      # Verilog source
    tb/
      i2c_task.v          # I2C Master tasks for simulation
      tb.v                # Testbench using i2c_task
    README.md

## Usage

Example instantiation:

``` verilog
i2c_slave_if #(
    .SLAVE_ADDR(SLAVE_ADDR)
) u_i2c_slave (
    .clk     (clk),
    .rst_n   (rst_n),
    .SDA_bus (SDA_bus),
    .SCL_bus (SCL_bus),
    .addr    (addr),
    .wdata   (wdata),
    .rdata   (rdata),
    .wr_en   (wr_en),
    .rd_en   (rd_en)
);
```

Write access:

    [SlaveAddr+W] + [RegAddr_H][RegAddr_L] + [Data3][Data2][Data1][Data0]

Read access:

    [SlaveAddr+W] + [RegAddr_H][RegAddr_L]
    [RESTART + SlaveAddr+R] -> [Data3][Data2][Data1][Data0]

## Status

-   Tested with ESP8266, working in Fast Mode 400kHz\
-   Not supporting 10-bit addressing\
-   Not supporting multi-master arbitration
