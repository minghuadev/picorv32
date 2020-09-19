
module sample_por(clock48, reseted, resetn_out);
	input clock48;
	input reseted;
	output resetn_out;
	
	reg [31:0] initcnt;
	reg resetn_out, reseted_state;
	
	parameter reset_clocks = 800; // at 40MHz, 20us, as the raven tb shows
	
	initial begin
		initcnt = 32'b0;
		resetn_out = 1'b0;
		reseted_state = 1'b0;
	end
	
	always @(posedge clock48)
	begin
		if (reseted) begin
			reseted_state <= 1'b1;
		end
		if (reseted_state) begin
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


