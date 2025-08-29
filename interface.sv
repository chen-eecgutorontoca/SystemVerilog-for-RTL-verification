module add(
  input [3:0] a,
  input [3:0] b,
  output [4:0] sum,
  input clk
);
  
  assign sum = a + b;
 
endmodule
         
         
interface add_if;
  logic [3:0] a;
  logic [3:0] b;
  logic [4:0] sum;
  logic clk;
endinterface


class transaction; 

	randc bit [3:0] a; 
	randc bit [3:0] b; 
  	bit [4:0] sum; 
  
  constraint data{
    a inside {[1:14]};
    b inside {[3:15]};}
  
  function transaction copy();
   copy = new();
   copy.a = this.a;
   copy.b = this.b;
   copy.sum = this.sum;
  endfunction

endclass

class error extends transaction; 
  constraint data_c {a == 0 ; b == 0;}
endclass


class generator; 
  
  transaction trans; 
  mailbox #(transaction) mbx;
  error err;
  event done; 

  function new(mailbox #(transaction) mbx); 
    this.mbx = mbx; 
    trans = new(); 
  endfunction 

/*
  task run(); 
    for(int i = 0; i<10; i++) begin 
      trans.randomize(); 
      mbx.put(trans.copy); 
      $display("[GEN] : DATA SENT TO DRIVER a: %0d  b: %0d", trans.a, trans.b); 
      #20; 
    end 
   -> done; 
  endtask 
*/
  
  task run(); 
  for(int i = 0; i<10; i++) begin 
    if ($urandom_range(0,10) == 0) begin
      err = new();
      mbx.put(err.copy);
      $display("[GEN] : Injecting ERROR transaction");
    end else begin
      trans = new();             
      assert(trans.randomize());
      mbx.put(trans.copy);
      $display("[GEN] : DATA SENT TO DRIVER a: %0d  b: %0d", trans.a, trans.b);
    end
    #20; 
  end 
 -> done; 
endtask

  
endclass 


class driver; 
  
  virtual add_if aif; 
  mailbox #(transaction) mbx; 
  transaction data; 
  event next; 

  function new(mailbox #(transaction) mbx); 
    this.mbx = mbx; 
  endfunction  

  task run(); 
    forever begin 
      mbx.get(data); 
     @(posedge aif.clk);   
      aif.a <= data.a; 
      aif.b <= data.b; 
      $display("[DRV] : Interface Trigger a: %0d  b: %0d", aif.a, aif.b); 
    end 
  endtask 

endclass 


class monitor;
  virtual add_if aif;
  mailbox #(transaction) mbx;

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction

  task run();
    transaction t;
    forever begin
      @(posedge aif.clk);
      t = new();
      t.a = aif.a;
      t.b = aif.b;
      t.sum = aif.sum;
      mbx.put(t);
      $display("[MON] : Captured from DUT a:%0d b:%0d sum:%0d", t.a, t.b, t.sum);
    end
  endtask
endclass


class scoreboard;
  mailbox #(transaction) mbx;
  int i = 0;

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction

  task run();
    transaction t;
    forever begin
      mbx.get(t);
      if (t.a == 0 && t.b == 0) begin
        if (t.sum !== 0)begin
          $display("[SCB-ERROR] DUT FAILED for error input a=0, b=0, got sum=%0d", t.sum);
          i++;
        end else begin
          $display("[SCB-ERROR] DUT correctly handled error input");
        end
      end
      else begin
        if (t.sum !== (t.a + t.b))begin
          $display("[SCB-FAIL] Expected sum=%0d, got sum=%0d", t.a+t.b, t.sum);
          i++;
       end else begin
          $display("[SCB-PASS] a=%0d b=%0d sum=%0d", t.a, t.b, t.sum);
       end
      end
    end
  endtask
  
endclass



module tb; 

 add_if aif(); 
 driver drv; 
 generator gen; 
  monitor mon;
  scoreboard sco;
  event done; 
  error er;
  mailbox #(transaction) mbx_t; 
  mailbox #(transaction) mbx_r; 
  
  add dut (aif.a, aif.b, aif.sum, aif.clk ); 

  initial begin 
    aif.clk = 0; 
  end 

  always #10 aif.clk = ~aif.clk; 

   initial begin 
     mbx_t = new(); 
     mbx_r = new();
     drv = new(mbx_t); 
     gen = new(mbx_t);     
     mon = new(mbx_r);
     sco = new(mbx_r);
     drv.aif = aif; 
     mon.aif = aif;
     er = new();
//     gen.trans.data.constraint_mode(0);
//     gen.trans = er;
     done = gen.done; 
   end 

  initial begin 
  fork 
    gen.run(); 
    drv.run(); 
    sco.run();
    mon.run();
  join_none 
    wait(done.triggered); 
    if(sco.i==0)begin
      $display("All Tests Passed!");
    end else begin
      $display("Number of tests failed: %0d", sco.i);
    end
    $finish(); 
  end 



  initial begin 
   $dumpfile("dump.vcd");  
    $dumpvars;   
  end 

   

endmodule 