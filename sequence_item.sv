class my_seq_item extends uvm_sequence_item;

	`uvm_object_utils(my_seq_item)
	rand bit[31:0] X;
	rand bit[31:0] Y;
	rand bit [2:0] r_mode;
	constraint redond {r_mode inside{[0:5]};}

	bit[31:0] Z;
	bit ovrf,udrf;

	function new (string name = "my_seq_item");
		super.new(name);
	endfunction	
	



	virtual function string convert2string(); //Se puede cambiar por macros de campo
		return $sformatf("X=%f ,In2=%f, out=%f R_mode=%g",X,Y,Z,r_mode);
	endfunction 

/*
	rand int unsigned x1;
	rand int unsigned y1;
	rand int indicex;
	rand int indicey;
	constraint inx {indicex inside{[0:7]};}
	constraint iny {indicey inside{[0:7]};}
	
	
	function void post_randomize();
		X = real'(x1) / (10**indicex); 
		
		Y = real'(x1) / (10**indicey);
		$display("			X=%f , Y=%f",X,Y);
	endfunction
*/


	
endclass
