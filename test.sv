
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

		//uvm_config_db #(bit[4-1:0])::set(this,"*","ref_patron",patron);

		seq = my_sequence::type_id::create("seq");
		
	endfunction 
	
	virtual task run_phase(uvm_phase phase);
		
		phase.raise_objection(this);
		//apply_reset();
		
		seq.randomize();
		seq.start(e0.a0.s0);
		#200;
		phase.drop_objection(this);

	endtask



	virtual task apply_reset();
		//vif.reset <= 1;
		repeat(5) @(posedge vif.clk);
		//vif.reset <=0;
		repeat(10) @(posedge vif.clk);
	endtask


endclass

class test_multi extends base_test;
	`uvm_component_utils(test_multi);
	function new (string name = "test_multi", uvm_component parent= null);
		super.new(name,parent);
	endfunction
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		seq.randomize() with {num inside {[300:500]};};
	endfunction

endclass





