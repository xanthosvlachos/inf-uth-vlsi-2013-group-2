`include "DMA_regfile.v"

module testbench;

	parameter	ADDR_BITS = 16;

	reg			clk;
	reg			reset;

	reg			pclken;
	reg			psel;
	reg			penable;
	reg [ADDR_BITS-1:0]	paddr;
	reg			pwrite;
	reg [31:0]		pwdata;
	
	wire [31:0]		prdata;
	wire			pslverr;
	wire			pready;
	
	reg [15:0]		buffer_count;
	reg [15:0]		int_count;

	wire [31:0]		rd_start_addr;
	wire [31:0]		wr_start_addr;
	wire [31:0]		buffer_size;
	wire			set_int;
	wire			cmd_last;
	wire [27:0]		next_addr;
	wire			wr_ch_start;

	initial
		begin
			$dumpfile("APB_test1.vcd");
			$dumpvars(0, testbench);

			clk	= 1'b0;
			reset	= 1'b1;
			pclken	= 1'b0;
			psel	= 1'b0;
			penable	= 1'b0;
			paddr	= 32'b0;
			pwrite	= 1'b0;
			pwdata	= 32'b0;
			
			buffer_count	= 16'b0;
			int_count	= 16'b0;


			/* IDLE */
			#0	reset	= 1'b0;

			/* SETUP - Write 0101011 in addr 0101 */
			#10	pwrite	= 1'b1;
				psel	= 1'b1;
				paddr	= 32'b0101;
				pwdata	= 32'b0101011;
				buffer_count	= 16'b111;
				int_count	= 16'b0;

			/* ACCESS - Second tick of the clock in current transfer */
			//#30	penable	= 1'b1;

			#10	pclken	= 1'b1;
				penable	= 1'b1;

			#10	pwdata	= 1'b0;
				psel	= 1'b0;
				penable	= 1'b0;

			#20	$finish;
		end

	always 
		begin
			#5 	clk = ~clk;	// period = 10
		end

	DMA_regfile interface_test(clk,reset,pclken,psel,penable,paddr,pwrite,pwdata,prdata,pslverr,pready,buffer_count,int_count,rd_start_addr,wr_start_addr,buffer_size,set_int,cmd_last,next_addr,wr_ch_start);

endmodule