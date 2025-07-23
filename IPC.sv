`timescale 1ns/1ns

module tb;
  event a;
  
  initial begin
    #10;
    ->a;			//trigger event a
  end
  
  initial begin
 //   @(a);						//wait for event a to trigger
    wait(a.triggered);
    $display("Event a recieved at time %0t", $time);
  end
  
endmodule 

module tb;
  
  event a1, a2;
  
  initial begin
    #10;
    ->a1;
    ->a2;
  end
  
  initial begin
    @(a1);
    $display("event a1 triggered at time: %0t", $time);
    wait(a2.triggered);
    $display("event a2 triggered at time: %0t", $time);
  end
  
endmodule


//Not sychronized
module tb;
  
  int data1;
  int data2;
  event done;
  int i = 0;
  
  initial begin
    for(int i=0; i<10; i++)begin
      data1 = $urandom();
      $display("Data GEN: %0d", data1);
      #10;
    end
    ->done;
  end
  
  initial begin
    forever begin
      #10;
      data2 = data1;
      $display("Data RCVD: %0d", data2);
    end
  end
  
  initial begin
    wait(done.triggered);
    $finish;
  end
  
endmodule


module tb; 

  int i =0; 
  bit [7:0] data1,data2; 
  event done; 
  event next; 

   
  task generator();    
   for(i = 0; i<10; i++) begin   
      data1 = $urandom(); 
      $display("Data Sent : %0d", data1); 
     #10;      
     wait(next.triggered);
    end 
    
   -> done;  
  endtask 

   
  task receiver(); 
     forever begin 
       #10; 
      data2 = data1; 
      $display("Data RCVD : %0d",data2); 
      ->next;  
    end 
  endtask 

  task wait_event(); 
     wait(done.triggered); 
   	 $display("Completed Sending all Stimulus"); 
     $finish(); 
  endtask 

   
 initial begin 
    fork 
      generator(); 
      receiver(); 
      wait_event(); 
    join 
  end  
  
endmodule



module tb; 

      task first(); 
        $display("Task 1 Started at %0t",$time); 
        #20;       
        $display("Task 1 Completed at %0t",$time);      

      endtask 

    task second(); 
      $display("Task 2 Started at %0t",$time); 
      #30;       
     $display("Task 2 Completed at %0t",$time);      
    endtask 

    task third(); 
      $display("Reached next to Join at %0t",$time);      
    endtask 

 

  initial begin                                                              
    fork 
      first();     //started at 0, completed at 20 
      second();   //started at 0, completed at 30 
    join                                      
      third();   //Reached next to join at 30 
  end
    
endmodule



class first;  
  rand int data; 
  constraint data_c {data < 10; data > 0;}
endclass
 
  
class second;  
  rand int data;  
  constraint data_c {data > 10; data < 20;}  
endclass
 
 
class third;
  rand int data;
endclass

class forth;
  rand int data;
endclass

class main;
  
  semaphore sem;
  
  first f;
  second s;
  third t;
  forth h;
  
   int data;
   int i = 0;
   int j = 0;
   int k = 0;
   int w = 0;
    
  task send_first();    
    sem.get(2);    
    for(i = 0; i<10; i++) begin
      f.randomize();
      data = f.data;
      $display("First access Semaphore and Data sent : %0d at at time %t", f.data, $time);
      #10;
    end         
    sem.put(2);   
    $display("Semaphore Unoccupied");
  endtask
  
  
  task send_second();
    sem.get(1);   
    for(j = 0; j<10; j++) begin   
      s.randomize();
      data = s.data;
      $display("Second access Semaphore and Data sent at time %t : %0d", s.data, $time);
      #10;
    end      
    sem.put(1);
    $display("Semaphore Unoccupied");   
  endtask
  
  task send_third();
    sem.get(1);   
    for(k = 0; k<10; k++) begin   
      t.randomize();
      data = t.data;
      $display("Third access Semaphore and Data sent at time %t : %0d", t.data, $time);
      #10;
    end      
    sem.put(1);
    $display("Semaphore Unoccupied");   
  endtask
  
  task send_forth();
    sem.get(1);   
    for(w = 0; w<10; w++) begin   
      h.randomize();
      data = h.data;
      $display("Forth access Semaphore and Data sent at time %t : %0d", h.data, $time);
      #10;
    end      
    sem.put(1);
    $display("Semaphore Unoccupied");   
  endtask
  
  
  
  task run();
    sem = new(2);
    f = new();
    s = new();
    t = new();
    h = new();
  
   fork
     send_first();    
     send_second();
     send_third();
     send_forth();
   join
  endtask
  
  
endclass
 
module tb;
  
  main m;
  
  initial begin
    m = new();
    m.run(); 
  end
  
  initial begin
    #250;
    $finish();
  end
  
endmodule




class generator;
  int data = 12;
  
  mailbox mbx;
  
  task run();
    mbx.put(data);
    $display("[GEN]: Sent Data %0d", data);
  endtask
  
endclass


class driver;
  int datac = 0;
  
  mailbox mbx;
  
  task run();
    mbx.get(datac);
    $display("[DRV]: Rcvd Data: %0d", datac);
  endtask
  
endclass

module tb;
  generator g;
  driver d;
  mailbox mbx;
  
  initial begin
    g = new();
    d = new();
    mbx = new();
    g.mbx = mbx;
    d.mbx = mbx;
    g.run();
    d.run();
  end
endmodule


//send transaction data between driver and generator
class transaction;  
   
    bit [7:0] addr = 8'h12;
    bit [3:0] data = 4'h4;  
    bit we = 1'b1;  
    bit rst = 1'b0;  
   
endclass  
  
class generator;  
    transaction t;  //create instance of transcation class
    mailbox mbx;   //declare a mailbox to transfer info 
      
    task send();  
        t = new(); 
        mbx.put(t);       //send data
        $display("[GEN] DATA SENT addr:%0h, data:%0h, we:%b, rst:%b", t.addr, t.data, t.we, t.rst);  
    endtask  
  
  	function new(mailbox mbx);      //automate mailbox communication
        this.mbx = mbx;
    endfunction
      
endclass  
  
class driver;  
    transaction t2;  
    mailbox mbx;  
        
    task receive();  
        mbx.get(t2);      //recieve data from mailbox
        $display("[DRV] DATA RECEIVED addr:%0h, data:%0h, we:%b, rst:%b", t2.addr, t2.data, t2.we, t2.rst);
    endtask  
      
 	function new(mailbox mbx);
        this.mbx = mbx;
    endfunction
    
endclass 

module tb();
    driver d;
    generator g;
    mailbox mbx;
    
    initial begin
        mbx = new();     //mailbox is also a class
        d = new(mbx);    //enable mailbox communication
        g = new(mbx);
        fork             //wait for data transfer to finish
            g.send();
            d.receive();
        join
        $finish;
    end
    
endmodule


class transaction;
 
rand bit [7:0] a;
rand bit [7:0] b;
rand bit wr;
 
constraint data{wr dist{1:=50,0:=50};}
endclass

class generator;
    transaction t1;
    mailbox #(transaction) mbx;
    
    function new(mailbox #(transaction) mbx);
        this.mbx = mbx;
    endfunction
    
    task main();      
        for(int i=0; i<10; i++)begin
            t1 = new();
            assert(t1.randomize())else $display("Randomization Failed at time=%0t",$time);
              mbx.put(t1);
              $display("[GEN] DATA SENT a:%0d, b:%0d, wr:%0d", t1.a, t1.b, t1.wr);
              #10;
         end
    endtask
    
endclass

class driver;
    transaction t2;
    mailbox #(transaction) mbx;
    
    function new(mailbox #(transaction) mbx);
        this.mbx = mbx;
    endfunction
    
    task main(); 
        forever begin
            t2 = new();
            mbx.get(t2);
            $display("[GEN] DATA RCVD a:%0d, b:%0d, wr:%0d", t2.a, t2.b, t2.wr);
            #10;
        end
   endtask
 
 endclass
 
 module tb;
    driver d;
    generator g;
    mailbox #(transaction) mbx;
    
    initial begin
        mbx = new();
        d = new(mbx);
        g = new(mbx);
        fork
            g.main();
            d.main();
        join
        $finish;
    end
    
 endmodule