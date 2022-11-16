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
	my_seq_item scoreboard[$]; //array para controlar el scoreboard
	virtual function write(my_seq_item item);
		`uvm_info("\nSCB-write", $sformatf ("Dato recibido: X=%h , Y=%h, Resultado = %h",item.X,item.Y,item.Z),UVM_MEDIUM)
		
			
		
		//Convierte las entradas a numeros reales para multiplicarlos
		//a=IEEE_Int(item.X);
	//	b=IEEE_Int(item.Y);

//		esperadoreal=a*b; 
		//Convierte ese valor teorico a formato IEEE para hacer las comparaciones
		c=Multi(item.X,item.Y);
		esperadoIEEE=c[34:3];		
		Round_bit = c[2];
		guard = c[1];
		sticky = c[0];

		//Empieza el case para determinar el redondeo teorico que tiene que tener esperadorIEEE para ser conparado con el valor recibido
		case(item.r_mode)
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

		//Guarda valores teoricos para usarlos en el informe CSV luego
		item.Zteorica = esperadoIEEE;
		item.Round_bit = Round_bit;
		item.guardORsticky = guard|sticky;

		//Convierte los valores de salida a reales solo para informacion
		salidateorica=0;	
		z=0;
		
		//Se hace la comparacion entre el valor en formato IEEE recibido con el esperado calculado anteriormente
		if (item.Z==esperadoIEEE)begin
			`uvm_info("*SCB*", $sformatf ("PASS! Match  X=%f, Y=%f, Teorico=%f out = %f , R_Mode = %g , R_bit %b , guard|sticky %b",a,b,salidateorica,z,item.r_mode, Round_bit,guard|sticky),UVM_LOW)
			//Guarda si fue correcto o no para el informe CSV luego
			item.pass=1;
		end else begin
			`uvm_error("*SCB*", $sformatf ("ERROR! a=%f, b=%f, Teorico=%f out = %f , Round=%b , Guard=%b, sticky=%b",a,b,salidateorica,z , Round_bit,guard,sticky))
			item.pass=0;
		end
		
		//Guarda el sequence_item a una cola para ser convertida en CSV en la fase de reporte
		scoreboard.push_back(item);



	endfunction




	integer f;
	int tamano_sb;

	bit [31:0] mul,mul2;
	virtual function void report_phase(uvm_phase phase);
		super.build_phase(phase);
		//foreach(scoreboard[i]) $display (scoreboard[i]);


		tamano_sb=scoreboard.size();
		$display("\n		CANTIDAD DE TRANSACCIONES : %g",tamano_sb);
		f = $fopen("output.csv", "w");
		$fwrite(f, "	X  , 	 Y,  		Z, 	  Z teorica ,	R_mode , Round_bit, Guard|Sticky , PASS , ovrf , udrf \n");
		for (int i=0;i<tamano_sb;i++)begin
			my_seq_item item = my_seq_item::type_id::create("item");
			item=scoreboard.pop_front;
			//Escribe de manera bonita los datos
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







