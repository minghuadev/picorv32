
module sample_por(clock48, reseted, resetn_out, clk2);
	input clock48;
	input reseted;
	output resetn_out;
	input clk2;
	
	reg [31:0] initcnt;
	reg resetn_out, reseted_state;
	reg cleared, cleared_state;
	
	parameter reset_clocks = 800; // at 40MHz, 20us, as the raven tb shows
	
	initial begin
		initcnt = 32'b0;
		resetn_out = 1'b0;
		reseted_state = 1'b0;
		cleared = 1'b0;
		cleared_state = 1'b0;
	end
	
	always @(negedge clk2) begin
		if ( !reseted ) begin
			cleared <= 1'b1;
		end else begin
			if (cleared && cleared_state) begin
				cleared <= 1'b0;
			end
		end
	end
	
	always @(posedge clock48)
	begin
		if ( cleared != cleared_state ) begin
			if ( cleared ) begin
				cleared_state <= 1'b1;
				reseted_state <= 1'b0;
			end else begin
				cleared_state <= 1'b0;
			end
		end else if (reseted) begin
			reseted_state <= 1'b1;
		end else begin
			reseted_state <= 1'b0; // never reach as when reseted is low clock48 does not run
		end
		if (reseted_state && !cleared) begin
			if ( initcnt < reset_clocks ) begin
				resetn_out <= 1'b0;
				initcnt <= initcnt + 1;
			end else begin
				resetn_out <= 1'b1;
			end
		end else begin
			initcnt <= 32'b0;
			resetn_out <= 1'b0;
		end
	end
endmodule


