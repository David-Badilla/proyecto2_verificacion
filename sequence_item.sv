class my_seq_item extends uvm_sequence_item;

	`uvm_object_utils(my_seq_item)
	//Entradas 
	bit[31:0] X;
	bit[31:0] Y;
	rand bit [2:0] r_mode;
	constraint redond {r_mode inside{[0:5]};}

	//salidas
	bit[31:0] Z;
	bit ovrf,udrf,NAN;

	//Extras para enviarlas de reporte al CSV
	bit[31:0] Zteorica;
	bit pass;
	bit Round_bit, guardORsticky;

	//Retardo
	rand int retraso;
	constraint ret {retraso inside{[0:10]};}

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

	//Probabilidades de enviar NAN o INF
	randc int proba;  	//Randc para que al menos 1 de cada 20 sea INF y NAN
	constraint pro {proba inside{[0:20]};}
	

	typedef enum {NAN1, INF, CERO, NORMAL} tipo_num;
	rand tipo_num tipo1;
	rand tipo_num tipo2;
	
	bit [30:0]sal,sal1;
	//Funcion para darle valores a X Y aleatorios en formato IEEE
	function void post_randomize();
		if (proba==5) begin		// 5% de probabilidad de que toque una operacion especial 1 de cada 20 es de fijo especial
			sal=colocar (tipo1, ex , manti);		//Puede ser NAN, INF, CERO o NORMAL de manera random
			ex=sal[30:23];	manti=sal[22:0];
	
			sal1= colocar(tipo2, ex1,manti1);
			ex1=sal1[30:23];	manti1=sal1[22:0];
		end
		

		X = {sig,ex,manti};
		Y = {sig1,ex1,manti1};
	endfunction
	
	// Funcion para colocar exponente y mantisa depenciendo del tipo de transaccion especial
	function [30:0] colocar( tipo_num prim,bit [7:0] e1, bit [22:0] mant1);
		case(prim)
			NAN1: return {8'b11111111, mant1};
			INF: return {8'b11111111, 23'b0};
			CERO: return {8'b0,23'b0};
			NORMAL: return {e1,mant1};
		endcase
	endfunction

	
endclass
