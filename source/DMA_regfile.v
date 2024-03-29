module DMA_regfile (clk,
		reset,		// INPUT...Active low reset
		pclken,		// INPUT...APB processor clock
		psel,		// INPUT...Select a particular device
		penable,	// INPUT...Enable data line
		paddr,		// INPUT...Address lines from the APB bus
		pwrite,		// INPUT...1'bx={0, 1} ? write transfer : read transfer
		pwdata,		// INPUT...Input data bus from APB bus
		prdata,		// OUTPUT...Output data bus to the APB transfer
		pslverr,	// OUTPUT...Error signal that indicates failure of a transfer
		pready,		// OUTPUT...Used by slave to extend the APB transfer
		buffer_count,
		int_count,
		rd_start_addr,	// OUTPUT...Enable signal for reading data from the ram connected to APB IF
		wr_start_addr,	// OUTPUT...Enable signal for writing data to the ram connected to APB IF
		buffer_size,
		set_int,
		cmd_last,
		next_addr,	// OUTPUT...Next address of the ram to which data has to be written or read from
		wr_ch_start);

	parameter			ADDR_BITS = 16;

	input				clk;
	input				reset;
	input				pclken;
	input				psel;
	input				penable;
	input [ADDR_BITS-1:0]	paddr;
	input				pwrite;
	input [31:0]		pwdata;
	output [31:0]		prdata;
	output				pslverr;
	output				pready;

	input [15:0]		buffer_count;
	input [15:0]		int_count;
	output [31:0]		rd_start_addr;
	output [31:0]		wr_start_addr;
	output [31:0]		buffer_size;
	output				set_int;
	output				cmd_last;
	output [27:0]		next_addr;
	output				wr_ch_start;


	wire			gpwrite;
	wire			gpread;
	reg [31:0]		prdata_pre;
	reg				pslverr_pre;
	reg [31:0]		prdata;
	reg				pslverr;
	reg				pready;

	wire			wr_reg0, wr_reg1, wr_reg2, wr_reg3, wr_reg4;
	reg [31:0]		rd_reg0, rd_reg1, rd_reg2, rd_reg3, rd_reg5;

	reg [31:0]		rd_start_addr;
	reg [31:0]		wr_start_addr;
	reg [31:0]		buffer_size;
	reg				set_int;
	reg				cmd_last;
	reg [27:0]		next_addr;
	
	//TA XWRAFIA MAS
	reg				last_tick;
	//TELEIWNOUN EDW

	wire			wr_ch_start;
   
	//---------------------- addresses-----------------------------------
	parameter		CONFIG0 = 'h0;		//DMA command reg 0
	parameter		CONFIG1 = 'h4;		//DMA command reg 1
	parameter		CONFIG2 = 'h8;		//DMA command reg 2
	parameter		CONFIG3 = 'hC;		//DMA command reg 3
	parameter		START	= 'h20;		//Channel start
	parameter		STATUS	= 'h30;		//Channel status

	//---------------------- gating -------------------------------------
	assign			gpwrite	= psel & (~penable) & pwrite;
	assign			gpread	= psel & (~penable) & (~pwrite);

	//---------------------- Write Operations ---------------------------
	assign			wr_reg0 = gpwrite & (paddr == CONFIG0);
	assign			wr_reg1 = gpwrite & (paddr == CONFIG1);
	assign			wr_reg2 = gpwrite & (paddr == CONFIG2);
	assign			wr_reg3 = gpwrite & (paddr == CONFIG3);
	assign			wr_reg4 = gpwrite & (paddr == START);

	//DMA command reg 0
	always @(posedge clk or posedge reset)
		if (reset)
			begin
				rd_start_addr <= 32'd0;	//Read start address
			end
		else if (wr_reg0)
			begin
				rd_start_addr <= pwdata[31:0];
			end
       
	//DMA command reg 1
	always @(posedge clk or posedge reset)
		if (reset)
			begin
				wr_start_addr <= 32'd0;	//Write start address
			end
		else if (wr_reg1)
			begin
				wr_start_addr <= pwdata[31:0];
			end
       
	//DMA command reg 2
	always @(posedge clk or posedge reset)
		if (reset)
			begin
				buffer_size <= 32'd0;	//Buffer size
			end
		else if (wr_reg2)
			begin
				buffer_size <= pwdata[31:0];
			end
	   
	//DMA command reg 3
	always @(posedge clk or posedge reset)
		if (reset)
			begin
				set_int		<=  1'd0;	//Set interrupt on completion
				cmd_last	<=  1'd1;	//Last command in list
				next_addr	<=  28'd0;	//Next command address
			end
		else if (wr_reg3)
			begin
				set_int		<=  pwdata[0:0];
				cmd_last	<=  pwdata[1:1];
				next_addr	<=  pwdata[31:4];
			end

	assign  wr_ch_start = {1{wr_reg4}} & pwdata[0:0];
          
	//---------------------- Read Operations ----------------------------
	always @(*)
		begin
			rd_reg0  = {32{1'b0}};
			rd_reg1  = {32{1'b0}};
			rd_reg2  = {32{1'b0}};
			rd_reg3  = {32{1'b0}};
			rd_reg5  = {32{1'b0}};

			rd_reg0[31:0]	= rd_start_addr;	//Read start address
			rd_reg1[31:0]	= wr_start_addr;	//Write start address
			rd_reg2[31:0]	= buffer_size;		//Buffer size
			rd_reg3[0:0]	= set_int;		//Set interrupt on completion
			rd_reg3[1:1]	= cmd_last;		//Last command in list
			rd_reg3[31:4]	= next_addr;		//Next command address
			rd_reg5[15:0]	= buffer_count;		//Buffer counter
			rd_reg5[31:16]	= int_count;		//Interrupt counter
		end
   
	always @(*)
		begin
			prdata_pre  = {32{1'b0}};

			case (paddr)
				CONFIG0	: prdata_pre = rd_reg0;
				CONFIG1	: prdata_pre = rd_reg1;
				CONFIG2	: prdata_pre = rd_reg2;
				CONFIG3	: prdata_pre = rd_reg3;
				STATUS	: prdata_pre = rd_reg5;
				default	: prdata_pre = {32{1'b0}};
			endcase
		end

   
	always @(paddr or gpread or gpwrite or psel)
		begin
			pslverr_pre = 1'b0;

			case (paddr)
				CONFIG0	: pslverr_pre = 1'b0;		//read and write
				CONFIG1	: pslverr_pre = 1'b0;		//read and write
				CONFIG2	: pslverr_pre = 1'b0;		//read and write
				CONFIG3	: pslverr_pre = 1'b0;		//read and write
				STATUS	: pslverr_pre = gpwrite;	//read only
				START	: pslverr_pre = gpread;		//write only
				default	: pslverr_pre = psel;		//decode error
			endcase
		end

     
	//---------------------- Sample outputs -----------------------------
	always @(posedge clk or posedge reset)
		if (reset)
			prdata <=  {32{1'b0}};
		else if (gpread & pclken)
			prdata <=  prdata_pre;
		else if (pclken)
			prdata <=  {32{1'b0}};
   
	always @(posedge clk or posedge reset)
		if (reset)
			begin
				pslverr	<=  1'b0;
				pready	<=  1'b0;
			end
		else if ((gpread | gpwrite) & pclken)
			begin
				pslverr	<=  pslverr_pre;
//				pready	<=  1'b1;				////
			end
		else if (pclken)
			begin
				pslverr	<=  1'b0;
//				pready	<=  1'b0;				////
			end
			
/*	always @(posedge clk or posedge reset)
		if (reset)
			begin
				last_tick	<= 1'b0;
			end
		else if (penable & ~last_tick)
			begin			
				pready	<= penable;
				last_tick	<= 1'b1;
			end
		else if ((penable == 1'b0) & last_tick)
			begin
				pready	<= 1'b0;
			end
		*/

	always @(posedge clk)
		pready <= pclken;
		
endmodule
