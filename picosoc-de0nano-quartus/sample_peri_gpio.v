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

module peri_gpio (
	input clk, resetn,

	input valid,
	output reg ready,
	input      [31:0] addr,
	output reg [31:0] rdata,
	input      [3:0]  wstrb, 
	input      [31:0] wdata,
	
	output reg [9:0]  pin_wdata,
	output wire       peri_addr_ok
);
	reg        xfer_resetn;

	initial begin
		ready = 0;
		xfer_resetn = 0;
	end
	
	parameter peri_addr_1 = 32'h0300_0008;
	parameter peri_addr_2 = 32'h0300_0004;
	parameter peri_addr_3 = 32'h0300_0000;
	
	wire peri_ok_1 = (addr == peri_addr_1);
	wire peri_ok_2 = (addr == peri_addr_2);
	wire peri_ok_3 = (addr == peri_addr_3);
	wire peri_any_ok = (peri_ok_1 || peri_ok_2 || peri_ok_3);

	wire peri_addr_in_range = (xfer_resetn && valid && peri_any_ok);
	assign peri_addr_ok = peri_addr_in_range;
	
	always @(posedge clk) begin
		xfer_resetn <= resetn;
		if ( xfer_resetn ) begin
			if ( peri_addr_ok ) begin
				if ( peri_ok_1 ) begin
					pin_wdata <= {2'b01, wdata[7:0]};
					ready <= 1;
				end else if ( peri_ok_2 ) begin
					pin_wdata <= {2'b10,wdata[7:0]};
					ready <= 1;
				end else if ( peri_ok_3 ) begin
					pin_wdata <= {2'b11,wdata[7:0]};
					ready <= 1;
				end else begin
					pin_wdata <= {2'b00,wdata[7:0]};
					ready <= 1;
				end
			end else begin
				ready <= 0;
			end
		end else begin
			ready <= 0;
		end
	end
	
endmodule

