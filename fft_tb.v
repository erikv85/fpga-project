`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2017 03:33:29 PM
// Design Name: 
// Module Name: mat_mul_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fft_tb # 
    (
        parameter integer ARRAY_SIZE = 2,
        parameter integer DATA_WIDTH = 32        
        
    )
    (

    );
    
    reg  s00_axi_aclk;
    reg  s00_axi_aresetn;

	// Ports of Axi Slave Bus Interface S00_AXIS
    wire  s00_axis_tready;
    reg [DATA_WIDTH-1 : 0] s00_axis_tdata;
    reg [(DATA_WIDTH/8)-1 : 0] s00_axis_tstrb;
    reg  s00_axis_tlast;
    reg  s00_axis_tvalid;

    // Ports of Axi Master Bus Interface M00_AXIS
    wire  m00_axis_tvalid;
    wire [DATA_WIDTH-1 : 0] m00_axis_tdata;
    wire [(DATA_WIDTH/8)-1 : 0] m00_axis_tstrb;
    wire  m00_axis_tlast;
    reg  m00_axis_tready;
    
    
    reg start;
    
    integer row;
    
    integer count;
    integer temp_counter;
    
    integer A [0 : ARRAY_SIZE-1];
    integer B [0 : ARRAY_SIZE-1];
    integer RSW ;
    integer RHW ;
    
    fft # (
    .SIZE(ARRAY_SIZE),
    .DATA_WIDTH(DATA_WIDTH)
    ) accelerator (
    .s00_axi_aclk(s00_axi_aclk),
    .s00_axi_aresetn(s00_axi_aresetn),
    .s00_axis_tready(s00_axis_tready),
    .s00_axis_tdata(s00_axis_tdata),
    .s00_axis_tlast(s00_axis_tlast),
    .s00_axis_tvalid(s00_axis_tvalid),
    .m00_axis_tvalid(m00_axis_tvalid),
    .m00_axis_tdata(m00_axis_tdata),
    .m00_axis_tstrb(m00_axis_tstrb),
    .m00_axis_tlast(m00_axis_tlast),
    .m00_axis_tready(m00_axis_tready), 
    .start(start)
    );
    
    always
        #10 s00_axi_aclk = ~s00_axi_aclk;
        
    initial begin
        s00_axi_aclk = 1;
        s00_axi_aresetn = 0;
        s00_axis_tdata = 0;
        s00_axis_tstrb = 4'hf;
        s00_axis_tlast = 0;
        s00_axis_tvalid = 0;
        m00_axis_tready = 0;
        start = 0;
        row = 0;
        
        count = 0;
        temp_counter= 0;
        
        // initialise the matrices; for debug use $urandom%10 to have unsigned values less than 10;
        for (row = 0; row < ARRAY_SIZE; row = row + 1)    
                A [row] = $urandom;
            
        #20
        s00_axi_aresetn = 1;
        count = 0;
        
        // send the two matrices using the AXI Stream protocol
        
        #20
        s00_axis_tvalid = 1;
        for (row = 0; row < ARRAY_SIZE; row = row + 1) begin
                
            s00_axis_tdata = A [row];
            if (row == ARRAY_SIZE-1)
                s00_axis_tlast = 1;
            #20;
                // wait until the slave is ready to read the data
            while (!s00_axis_tready) begin
                #20;
            end  
        end
            
        s00_axis_tlast = 0;
        s00_axis_tvalid = 0;
        
        // start the accelerator
        #20
        start = 1;
        #20
        start = 0;
        
        m00_axis_tready = 1;
        
        while (!m00_axis_tlast) begin
            #20;
            if(m00_axis_tready == 1 && m00_axis_tvalid == 1) begin
                RHW = m00_axis_tdata;
            end
        end
        m00_axis_tready = 0;
               
       $stop;
       
    end
    
endmodule