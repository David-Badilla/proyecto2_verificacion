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

	//Variables para X
	rand bit sig;
	rand bit [7:0] ex;
	rand bit [22:0] manti;

	//Variables para Y
	rand bit sig1;
	rand bit [7:0] ex1;
	rand bit [22:0] manti1;



	//Funcion para darle valores a X Y aleatorios en formato IEEE
	function void post_randomize();
		X = {sig,ex,manti};
		Y = {sig1,ex1,manti1};
	endfunction
	


	
endclass
