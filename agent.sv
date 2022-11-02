 
class my_agente extends uvm_agent;
	`uvm_component_utils(my_agente);

	function new (string name = "my_agente", uvm_component parent= null);
		super.new(name,parent);
	endfunction
	
	my_driver d0;
	my_monitor m0;
	uvm_sequencer #(my_seq_item) s0;

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		s0 = uvm_sequencer #(my_seq_item)::type_id::create("s0",this);
		d0 = my_driver::type_id::create("d0",this);
		m0 = my_monitor::type_id::create("m0",this);
		
	endfunction

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		d0.seq_item_port.connect(s0.seq_item_export);
	endfunction 

endclass
