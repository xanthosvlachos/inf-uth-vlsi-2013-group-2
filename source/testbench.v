`include "DMA_regfile.v"

module test_apb_regfile;
	reg		clk;
	reg		reset;

	reg [23:0]		HADDR;
	reg [2:0]		HBURST;
	reg [1:0]		HSIZE;
	reg [1:0]		HTRANS;
	reg				HWRITE;
	reg [31:0]		HWDATA;
	reg				STALL_pre;

	wire [31:0]		HRDATA;
	wire			HREADY;
	wire			HRESP;

	wire			WR;
	wire			RD;
	wire [23:0]		ADDR_WR;
	wire [23:0]		ADDR_RD;
	wire [31:0]		DIN;
	wire [32/8-1:0]	BSEL;
	wire [31:0]		DOUT;

	initial
		begin
			$dumpfile("APB_test.vcd");
			$dumpvars(0, test_apb_regfile);

			clk = 1'b0;
			reset = 1'b1;
			HADDR = 24'h0;
			HBURST = 3'b000;
			HSIZE = 2'b00;
			HTRANS = 2'b00;
			HWRITE = 1'b0;
			HWDATA = 32'h0;
			STALL_pre = 1'b0;

			/* eisagwgh ths timhs 2 sth thesh 20*/
			#5  reset = 1'b0;
				HADDR = 24'h20;
				HBURST = 3'b101;
				HSIZE = 2'b10;
				HTRANS = 2'b10;	/*NONSEQ = 2'b10*/
				HWRITE = 1'b1;
				HWDATA = 32'h1;
				STALL_pre = 1'b1;

			#10 HWRITE = 1'b1; 

			/* anagnwsh ths timhs apo th thesh 20*/
			#10 HWRITE = 1'b0;

			/* eisagwgh ths timhs 2 sth thesh 24*/    
			#10 HADDR = 24'h24;
				HTRANS = 2'b11;	/*SEQ = 2'b11*/
				HWRITE = 1'b1;
				HWDATA = 32'h2;

			#10 HWRITE = 1'b1; 

			/* anagnwsh ths timhs apo th thesh 24*/
			#10 HWRITE = 1'b0;   

			/* eisagwgh ths timhs 2 sth thesh 28*/
			#10 HADDR = 24'h28;
				HTRANS = 2'b10;	/*NONSEQ = 2'b11*/
				HWRITE = 1'b1;
				HWDATA = 32'h3;
			  
			#10 HWRITE = 1'b1; 

			/* anagnwsh ths timhs apo th thesh 28*/
			#10 HWRITE = 1'b0;   

			/* eisagwgh ths timhs 2 sth thesh 2c*/
			#10 HADDR = 24'h2c;
				HTRANS = 2'b11;	/*SEQ = 2'b11*/
				HWRITE = 1'b1;
				HWDATA = 32'h4;

			#10 HWRITE = 1'b1; 

			/* anagnwsh ths timhs apo th thesh 2c*/
			#10 HWRITE = 1'b0;  

			/* eisagwgh ths timhs 2 sth thesh 30*/	
			#10 HADDR = 24'h30;
				HBURST = 3'b101;
				HSIZE = 2'b10;
				HTRANS = 2'b01;	/*STALL   = 2'b01*/
				HWRITE = 1'b1;
				HWDATA = 32'h5;

			#100 $finish;
		end

	always 
		begin
			#5 clk = ~clk;
		end

	DMA_regfile interface_test(clk,reset,pclken,psel,penable,paddr,pwrite,pwdata,prdata,pslverr,pready,buffer_count,int_count,rd_start_addr,wr_start_addr,buffer_size,set_int,cmd_last,next_addr,wr_ch_start);

endmodule
