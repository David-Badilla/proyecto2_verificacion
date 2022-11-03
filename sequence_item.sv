class my_seq_item extends uvm_sequence_item;

	`uvm_object_utils(my_seq_item)
	bit[31:0] X;
	bit[31:0] Y;
	rand bit [2:0] r_mode;
	constraint redond {r_mode inside{[0:5]};}

	bit[31:0] Z;
	bit[31:0] Zteorica;
	bit Round_bit, guardORsticky;
	bit pass;
	bit ovrf,udrf;

	function new (string name = "my_seq_item");
		super.new(name);
	endfunction	
	



	virtual function string convert2string(); //Se puede cambiar por macros de campo
		return $sformatf("X=%h ,Y=%h, out=%h R_mode=%g",X,Y,Z,r_mode);
	endfunction 


	rand bit sig;
	bit [7:0] ex;
	rand bit [22:0] manti;

	rand bit sig1;
	bit [7:0] ex1;
	rand int e1,e2;
	constraint en {e1 inside{[-8:8]};e2 inside{[-8:8]};}

	rand bit [22:0] manti1;
	
	function void post_randomize();
		ex=e1+127;
		//$display("		EXPONENTE: %b ,%d",ex,ex);
		ex1=e2+127;
		X = {sig,ex,manti};
		Y = {sig1,ex1,manti1};
		//$display("		GENERADO		X=%h = %f, Y=%h = %f",X,IEEE_Int(X),Y,IEEE_Int(Y));
	endfunction
	


	
endclass
