
class base_test extends uvm_test;
	`uvm_component_utils(base_test);
	function new (string name = "base_test", uvm_component parent= null);
		super.new(name,parent);
	endfunction
	my_env e0;
	virtual dut_if vif;

	my_sequence seq;

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		e0= my_env::type_id::create("e0",this);

		if(!uvm_config_db#(virtual dut_if)::get(this,"","dut_if",vif))
			`uvm_fatal("TEST", "Could not get vif")

		uvm_config_db #(virtual dut_if)::set(this,"e0.a0.*","dut_if",vif);

		seq = my_sequence::type_id::create("seq");
		
	endfunction 
	
	virtual task run_phase(uvm_phase phase);
		
		phase.raise_objection(this);
		vif.reset=0;
		
		
		seq.randomize();
		seq.start(e0.a0.s0);
		vif.reset=1;
		#4000;
		phase.drop_objection(this);

	endtask


endclass

class test_r_mode_0 extends base_test;
	`uvm_component_utils(test_r_mode_0);
	function new (string name = "test_r_mode_0", uvm_component parent= null);
		super.new(name,parent);
	endfunction
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		seq.randomize() with {num inside {[10:200]};};
		seq.round=0;
	endfunction

endclass

class test_r_mode_1 extends base_test;
	`uvm_component_utils(test_r_mode_1);
	function new (string name = "test_r_mode_1", uvm_component parent= null);
		super.new(name,parent);
	endfunction
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		seq.randomize() with {num inside {[10:200]};};
		seq.round=1;
	endfunction

endclass

class test_r_mode_2 extends base_test;
	`uvm_component_utils(test_r_mode_2);
	function new (string name = "test_r_mode_2", uvm_component parent= null);
		super.new(name,parent);
	endfunction
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		seq.randomize() with {num inside {[10:200]};};
		seq.round=2;
	endfunction

endclass

class test_r_mode_3 extends base_test;
	`uvm_component_utils(test_r_mode_3);
	function new (string name = "test_r_mode_3", uvm_component parent= null);
		super.new(name,parent);
	endfunction
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		seq.randomize() with {num inside {[10:200]};};
		seq.round=3;
	endfunction

endclass

class test_r_mode_4 extends base_test;
	`uvm_component_utils(test_r_mode_4);
	function new (string name = "test_r_mode_4", uvm_component parent= null);
		super.new(name,parent);
	endfunction
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		seq.randomize() with {num inside {[10:200]};};
		seq.round=4;
	endfunction

endclass





