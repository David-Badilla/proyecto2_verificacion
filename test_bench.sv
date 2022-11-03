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
			fraccion+=(1/peso_decimal) ;
			for(int j=(22);j>=0;j--)begin
				peso_decimal=2**-(expone-auxi);
				fraccion+=iee[j]*((1/(peso_decimal) ));
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


int parte_entera;
	int aux;
	//int dec[$];
	bit [31:0] temporal;
	bit [25:0] mantisa;
	int contador;
	bit [7:0] exponente;
	int exp;
	bit empezar;
	bit signo;
	bit [34:0]IEEE;
	int in;
	bit arreglo [];
	
function [34:0]Int_IEEE(real num); //CONVIERTE UN NUMERO A FORMATO IEEE754
		//$display("RECIBIDO: %f",num);
	if (num!=0)begin
		if(num<0)begin //Revisa signo
			signo=1;
			num=-num;
		end else signo=0;

		parte_entera= $rtoi(num);//trunca la parte entera sin redondear
		num = num-parte_entera; //deja solo la parte decimal para iniciar algorimo
		if (num<0)num=-num; //Convierte siempre el numero a positivo
	
		in=0;
		arreglo=new[100];//Genera arreglo para almacenar los bits de la parte decimal
		foreach(arreglo[i]) arreglo[i]=0;
		while(num!=0)begin //Algoritmo conversor decimal binario
			
			num=num*2;
			aux= $rtoi(num);
			
			if (aux==1) num=num-aux;//resta parte entera
			arreglo[in]=aux;
			//$display("DEC[%g] %g  aux %g",in,dec[0],aux);
			in+=1;
			if (num<0)num=-num;
		end
	//foreach(arreglo[i])begin	
	///	$display("arreglo[%g] : %g ",i,arreglo[i]);
	//end
	temporal=parte_entera;
	exp=0;
	empezar=0;
	//$display("PARTE ENTERA: %g",parte_entera);
	if(parte_entera!=0)begin	
		for (int i=31;i>=0;i--)begin//Cuenta la cantidad de bits que necesita la parte entera para calcular el exponente
			if(temporal[i]==1) empezar=1;
			if(empezar==1) exp+=1;
		end
	end
	
	
	contador=0;
	if (parte_entera!=0)begin
		while(temporal[31]!=1)begin //algoritmo para acomodar la parte entera y la decimal juntas hasta que haya un 1 en el bit 24
			temporal = temporal << 1;
			temporal[0]=arreglo[contador];
			contador+=1;
		end
	end else begin	
		exp=0;
		empezar=0;
		while(temporal[31]!=1)begin //algoritmo para acomodar la parte entera y la decimal juntas hasta que haya un 1 en el bit 24
			temporal = temporal << 1;
			temporal[0]=arreglo[contador];
			if (arreglo[contador]==1)empezar=1;
			if(!empezar) exp-=1;			
			contador+=1;
		end
		//$display("TEMPORAL: %b",temporal);
	end

	exp-=1;//resta 1 para no contar el primer bit
	//$display("\nExponente = %d",exp);
	exponente=exp+127; //Suma 127 de acuerdo al formato
	mantisa=temporal[30:5]; //Iguala mantisa de 23 bits con temporal de 24 bits para eliminar el primer bit como dice el formato
	//$display("Exponente:%g temporal: %b \nMantisa: %b",exponente-127,temporal,mantisa);
	IEEE={signo,exponente,mantisa};//Concatena todo
	//$display("\nFORMATO IEE = %h \n",IEEE);
	
	end else begin

	IEEE=0;
	end

	return IEEE;

	endfunction
