//`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "multiplicador_32_bits_FP_IEEE.sv"
`include "Interface.sv"
`include "sequence_item.sv"
`include "Sequence.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "agent.sv"
`include "enviroment.sv"
`include "test.sv"

module tb_top;
	
	

	reg clk;
	always #10 clk <= ~clk;


	//Instantiate the interface and pass it to design
	dut_if	vif(clk);

       top DUT(
		.clk(clk),
		.r_mode(vif.r_mode),
		.fp_X(vif.fp_X), 
		.fp_Y(vif.fp_Y),
		.fp_Z(vif.fp_Z),
		.ovrf(vif.ovrf), 
		.udrf(vif.udrf)
		);

	initial begin
		clk <=0;
		vif.fp_X<=0;
		vif.fp_Y<=0;
		vif.r_mode<=0;
		uvm_config_db #(virtual dut_if)::set(null,"uvm_test_top","dut_if", vif);
		run_test();
	end


endmodule




