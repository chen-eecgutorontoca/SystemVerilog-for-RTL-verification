module DFF(
  	input logic clk,
  	input logic rst_n,
  input logic din,
  output logic dout
);
  
  always_ff@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      	dout <= 1'b0;
     end else begin
      	dout <= din;
    end
  end
    
endmodule



interface dff_if;
  logic clk, rst_n, din, dout;

  clocking drv_cb @(posedge clk);
    output din;
  endclocking

  clocking mon_cb @(posedge clk);
    default input #1step output #0;
    input din, dout;
  endclocking
  
endinterface

class transaction;
  rand bit din;
  bit      dout;

  function transaction copy();
    copy = new();
    copy.din  = this.din;
    copy.dout = this.dout;
  endfunction
endclass


class generator;
  transaction trans;
  mailbox #(transaction)   mbx;
  event next; 
  event done;    

  function new(mailbox #(transaction) mbx);
    this.mbx   = mbx;
    this.trans = new();
  endfunction

  task run();
    for (int i = 0; i < 10; i++) begin
      assert(trans.randomize()) else
        $display("[GEN] randomization failed at %0t", $realtime);
      mbx.put(trans.copy);
      $display("[GEN] DATA SENT To DRIVER din=%0d @%0t", trans.din, $time);
      @(next);          
    end
    ->done;
  endtask
  
endclass


class driver;
  transaction              tr;
  virtual dff_if           vif;
  mailbox #(transaction)   mbx;

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
    this.tr  = new();
  endfunction

  task reset();
    vif.rst_n = 1'b0;
    @(negedge vif.clk);     
    vif.rst_n = 1'b1;
    $display("[DRV] Reset released @%0t", $time);
  endtask

  task run();
    forever begin
      mbx.get(tr);
      @(vif.drv_cb);             
      vif.drv_cb.din <= tr.din;  
      $display("[DRV] Drove din=%0d @%0t", tr.din, $time);
    end
  endtask
endclass


class monitor;
  virtual dff_if vif;
  mailbox #(transaction) mbx;

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction

  task run();
    transaction t;
    forever begin
      @(vif.mon_cb);                
      t = new();
      t.din  = vif.mon_cb.din;      
      t.dout = vif.mon_cb.dout;
      mbx.put(t);
      $display("[MON] Captured din=%0d dout=%0d @%0t", t.din, t.dout, $time);
    end
  endtask
endclass


class scoreboard;
  mailbox #(transaction)  mbx;
  event next;      
  event all_done;    

  int N = 10;            
  int seen = 0;
  bit last_din = 1'b0;  
  int passes = 0, fails = 0;

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction

  task run();
    transaction t;
    forever begin
      mbx.get(t);
      if (t.dout === last_din) begin
        $display("[SCO] PASS  exp=%0d got=%0d (din_now=%0d) @%0t",
                 last_din, t.dout, t.din, $time);
        passes++;
      end else begin
        $display("[SCO] FAIL  exp=%0d got=%0d (din_now=%0d) @%0t",
                 last_din, t.dout, t.din, $time);
        fails++;
      end

      last_din = t.din;   
      seen++;
      ->next;           

      if (seen == N+2) begin
        ->all_done;      
      end
    end
  endtask

  task postprocessing();
    $display("======== Summary ========");
    $display("Tests passed: %0d", passes);
    $display("Tests failed: %0d", fails);
  endtask
endclass



class environment;
  generator                g;
  driver                   d;
  monitor                  m;
  scoreboard               s;

  mailbox #(transaction)  mbx_tx;    
  mailbox #(transaction)  mbx_rx;    

  event                    done;
  virtual dff_if           vif;

  function new(virtual dff_if vif);
    this.vif = vif;

    mbx_tx = new();
    mbx_rx = new();

    g = new(mbx_tx);
    d = new(mbx_tx);
    m = new(mbx_rx);
    s = new(mbx_rx);

    d.vif = vif;
    m.vif = vif;

    g.next = s.next;
  endfunction

  task run();
    d.reset();
    fork
      g.run();
      d.run();
      m.run();
      s.run();
    join_any

    wait (s.all_done.triggered);
    disable fork;

    s.postprocessing();
    ->done;
  endtask
endclass



module tb;
  dff_if      vif();
  environment e;

  DFF dut (
    .clk  (vif.clk),
    .rst_n(vif.rst_n),
    .din  (vif.din),
    .dout (vif.dout)
  );

  initial begin
    vif.clk = 1'b0;
   
  end

 always #10 vif.clk = ~vif.clk;


  initial begin
    e = new(vif);
    e.run();
    wait (e.done.triggered);
    $finish;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule