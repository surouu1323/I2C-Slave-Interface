`timescale 1ns/1ps

module tb;
    

    `include "../tb/i2c_task.v"
    reg clk;
    reg clk_slave;
    reg rst_n;
    wire rst;
    reg scl_en;
    reg scl;
    reg sda_drive;   // master điều khiển SDA
    wire sda;        // SDA line (pull-up)
    reg ack_respone;
    
    // Pull-up giả lập bus
    pullup(sda);

    parameter SLAVE_ADD = 7'h50;

    top dut(
        .clk(clk_slave),
        .rst(rst),
        .SCL_bus(scl),
        .SDA_bus(sda)
    );

    // Dump waveform ra file VCD
    initial begin
    `ifdef WAVE
        $display("=== DUMP NORMAL VCD ===");
        $dumpfile("dump.vcd");
        $dumpvars(0);
    `elsif DEC
        $display("=== DUMP DEC VCD ===");
        $dumpfile("dump_dec.vcd");
        $dumpvars(0,tb.sda,tb.scl);
    `else
        $display("=== RUN DEFAULT CASE ===");
    `endif
    end

   

    // Kết nối SDA: master có thể drive low hoặc nhả ra
    assign sda = (sda_drive) ? 1'bz : 1'b0;
    

    always @(posedge clk) begin
        if (!scl_en)
            scl <= 1'b1;        // giữ high khi enable
        else
            scl <= ~scl;    // tạo xung khi disable
    end


    assign rst = ~rst_n;
    // Clock nội bộ cho slave: 27 MHz
    initial begin
        clk_slave = 0;
        forever #(18.5) clk_slave = ~clk_slave;  // ~27 MHz
    end

    // Clock nội bộ để generate SCL: 400 kHz
    initial begin
        clk = 1;
        forever #(625) clk = ~clk;  // 400 kHz (2.5 us period)
    end

    
    
    initial begin
        scl = 1;
        scl_en = 0;
        sda_drive = 1'b1;
        rst_n = 0;
        ack_respone = 0;
        #5;
        rst_n = 1;
        #5;

        $display("=== SLAVE WRITE ===");
        i2c_write(16'h0, 32'h01020304);

        #5000;

        $display("=== SLAVE READ  ===");
        i2c_read (16'h0, 32'h01020304);
        #10000;
        $finish;
    end

endmodule
