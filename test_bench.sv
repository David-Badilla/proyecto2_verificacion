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






bit [7:0] exp1,exp2;
bit [46:0] mant1;
bit [23:0] mant2;
bit [25:0] mantnueva;
bit sig;
bit [47:0] resultado;
int espacios;
int cont;
bit ini;
bit [7:0] expfinal;
int of1,of2,aux1,aux2,corte,u,expfi;
bit [34:0]res;
function [34:0] Multi(bit [31:0]num1,bit [31:0] num2);
	sig=num1[31]^num2[31];
	exp1=num1[30:23];
	exp2=num2[30:23];
	
	mant1={1'b1,num1[22:0]};
	mant2={1'b1,num2[22:0]};
	if ((num1[22:0]==0 & exp1==0)|(num2[22:0]==0 & exp2==0)) return 0; 
	aux1=0;
	if (mant1!=0)begin
		while(mant1[0]!=1) begin
			mant1=mant1>>1;
			aux1+=1;
		end
	end
	aux1=23-aux1;
	aux2=0;
	//$display("		aux1= %g",aux1);
	if (mant2!=0)begin
		while(mant2[0]!=1) begin
			mant2=mant2>>1;
			aux2+=1;
		end
	end
	
	aux2=23-aux2;
	//$display("		aux2= %g",aux2);
	corte=aux1+aux2;
	resultado = 0;
	espacios=0;
	
	//$display("mant1 %b",mant1);
	//$display("mant2 %b",mant2);
	for (int i=0;i<=24;i++)begin	
		if(mant2[0]==0)begin 
			espacios+=1;
			mant2=mant2>>1;
			//$display("mant2:%b",mant2);	
			//$display("		Cero");
		end else begin
			//$display("Res: %b \n+    %b\n",resultado,mant1<<espacios);
			resultado+=mant1<<espacios;
			mant2=mant2>>1;
			//$display("mant2:%b\n",mant2);
			espacios+=1;
		end
	end
	//$display("\n		RESULTADO : %b\n",resultado); 
	cont=0;
	ini=0;
	//if(resultado[45:32]!=0)begin
//	$display("	resultado[45:32]!=0 : %b",resultado[45:32]);
	for (int j=47;j>=corte;j--)begin
		if (resultado[j]==1)ini=1;
		if (ini) cont+=1;
	end
	cont-=1;
	if(ini==0) begin	
		cont=0;
		for(int k=corte-1;k>=0;k--)begin
			if(resultado[k]!=1) cont+=1;
			else break;
		end
		//cont-=1;
		cont=-cont;

	end

	//$display("		EXP: %g\n",cont);

	
	of1=exp1-127;
	of2=exp2-127;
	expfi=of1+of2+cont+127;
	//$display("		EXP1: %g  EXP2: %g\n",of1,of2);
	//$display("		EXPfinal: %b  %g\n",expfi,expfi);
	of1=corte-1+cont;
	//$display("		ofset: %g",of1);
	of2=31+cont-8;
	//if (cont!=0)begin
		
		mantnueva=0;
		
		if (expfi>=255)begin
			$display("		OVRFLOW: %g\n",expfi);
			return {sig,8'b11111111,mantnueva};
		end
		if (expfi<0) begin
			$display("		UNDRFLOW: %g\n",expfi);
			return {sig,8'b00000000,mantnueva};

		end

		u=47;
		while(mantnueva[25]!=1)begin
			mantnueva=mantnueva<<1;
			mantnueva[0]=resultado[u];
			u-=1;
		end
		mantnueva=mantnueva<<1;
		mantnueva[0]=resultado[u];


	expfinal=expfi;
	res={sig,expfinal,mantnueva};
	$display ("		salida: %b , rbit: %b , guard: %b , stic: %b \nhex: %h	",res[34:3],res[2],res[1],res[0],res[34:3]);
	return res;

endfunction 


