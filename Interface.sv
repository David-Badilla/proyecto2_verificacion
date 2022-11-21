interface dut_if (input bit clk);
	//Inputs	
	logic reset;
	logic [2:0] r_mode;
	logic [31:0] fp_X, fp_Y;

	// Outputs
	logic [31:0] fp_Z;
	logic ovrf;
	logic udrf;
	logic NAN;

	clocking cb @(posedge clk); //Tiempo de muestreo 
		default input #1step output #3ns;
			input fp_Z;
			input ovrf;
			input udrf;
			input NAN;

			output r_mode;
			output fp_X;
			output fp_Y;

	endclocking
endinterface
