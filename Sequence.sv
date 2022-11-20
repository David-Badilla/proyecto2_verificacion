class my_sequence extends uvm_sequence;
	`uvm_object_utils(my_sequence);

	function new (string name = "my_sequence");
		super.new(name);
	endfunction
	
	rand int num;
	int round;

	constraint c1{soft num inside{[150:350]} ;}
	
	virtual task body();
	for (int i=0;i<num;i++)begin
		my_seq_item m_item = my_seq_item::type_id::create("m_item");

		start_item(m_item);
		m_item.randomize();
		m_item.r_mode=round;
		`uvm_info("SEQ",$sformatf("Generado item: %s", m_item.convert2string()), UVM_HIGH )	//Imprimir 
		finish_item(m_item);
	end
		`uvm_info("SEQ",$sformatf("Secuencia terminada total de items: %0d", num ), UVM_LOW) // Imprime cuando termina 
		//***Otra forma ***
		//m_item.randomize();
		//`uvm_do(m_item);
		

	endtask
	
	
	
endclass 
