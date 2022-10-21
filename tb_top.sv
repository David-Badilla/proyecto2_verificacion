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
		r_mode=0;
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
	real valorX;
	real valorY;
	real b;
	bit [31:0] c;
	bit [31:0] esperadoIEEE;
	real esperadoreal;
	
	always@(posedge clk)begin
	for (int i=0;i<20;i++) begin
		a=$urandom_range(50000,1000);;//NUMEROS MENORES QUE 2147483648
		a=a/1000;
		if($urandom_range(1)==1) a=-a;		

		b=$urandom_range(50000,1000);//
		b=b/1000;
		if($urandom_range(1)==1) b=-b;		
		
		fp_X = int2IEE754(a); //Le mete valor
		valorX = IEE7542int(fp_X); // VALOR REAL ENTRANTE AL MULTIPLICADOR ya que al convertir a punto flotante es posible que algunos decimales se pierdan por eso esta funcion devuelve en decimal lo que se convirtió para saber exactamente lo que entró en X
		 
		$display("FPX: 0x%h, a=%f , Valor real al convertir IEEE754 X: %f",fp_X,a,valorX);
		fp_Y =int2IEE754(b);
		valorY = IEE7542int(fp_Y); 

		$display("FPY: 0x%h, valor=%f Valor real al convertir IEEE754 Y: %f\n",fp_Y,b,valorY);
		esperadoIEEE=int2IEE754(valorX*valorY); //Convierte los valores en IEEE para saber que decimales se pierden al convertir la mantisa
		esperadoreal=IEE7542int(esperadoIEEE); // Regresa a formato decimal para saber en verdad que se debe ver en la salida
		//$display("RESULTADO ESPERADO: %f ,IEEE %h",esperadoreal,esperadoIEEE);
		#100
		salida=IEE7542int(fp_Z);
		//$display("	RESULTADO SALIDA fp_Z: 0x%h  decimal:%f ",fp_Z,salida,);
		

		//CHECKER
		if(esperadoreal==salida) $display("--------PASS: los resultados coinciden Esperado:normal %f %f Recibido:%f--------------\n\n\n",valorX*valorY,esperadoreal,salida);
		else  $display("*******ERROR: los resultados NO coinciden Esperado:normal %f %f Recibido:%f**************",valorX*valorY,esperadoreal,salida);
		
		
		if (ovrf)$display("**OVERFLOW**");
		if (udrf)$display("**UNDERFLOW**");
		$display("\n\n\n\n");

	end


		
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
	mantisa=temporal[30:8]; //Iguala mantisa de 23 bits con temporal de 24 bits para eliminar el primer bit como dice el formato
	//$display("Exponente:%g temporal: %b \nMantisa: %b",exponente-127,temporal,mantisa);
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












