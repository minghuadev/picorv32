/*
 *  Raven - A full example SoC using PicoRV32 in X-Fab XH018
 *
 *  Copyright (C) 2017  Clifford Wolf <clifford@clifford.at>
 *  Copyright (C) 2018  Tim Edwards <tim@efabless.com>
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

`timescale 1 ns / 1 ps


`define PICOSOC_MEM picosoc_mem_de0nano


module picosoc_mem_de0nano #(
	parameter integer WORDS = 256
) (
	input clk,
	input [3:0] wen,
	input [21:0] addr,
	input [31:0] wdata,
	output [31:0] rdata
);

	picosoc_mem_banked #( .WORDS(WORDS) ) mem_bank_0 (
		.clk(clk), .wen(wen[0]), .addr(addr),
		.wdata(wdata[7:0]),
		.rdata(rdata[7:0])
	);
	picosoc_mem_banked #( .WORDS(WORDS) ) mem_bank_1 (
		.clk(clk), .wen(wen[1]), .addr(addr),
		.wdata(wdata[15:8]),
		.rdata(rdata[15:8])
	);
	picosoc_mem_banked #( .WORDS(WORDS) ) mem_bank_2 (
		.clk(clk), .wen(wen[2]), .addr(addr),
		.wdata(wdata[23:16]),
		.rdata(rdata[23:16])
	);
	picosoc_mem_banked #( .WORDS(WORDS) ) mem_bank_3 (
		.clk(clk), .wen(wen[3]), .addr(addr),
		.wdata(wdata[31:24]),
		.rdata(rdata[31:24])
	);
endmodule

module picosoc_mem_banked #(
	parameter integer WORDS = 256
) (
	input clk,
	input  wen,
	input [21:0] addr,
	input [7:0] wdata,
	output reg [7:0] rdata
);
	reg [7:0] mem [0:WORDS-1];

	always @(posedge clk) begin
		rdata <= mem[addr];
		if (wen) mem[addr] <= wdata;
	end
endmodule


