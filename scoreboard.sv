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
	real a=0,b=0;
	bit [34:0] c;
	bit [31:0] esperadoIEEE;
	real esperadoreal;
	bit Round_bit, guard, sticky;

	virtual function write(my_seq_item item);
		`uvm_info("\n*****SCB-write", $sformatf ("Dato recibido: X=%f , Y=%f, Resultado = %f",item.X,item.Y,item.Z),UVM_MEDIUM)
		
			
		

		//La salida le toma un ciclo de reloj por lo tanto hay que leerlo en la siguiente entrada de item
		if (IEEE_Int(item.Z)==esperadoreal)begin
			`uvm_info("*SCB*", $sformatf ("PASS! Match  X=%f, Y=%f, Teorico=%f out = %f",a,b,salidateorica,item.Z),UVM_LOW)
		end else begin
			`uvm_error("*SCB*", $sformatf ("ERROR! a=%f, b=%f, Teorico=%f out = %f , Round=%b , Guard=%b, sticky=%b",a,b,salidateorica,item.Z , Round_bit,guard,sticky))
		end
		

		a=IEEE_Int(item.X);
		$display("		%b  = %f",Int_IEEE(29),IEEE_Int(32'ha3623956));
		b=IEEE_Int(item.Y);
		
		c = Int_IEEE(a*b) ;//Convierte los valores en IEEE para saber que decimales se pierden al convertir la mantisa
		Round_bit = c[2];
		guard = c[1];
		sticky = c[0];
		esperadoIEEE = c[34:3];
		esperadoreal=IEEE_Int(esperadoIEEE); // Regresa a formato decimal para saber en verdad que se debe ver en la salida

	endfunction

	
endclass







