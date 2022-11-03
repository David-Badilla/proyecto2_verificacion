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











// -----------------EMPIEZAN FUNCIONES------------------------------------



	real entero;
	bit [31:0]par_ent;
	int expone;
	int auxi;
	real fraccion;
	real peso_decimal;
	function real IEEE_Int(bit [31:0] iee); //funcion para convertir del formato IE745 a decimal
	if(iee!=0)begin
		expone= iee[30:23];
		expone-=127;
		//$display("\nExponente = %d",expone);
		
		par_ent=0;
		if(expone>0)par_ent[0]=1;
		//$display ("Expone %g",expone);
		if(expone>=0)begin
			for(int i=0;i<expone;i++)begin
				par_ent=par_ent<<1;
				par_ent[0]=iee[22-i];	
			end
		end
		entero=par_ent;
		//$display("\nEntero = %f %0b",entero, entero);

		auxi=1;
		fraccion=0;
		if (expone>0)begin
			for(int j=(22-expone);j>=0;j--)begin
				peso_decimal=2**auxi;
				fraccion+=iee[j]*(1/peso_decimal);
				auxi+=1;
			end
		end else begin	
			peso_decimal=2**(-expone);
			fraccion+=1/peso_decimal;
			for(int j=(22);j>=0;j--)begin
				peso_decimal=2**-(expone-auxi);
				fraccion+=iee[j]*(1/peso_decimal);
				auxi+=1;
			end

		end
		//$display("\nFraccion = %f",fraccion);
		entero+=fraccion;
		if(iee[31])entero=-entero;
		
		//$display("\nSALIDA = %f",entero);
		end else entero=0;
		return entero;
	endfunction


