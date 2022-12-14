class my_driver extends uvm_driver #(my_seq_item);
  `uvm_component_utils(my_driver)
  function new (string name = "my_driver", uvm_component parent= null);
    super.new(name,parent);
  endfunction

  virtual dut_if vif;

  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual dut_if)::get(this,"","dut_if",vif))
       `uvm_fatal("DRV", "Could not get vif");
  endfunction


  virtual task run_phase (uvm_phase phase);
    super.run_phase(phase);

    forever begin 
		my_seq_item m_item;
		
		`uvm_info("DRV",$sformatf("Esperando item de sequencer"),UVM_LOW)
		
		seq_item_port.get_next_item(m_item);
		`uvm_info("DRV",$sformatf("Item recibido\n"),UVM_MEDIUM)
		m_item.convert2string();
		//Funcion manejo retardo
		vif.reset=1;
		retraso_item(m_item);

		//Funcion colocar datos en la entrada
		drive_item(m_item);
			
		seq_item_port.item_done();
    end    
	endtask
	
	//Funcion de manejo de retraso simulado
	int tiempo;
	virtual task retraso_item(my_seq_item m_item);
		tiempo=0;
		while(tiempo!=m_item.retraso) begin
			#1;
			tiempo+=1;
		end
		
	endtask

	virtual task drive_item(my_seq_item m_item); //task por que necesita consumir tiempo
		vif.reset=0; //Se usa el reset como activador de lectura para el monitor
		@(vif.cb);
		//Conexiones con los inputs del DUT
		vif.cb.r_mode <= m_item.r_mode;
		vif.cb.fp_X <= m_item.X;
		vif.cb.fp_Y <= m_item.Y;


	endtask
endclass
















