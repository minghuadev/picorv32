/*
 *  PicoSoC - A simple example SoC using PicoRV32
 *
 *  Copyright (C) 2017  Clifford Wolf <clifford@clifford.at>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

module spimemio (
	input clk, resetn,

	input valid,
	output reg ready,
	input [23:0] addr,
	output reg [31:0] rdata,

	output flash_csb,
	output flash_clk,

	output flash_io0_oe,
	output flash_io1_oe,
	output flash_io2_oe,
	output flash_io3_oe,

	output flash_io0_do,
	output flash_io1_do,
	output flash_io2_do,
	output flash_io3_do,

	input  flash_io0_di,
	input  flash_io1_di,
	input  flash_io2_di,
	input  flash_io3_di,

	input   [3:0] cfgreg_we,
	input  [31:0] cfgreg_di,
	output [31:0] cfgreg_do
);
	reg        xfer_resetn;

	reg [23:0] rd_addr;
	reg ready_next;
	wire [31:0] rdata_buffer;
	
	initial begin
		ready = 0;
		ready_next = 0;
	end
	
	parameter base_addr_m = 4'b1; // 1M
	parameter base_size_byte = 8192;

	always @(negedge clk) begin
		if ( xfer_resetn && valid && (addr[23:20] == base_addr_m) ) begin
			if (addr[19:0] < base_size_byte) begin
				if ( !ready ) begin
					if ( ready_next ) begin
						ready_next <= 0;
					end else begin
						rd_addr <= addr;
						ready_next <= 1;
					end
				end
			end
		end
	end
	
	altm1p_1        altm1p_1_inst (
        .address( rd_addr[11:0] ), // 12-bit
        .clock ( clk ),
        .data ( 32'b0 ),
        .wren ( 1'b0 ),
        .q ( rdata_buffer )
        );

	always @(posedge clk) begin
		xfer_resetn <= resetn;
		if ( xfer_resetn ) begin
			if ( ready_next ) begin
				rdata <= rdata_buffer;
				ready <= 1;
			end else begin
				ready <= 0;
			end
		end else begin
			ready <= 0;
		end
	end
	
endmodule

