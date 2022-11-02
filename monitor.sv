class my_monitor extends uvm_monitor;
	`uvm_component_utils(my_monitor);

	function new (string name = "my_monitor", uvm_component parent= null);
		super.new(name,parent);
	endfunction

	uvm_analysis_port #(my_seq_item) mon_analysis_port;
	
	virtual dut_if vif;

	virtual function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual dut_if)::get(this,"","dut_if",vif))
			`uvm_fatal("MON", "Could not get vif")
		mon_analysis_port = new ("mon_analysis_port",this);
	endfunction

	bit a=1;
	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
        forever begin		
           @(vif.cb);
			if (a==1) begin
				my_seq_item item = my_seq_item::type_id::create("item");
				item.X = vif.fp_X;
				item.Y = vif.fp_Y;
				item.r_mode= vif.r_mode;



				item.Z = vif.cb.fp_Z;;
				item.ovrf = vif.cb.ovrf;
				item.udrf = vif.cb.udrf;

				mon_analysis_port.write(item);
				`uvm_info("MON",$sformatf("VISTO item %s",item.convert2string()),UVM_HIGH);
			end      
  
       end
        
	endtask

endclass
