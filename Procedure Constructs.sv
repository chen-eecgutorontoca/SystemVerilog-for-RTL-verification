`timescale 1ns/1ps

module tb();
    
    reg clk;				//clock and any input should be declared as reg 
    reg sig_clk;
    
    initial begin			//define the initial value of the clock, which is 0
    clk = 1'b0;				//this step is curcial, otherwise system will have undefined values
    sig_clk = 1'b0;
    end
    
    always #10 clk = ~clk;      //generate default clk at 50Mhz
    
  	//calculate Ton and Toff
    task calculate(input real period, input real duty_cycle, output real ton, output real toff);
        ton = period * duty_cycle; 					
        toff = period - ton;            			
    endtask   
    
  	//generate the actual signal clk
    task wavegen(input real ton, input real toff);
      @(posedge clk);				//synchronize with system clock at the first rising edge
      while(1)begin					//infinite loop
        sig_clk = 1'b1;				
        #ton;						//signal clock will stay at one for Ton time
        sig_clk = ~sig_clk;
        #toff;						//signal clock will be flipped to zero for Toff time
        end
    endtask         
    
    real period;					//real means the signal can be a decimal number
    real duty_cycle;			
    real ton;						//on-time
    real toff;						//off-time
   
  	//call tasks      
    initial begin   
      calculate(40, 0.4, ton, toff); //Here we create a clock signal with frequency of 25MHz and duty cycle of 40%
      wavegen(ton, toff);
    end
    
    initial begin          //display all waveforms
        $dumpfile("dump.vcd");
        $dumpvars;
    end
    
    initial begin       
        #200; 			 //run for 200ns
        $finish();       //stop the program
    end
        
endmodule