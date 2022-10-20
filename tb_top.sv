//`timescale 1ns / 1ps

`include "multiplicador_32_bits_FP_IEEE.sv"

module tb_top;

	// Inputs
	reg clk;
	reg [2:0] r_mode;
	reg [31:0] fp_X, fp_Y;
	

	// Outputs
	reg [31:0] fp_Z;
	wire ovrf;
	wire udrf;
	//$dumpfile("tb_top.vcd")
	//$dumpvars(0,test); 
	// Instantiate the Unit Under Test (UUT)
       top DUT(
		.clk(clk),
		.r_mode(r_mode),
		.fp_X(fp_X), 
		.fp_Y(fp_Y),
		.fp_Z(fp_Z),
		.ovrf(ovrf), 
		.udrf(udrf)
		);
	
	initial begin
		clk=0;
		r_mode=1;
		fp_X=0;
		fp_Y=0;
				
	end
	//r_mode==0  round to nearest, ties to even
	//r_mode==1  round to zero
	//r_mode==2  round down
	//r_mode==3  round up
	//r_mode==4  round to nearest, ties to max magnitude
	always #2 clk=~clk;
	real salida;
	real a;
	real b;
	bit [31:0] c;
	real esperado;
	always@(posedge clk)begin

		a=-8010.2121;//NUMEROS MENORES QUE 2147483648
		b=870.2311;//

		
		fp_X = int2IEE754(a); //Le mete valor 
		$display("FPX: 0x%h, valor=%f",fp_X,a);
		fp_Y =int2IEE754(b);
		$display("FPY: 0x%h, valor=%f\n",fp_Y,b);
		esperado=a*b;
		$display("\nRESULTADO ESPERADO: %f , %h conv iee dec %f",esperado,int2IEE754(esperado), IEE7542int(int2IEE754(esperado)));
		#100
		salida=IEE7542int(fp_Z);
		$display("	RESULTADO fp_Z: 0x%h  decimal:%f  \n\n",fp_Z,salida,);
		if (ovrf)$display("**OVERFLOW**");
		if (udrf)$display("**UNDERFLOW**");
		//$display("Entradas x=%g y=%g == %g",fp_X,fp_Y,fp_Z);
		$finish;
	end

















// -----------------EMPIEZAN FUNCIONES------------------------------------
	int parte_entera;
	int aux;
	//int dec[$];
	bit [31:0] temporal;
	bit [22:0] mantisa;
	int contador;
	bit [7:0] exponente;
	int exp;
	bit empezar;
	bit signo;
	bit [31:0]IEEE;
	int in;
	bit arreglo [];
	function [31:0]int2IEE754(real num); //CONVIERTE UN NUMERO A FORMATO IEEE754
		//$display("RECIBIDO: %f",num);
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
		//$display("arreglo[%g] : %g ",i,arreglo[i]);
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
			//$display("DEC[CONT]:",dec[contador]);
			if (arreglo[contador]==1)empezar=1;
			if(!empezar) exp-=1;			
			contador+=1;
		
			

		end
		//$display("TEMPORAL: %b",temporal);
	end

	exp-=1;//resta 1 para no contar el primer bit
	//$display("\nExponente = %d",exp);
	exponente=exp+127; //Suma 127 de acuerdo al formato
	mantisa=temporal[30:8]; //Iguala mantisa de 23 bits con temporal de 24 bits para eliminar el primer bit como dice el formato
	
	IEEE={signo,exponente,mantisa};//Concatena todo
	//$display("\nFORMATO IEE = %h \n",IEEE);
	return IEEE;

	endfunction


	real entero;
	bit [31:0]par_ent;
	int expone;
	int auxi;
	real fraccion;
	real peso_decimal;
	function real IEE7542int(bit [31:0] iee); //funcion para convertir del formato IE745 a decimal
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
		return entero;
	endfunction

endmodule












