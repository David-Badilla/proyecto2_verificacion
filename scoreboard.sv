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
	
	bit [34:0] c;
	bit [31:0] esperadoIEEE,temp1,temp2;
	bit Round_bit, guard, sticky, ovrfTeorico, udrfTeorico,NANteorico;
	my_seq_item scoreboard[$]; //array para controlar el scoreboard
	virtual function write(my_seq_item item);
		`uvm_info("\nSCB-write", $sformatf ("Dato recibido: X=%h , Y=%h, Resultado = %h",item.X,item.Y,item.Z),UVM_MEDIUM)

		//LLama a la funcion Multi que devuelve los 32 bits de resultado junto con otros 3 bits extras al realizar la multiplicacion
		c=Multi(item.X,item.Y);
		esperadoIEEE=c[34:3];		
		Round_bit = c[2];
		guard = c[1];
		sticky = c[0];
		udrfTeorico=0;ovrfTeorico=0;NANteorico=0;
		
		if (esperadoIEEE==32'h80000000 | esperadoIEEE==32'h00000000) udrfTeorico=1;
		//temp1=item.X; temp2=item.Y;
		//if (temp1[30:23]==0 | temp2[30:23]==0) udrfTeorico=0;  	// Revisa si el cero en la salida esta dado por alguna entrada desnormalizada ""REVISAR"""
		if (esperadoIEEE==32'hff800000 | esperadoIEEE==32'h7f800000) ovrfTeorico=1;
		if (esperadoIEEE==32'h7fc00000) NANteorico=1;



		//Empieza el case para determinar el redondeo teorico que tiene que tener esperadorIEEE para ser conparado con el valor recibido
		if (~(udrfTeorico|ovrfTeorico|NANteorico))begin //Revisa si no hay ninguna de esas tres opciones activas
			case(item.r_mode)
				0: begin //r_mode==0  round to nearest, ties to even
					if (Round_bit)begin	
						if(guard|sticky == 1) esperadoIEEE+=1'b1; 
						else if(esperadoIEEE[0]==1) esperadoIEEE+=1'b1; //revisa si es impar en ese caso le suma 1
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
		end
		//Guarda valores teoricos para usarlos en el informe CSV luego
		item.Zteorica = esperadoIEEE;
		item.Round_bit = Round_bit;
		item.guardORsticky = guard|sticky;

		
		//Se hace la comparacion entre el valor en formato IEEE recibido con el esperado calculado anteriormente
		if (item.Z==esperadoIEEE && item.udrf==udrfTeorico && item.ovrf==ovrfTeorico)begin
			`uvm_info("*SCB*", $sformatf ("PASS! Match  X=%h, Y=%h, Z=%h ,Teorico=%h, R_Mode = %g , R_bit %b , guard|sticky %b",item.X,item.Y,item.Z,item.Zteorica,item.r_mode, Round_bit,guard|sticky),UVM_LOW)
			//Guarda si fue correcto o no para el informe CSV luego
			item.pass=1;
		end else begin
			`uvm_error("*SCB*", $sformatf ("ERROR! X=%h, Y=%h, Z=%h ,Teorico=%h, R_Mode = %g , R_bit %b , Guard=%b, sticky=%b",item.X,item.Y,item.Z,item.Zteorica,item.r_mode, Round_bit,guard,sticky))
			item.pass=0;
		end
		
		//Guarda el sequence_item a una cola para ser convertida en CSV en la fase de reporte
		scoreboard.push_back(item);



	endfunction





//********************FUNCION PARA LA MULTIPLICACION DE DOS NUEMEROS 32 BITS FORMATO IEEE745********************************
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
		//Separa los numeros 
		sig=num1[31]^num2[31];	//Calcula el signo para la salida
	
		exp1=num1[30:23];
		exp2=num2[30:23];
	
		mant1={1'b1,num1[22:0]};
		mant2={1'b1,num2[22:0]};


		if ((num1[22:0]==0 & exp1==0)|(num2[22:0]==0 & exp2==0)|exp1==0|exp2==0) return {sig,8'b0,1'b0,25'b0}; //Revisa si las entradas son diferentes de 0
		if ((num1[22:0]!=0 & exp1==8'b11111111)|(num2[22:0]!=0 & exp2==8'b11111111)) return {1'b0,8'b11111111,1'b1,25'b0}; //Revisa si las entradas son NOT a NUMBER (NAN)
		//Al ser fraccionarias los ceros a la derecha se deben eliminar
		aux1=0;
		if (mant1!=0)begin
			while(mant1[0]!=1) begin
				mant1=mant1>>1;
				aux1+=1;	//calcula cuantos ceros habian
			end
		end
		aux1=23-aux1; // calcula cuantos numeros son significativos para calcular la posicion de la coma en el resultado
		//mismo paso pero con la segunda mantisa
		aux2=0;
		if (mant2!=0)begin
			while(mant2[0]!=1) begin
				mant2=mant2>>1;
				aux2+=1;
			end
		end
		
		aux2=23-aux2;

		corte=aux1+aux2; // Calcula la posicion en que debe estar la coma en el resultado


		resultado = 0;
		espacios=0;	//Variable para controlar los corrimientos

		//For para realizar la multiplicacion 
		for (int i=0;i<=24;i++)begin	
			if(mant2[0]==0)begin //Revisa si el primer bit de la mantiza 2 es cero si es se aumenta un espacio
				espacios+=1;
				mant2=mant2>>1;
			end else begin	//Si es 1 se procede a copiar la mantisa 1 con los corrimientos necesarios y se suman al resultado
				resultado+=mant1<<espacios;
				mant2=mant2>>1;
				espacios+=1;
			end
		end

		cont=0;
		ini=0;

		//Algoritmo para calcular el exponente para normalizar el resultado en base al corte donde se debe ubicar la coma
		for (int j=47;j>=corte;j--)begin //Para calcular exponentes positivos despues de la coma
			if (resultado[j]==1)ini=1; //si detecta un 1 y activa el inicio para contar
			if (ini) cont+=1;
		end
		cont-=1; 
		if(ini==0) begin //Si no se detencto ningun 1 despues de la coma inicia la cuenta negativa
			cont=0;
			for(int k=corte-1;k>=0;k--)begin
				if(resultado[k]!=1) cont+=1; //Cuenta hasta que haya un 1 
				else break;
			end
			cont=-cont; //Lo convierte en negativo

		end
		
		//Calcula el nuevo exponente
		of1=exp1-127;
		of2=exp2-127;
		expfi=of1+of2+cont+127;

		
		mantnueva=0;
		
		if (expfi>=255)begin //Revisa si el nuevo exponente se sale del maximo permitido en el estandar IEEE754
			$display("		OVRFLOW: %g\n",expfi);
			return {sig,8'b11111111,mantnueva};
		end
		if (expfi<=0) begin//Revisa si el nuevo exponente se sale del minimo permitido en el estandar IEEE754
			$display("		UNDRFLOW: %g\n",expfi);
			return {sig,8'b00000000,mantnueva};

		end


		//Coloca el resultado en una mantisa nueva de 26 bits donde 23 son la mantisa IEEE y tres son los de redondeo,guard,sticky
		u=47;
		while(mantnueva[25]!=1)begin
			mantnueva=mantnueva<<1;
			mantnueva[0]=resultado[u];
			u-=1;
		end
		mantnueva=mantnueva<<1;  //Un ultimo corrido para eliminar el primer 1 como lo dice el estandar IEEE754
		mantnueva[0]=resultado[u];


		expfinal=expfi;	
		res={sig,expfinal,mantnueva};
		$display ("		salida: %b , rbit: %b , guard: %b , stic: %b \nhex: %h	",res[34:3],res[2],res[1],res[0],res[34:3]);
		return res;

	endfunction 









//-----------------------------------Fase de reporte-------------------------------------------------------------------------
	integer f;
	int tamano_sb;
	virtual function void report_phase(uvm_phase phase);
		super.build_phase(phase);

		tamano_sb=scoreboard.size();
		//$display("\n		CANTIDAD DE TRANSACCIONES : %g",tamano_sb);
		//Crea un archivo csv para almacenar los datos importantes		
		f = $fopen("output.csv", "w");
		$fwrite(f, "	X  , 	 Y,  		Z, 	  Z teorica ,	R_mode , Round_bit, Guard|Sticky , PASS , ovrf , udrf \n");
		for (int i=0;i<tamano_sb;i++)begin
			my_seq_item item = my_seq_item::type_id::create("item");
			item=scoreboard.pop_front; //Saca el dato de la cola 
			//Escribe de manera bonita los datos en el csv
			$fwrite(f, "%h, %h, %h, %h, 	 %g, 		%b, 			%b, 			%b, 		%b, 		%b \n", 
				        item.X,
				            item.Y ,
				                item.Z ,
				                   item.Zteorica ,
				                             item.r_mode ,
				                                         item.Round_bit ,
				                                                        item.guardORsticky ,
				                                                                        item.pass ,
				                                                                                     item.ovrf ,
																												item.udrf);
		end



	endfunction 




	
endclass







