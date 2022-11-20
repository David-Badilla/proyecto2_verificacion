class my_env extends uvm_env;
	`uvm_component_utils(my_env);

	function new (string name = "my_env", uvm_component parent = null);
		super.new(name,parent);
	endfunction
	
	my_agente a0;
	my_scoreboard sb0;
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		a0 = my_agente::type_id::create("a0",this);
		sb0 = my_scoreboard::type_id::create("sb0",this);
	endfunction

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		//Conexion de los puertos de analisis
		a0.m0.mon_analysis_port.connect(sb0.m_analysis_imp);
	endfunction 

endclass
