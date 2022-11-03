class my_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(my_scoreboard) //component
	function new (string name = "my_scoreboard", uvm_component parent= null);
		super.new(name,parent);
	endfunction

	uvm_analysis_imp #(my_seq_item, my_scoreboard) m_analysis_imp;

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		m_analysis_imp = new("m_analysis_imp",this);
	endfunction 
	
	real salidateorica=0;
	real a=0,b=0,z=0;
	bit [34:0] c;
	bit [31:0] esperadoIEEE;
	real esperadoreal;
	bit Round_bit, guard, sticky;

	virtual function write(my_seq_item item);
		`uvm_info("\n		SCB-write", $sformatf ("Dato recibido: X=%h , Y=%h, Resultado = %h",item.X,item.Y,item.Z),UVM_MEDIUM)
		
			
		

		//La salida le toma un ciclo de reloj por lo tanto hay que leerlo en la siguiente entrada de item
	
		a=IEEE_Int(item.X);
		//$display(" A=%f = %h",a, item.X);
		//$display("	PRUEBA		%b  = %f",Int_IEEE(-29),IEEE_Int(32'b01000001111010000000000000000000000));
		b=IEEE_Int(item.Y);
		//$display(" B=%f = %h",b,item.Y);
		esperadoreal=a*b;

		c=Int_IEEE(esperadoreal);
		esperadoIEEE=c[34:3];
		
		Round_bit = c[2];
		guard = c[1];
		sticky = c[0];


		case(item.r_mode)
			//r_mode==0  round to nearest, ties to even
			//r_mode==1  round to zero
			//r_mode==2  round down
			//r_mode==3  round up
			//r_mode==4  round to nearest, ties to max magnitude
			0: begin //r_mode==0  round to nearest, ties to even
				if (Round_bit)begin	
					if(guard|sticky == 1) esperadoIEEE+=1'b1; 
					else if(esperadoIEEE[0]==1) esperadoIEEE+=1'b1; 
				end
			end

			1: begin //r_mode==1  round to zero
				esperadoIEEE=esperadoIEEE;
			end

			2: begin //r_mode==2  round down
				if (esperadoIEEE[31]==1) esperadoIEEE+=1'b1; 

			end

			3: begin //r_mode==3  round up
				if (esperadoIEEE[31]==0) esperadoIEEE+=1'b1; 
			end

			4: begin //r_mode==4  round to nearest, ties to max magnitude
				if (Round_bit) esperadoIEEE+=1'b1; 
			end
	
			default esperadoIEEE=esperadoIEEE; 
		endcase












		salidateorica=IEEE_Int(esperadoIEEE);

		z=IEEE_Int(item.Z);
		$display(" Z=%f = %h",z ,item.Z);
		if (z==salidateorica)begin
			`uvm_info("*SCB*", $sformatf ("PASS! Match  X=%f, Y=%f, Teorico=%f out = %f , R_Mode = %g , R_bit %b , guard|sticky %b",a,b,salidateorica,z,item.r_mode, Round_bit,guard|sticky),UVM_LOW)
		end else begin
			`uvm_error("*SCB*", $sformatf ("ERROR! a=%f, b=%f, Teorico=%f out = %f , Round=%b , Guard=%b, sticky=%b",a,b,salidateorica,z , Round_bit,guard,sticky))
		end
		






		$display(" Esperado = %f , %h",esperadoreal,esperadoIEEE); 
		
		//c = Int_IEEE(a*b) ;//Convierte los valores en IEEE para saber que decimales se pierden al convertir la mantisa
		











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















	
endclass







