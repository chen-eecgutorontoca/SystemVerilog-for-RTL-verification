`timescale 1ns/1ns

class generator;
  rand bit [3:0] a;						
  rand bit [3:0] b;
  bit [3:0] y;
  
  constraint data{a > 13; }				
endclass

/*********************************************************************************/
class generator1;       

    rand bit [7:0] x,y,z;
    constraint data {x inside {[1:255]}; y inside {[1:255]}; z inside {[1:255]}; }  

endclass
/*********************************************************************************/


/*********************************************************************************/

//create 20 random test cases for x, y, z in range of 0 to 50
class generator2;
    randc bit [7:0] x;
    randc bit [7:0] y;
    randc bit [7:0] z;
    
    constraint data {x inside {[0:50]};         //set constraint between 0 to 50
                    y inside {[0:50]};
                    z inside {[0:50]};};		// ← still needs this semicolon
    
    function void display();                    //display result of xyz
        $display("value of x:%0d  y:%0d  z:%0d at time = %0t",x,y,z,$realtime);
    endfunction
    
endclass
/********************************************************************************/


/**********************************************************************************/
class generator_e;
  rand int a;
  rand int b;
  					
  constraint data_a {a > 3; a < 7; };	// // a ∈ {4,5,6}
  constraint data_b {b == 3; }	;		//forces b to be 3 at all time
  
  constraint data_1 { a > 3; a < 7; b >= 0; };		//3<a<7 && b>=0
  constraint data_2 { a inside {[0:8], [10:11], 15};	
                     b inside {[3:11]};		//3<=b<=11
                  };
  constraint data_3 { !(a inside {[3:7]}); 		//forbids a from 3 to 7
                     !(b inside {[5:9]});		//forbids b from 5…9. 
                    };
endclass
/**********************************************************************************/


/*********************************************************************************/
class generator_ex;
  
  rand bit [4:0] a;
  rand bit [5:0] b;
    
  extern constraint data;        //write constraint outside of class
  extern function void display;		//write function outside of class
 
endclass
   
constraint generator_ex :: data{            //constraint inside scope of generator class
        a inside {[0:8]};
        b inside {[0:5]};
        };
    
function void generator_ex :: display();
  $display("value of a: %0d, value of b: %0d", a, b);
endfunction

/*******************************************************************************/

    
/*******************************************************************************/
class generator_p;
  rand bit [3:0] a, b;
  bit [3:0] y;
  
  int min, max;
  
  function void set_range(input int min, max);
    this.min = min;
    this.max = max;
  endfunction
  
  constraint data{a inside {[min:max]};
                  b inside {[min:max]};
                 };
  
  function void display();
    $display("value of a: %0d, value of b: %0d", a, b);
  endfunction
  
endclass
/*****************************************************************************/
    

/*****************************************************************************/
class temp;
  rand bit wr;
  rand bit [1:0] sel;
  
  constraint wr_const{ wr dist{0:=10, 1:=90}; };
  constraint wr_const_w{ wr dist{0:/10, 1:/90}; };			
  constraint sel_const{ sel dist{0:=10, [1:3]:=60}; }; //equivalent as {0:=10, 1:=60, 2:=60, 3:=60}
  constraint sel_const_w{ sel dist{0:/10, [1:3]:/60}; };	//equivalent as {0:/10, 1:/20, 2:/20, 3:/20}
endclass
/****************************************************************************/
    
class first;
  rand bit wr;
  rand bit rd;
  bit rst;
  bit ce;

  
  constraint cntrl{wr dist{0:=30, 1:=70};
                   rd dist{0:/30, 1:/70};
                  };
  extern constraint control_rst_ce;
  extern constraint wr_ce_C;

endclass

/*********************************************************************************/
    
constraint first::control_rst_ce{(rst == 0) -> (ce == 1);};		
constraint first::wr_ce_C{(wr == 1) <-> (ce == 1); };
    
/********************************************************************************/
    
class gen;
  rand bit [3:0] addr;
  rand bit wr;
  
  constraint wrctl{wr dist {1:=50, 0:=50};}        //1:1 assignment for wr signal
  
  constraint data{                                //when wr high, addr should be 0-7, otherwise 8-15
    if(wr){
       addr inside {[0:7]};
    }else{
        addr inside {[8:15]};
     }
      };
  
endclass
    
    
module tb;
  generator g;
  int i = 0;
  
  initial begin
    g = new();
    for(i = 0; i<10; i++)begin
      g.randomize();
      #10;				//delay for 10ns for each tests generated
      $display("Value of a: %0d, value of b: %0d, at time %t", g.a, g.b, $time);
    end
  end

/********************************************************************************/
  
  generator1 g1;
  int j = 0;
    
  initial begin
    g1 = new();
    for(int j = 0 ; j<10; j++)begin              //generate 20 random values for x,y,z
      assert(g1.randomize())else begin                        //display failure message
         $display("randomization failed at %0t", $realtime);
      end
      $display("x: %0d, y: %0d, z:%0d at time = %0t",g1.x, g1.y, g1.z, $realtime);    
     end
     $display("20 random values generation finished at time = %0t", $realtime);
      #20;
     $finish;
   end
 
/********************************************************************************/
  
  
  	generator2 g2;
  	int k = 0;
  
    initial begin
    g2 = new();
    #20
      for(int k = 0; k < 10; k++)begin                
      	if(!g2.randomize())begin
            $display("Randomization Failed at time = %0t",$realtime);
        end else begin
             g2.display();
        end
       end
    $finish;  
    end
  
/*****************************************************************************/
 
  	generator_e ge;
  	int w = 0;
  
  	initial begin
      ge = new();
      for(int w = 0; w < 5; w++)begin
        if(!ge.randomize())begin
            $display("Randomization Failed at time = %0t",$realtime);
        end else begin
          $display("value of a: %0d, value of b: %d", ge.a, ge.b);  
        end	
      end
    end
  
  
/*******************************************************************************/
  
  	generator_ex gex;
  	int x = 0;
  
  	initial begin
      gex = new();
      for(int x = 0; x < 10; x++)begin
        assert(gex.randomize())else begin                        //display failure message
         $display("randomization failed at %0t", $realtime);
        end
        gex.display();
      end
    end
/********************************************************************************/
  
 	generator_p gp;
  	int y = 0;
  
  	initial begin
      gp = new();
      gp.set_range(3,8);
      for(int y = 0; y < 10; y++)begin
        gp.randomize();
        gp.display();
      end
    end
/*******************************************************************************/
  
   first f;
   int a = 0;
  
  	initial begin
      f = new();
      for(int a = 0; a < 20; a++)begin
        assert(f.randomize())else begin                        //display failure message
         $display("randomization failed at %0t", $realtime);
        end
        $display("wr: %0d, rd: %0d", f.wr, f.rd);
      end
    end
 

 /****************************************************************************/
  
  gen g_e_n;
  int b = 0;
  
  initial begin
    g_e_n = new();
    $display("data constraint mode : %0d", g_e_n.data.constraint_mode());	//check constraint ON or OFF
    g_e_n.data.constraint_mode(0);				//turn constraints off
    $display("data constraint mode : %0d", g_e_n.data.constraint_mode());
    for(int b = 0; b < 10; b++)begin
      assert(g_e_n.randomize())else begin
                $display("Randomization Failed at time=%0t",$time);
      end $display("wr=%0d, addr=%0d at time=%0t",g_e_n.wr,g_e_n.addr,$time);
        end
        $finish;
   end
  
  
endmodule