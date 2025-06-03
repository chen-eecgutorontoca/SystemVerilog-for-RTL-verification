`timescale 1ns/1ns

class first;          //initialize a class with three variables
    int data1;
    int data2;
    int data3;
endclass


//a function to perform multiplication
function int multiplication(input int a, input int b);        
    return a*b;
endfunction


//a task to perform multiplication
task multiply(input int a, input int b, output int y);		
  y = a * b;
endtask


//swap variable task, pass by reference
task automatic swap(ref bit [1:0] a, b);			
  bit [1:0] temp;
  temp = a;
  a = b;
  b = temp;
endtask


//create a function and pass an array by reference
function automatic void generate_values(ref bit [31:0] arr[32]);    
    for(int i=0; i<32; i++)begin
        arr[i] = i*8;
    end
endfunction

/****************************************************************************************/

class second;
  int data1;
  bit [7:0] data2;
  shortint data3;
  
  function new(input int data1 = 0, input bit data2 = 8'h00, input shortint data3 = 0);
    this.data1 = data1;
    this.data2 = data2;
    this.data3 = data3;
  endfunction
  
  task display();
    $display("value of data1: %0d",data1);
  endtask

endclass

/***********************************************************************************/

class third;
  	bit [3:0] a;
    bit [3:0] b;
    bit [3:0] c;
  
   function new(input bit[3:0]a = 4'b0, input bit[3:0]b=4'b0, input bit[3:0]c=4'b0);    
        this.a = a;
        this.b = b;
        this.c = c;
   endfunction  
  
  	task add(output bit[4:0]result);            
        result = a+b+c;
        $display("a=%0d, b=%0d, c=%0d, result: %0d", a,b,c,result);
    endtask

endclass
  
  
/*********************************************************************************/

class first_one;
  local int data;			//restricted to that class
  
  task set(input int data);
    this.data = data;
  endtask
  
  function int get();
    return data;
  endfunction
    
endclass


class second_one;  
 
  first_one f;
  
  function new();
    f = new();
  endfunction
  
endclass
/********************************************************/


//shallow copy
/*******************************************************/
class firstclass;
  int data = 12;
endclass

class secondclass;
  int ds = 34; 
  firstclass f1;
  function new();
    f1 = new();
  endfunction
endclass
/******************************************************/


//deep copy
/******************************************************/
class fir;
  int data = 12;
  
  function fir copy();
    copy = new();
    copy.data = data;
  endfunction
  
endclass

class sec;
  int ds = 34;
  fir f1;
  
  function new();
    f1 = new();
   endfunction
  
  function sec copy();
    copy = new();
    copy.ds = ds;
    copy.f1 = f1.copy;
  endfunction
  
endclass
/*****************************************************/


/****************************************************/
class generator;
  
  bit [3:0] a = 5,b =7;
  bit wr = 1;
  bit en = 1;
  bit [4:0] s = 12;
  
  function void display();
    $display("a:%0d b:%0d wr:%0b en:%0b s:%0d", a,b,wr,en,s);
  endfunction
 
 function generator copy();        //create a function for deep copy
    copy = new();
    copy.a = a;
    copy.b = b;
    copy.wr = wr;
    copy.en = en;
    copy.s = s;
    endfunction
    
endclass
/************************************************************/


//Parent and child class
/***********************************************************/
class FIRST;
  int data = 12;
  virtual function void display();
    $display("First value of data: %0d", data);
  endfunction
endclass

class SECOND extends FIRST;
  
  int temp = 34;
  function void add();
    $display("Value of processed: %0d", temp+4);
  endfunction
  
  function void display();
    $display("Second value of data: %0d", data);
  endfunction
  
endclass
/**********************************************************/
  

/**********************************************************/
class one;
  int data;
  
  function new(input int data);
    this.data = data;
  endfunction 
  
endclass

class two extends one;
  int temp;
  
  function new(int data, int temp);
    super.new(data);					//invoke parent class's constructor
    this.temp = temp;
  endfunction 
  
endclass
  
/*********************************************************/



module tb();
 
/*********************************************************/  
    first f1;            //create the object
  
    initial begin
    f1 = new();        //call constructor
    f1.data1 = 45;      //assign values to the object
    f1.data2 = 79;
    f1.data3 = 90;
    end
    
    initial begin
      //    $display("%0d  %0d  %0d",f1.data1, f1.data2, f1.data3);
    f1 = null;        //deallocate memory space
 //  $finish;
    end
/*********************************************************/   

  
/*********************************************************/
  	int a;
    int b;
    int result;
  	int y;
    
	initial begin
    a = $urandom();            //generate random values for a & b
    b = $urandom();
    $display("a: %0d  b: %0d",a, b);
    
    result = multiplication(a,b);
    
    multiply(a, b, y);
      
    $display("a*b = %0d",result);
      if(result == y)begin
        $display("Test Passed!");
    end else begin
        $display("Test Failed!");
    end
      
//    $finish;
 end
/*********************************************************/  

  
  
//pass by reference and generate values  
/*********************************************************/
  
  	bit [31:0] arr[32];
  
   initial begin
    generate_values(arr);
    #10
     for(int j=0; j<32; j++)begin
//       $display(arr[j]);
    end
//    $finish;
    end
/*********************************************************/
  
  
//call custom constructor
/*********************************************************/  	
  	second s2;
  	initial begin
      s2 = new(23, , 35);				//follow by order
      s2 = new(.data2(4), .data3(5), .data1(6));
      s2.display();
    end
  	
  bit [4:0] result = 5'b0;			//assign initial value to variable
  
  	third t3;
  	initial begin
      t3 = new(1,2,4);
      t3.add(result);
    end
  
/*********************************************************/


//use a class inside another class 
/********************************************************/
  
  second_one s;
  initial begin
    s = new();
    s.f.set(123);
    $display("value of data in class first_one is %0d", s.f.get());
  end
/*********************************************************/
  
  
//shallow copy demonstration
/*********************************************************/
	secondclass sec1, sec2;

	initial begin
      sec1 = new();
      sec1.ds = 45;
      sec2 = new sec1;
      $display("sec2.ds=%0d", sec2.ds);
      sec2.ds = 78;
      $display("sec1.ds=%0d", sec1.ds);
      sec2.f1.data = 56;
      $display("sec1.f1.data=%0d sec2.f1.data=%0d",sec1.f1.data, sec2.f1.data);
    end
    
/*********************************************************/


//deep copy demonstration
/********************************************************/
    sec ss1, ss2;
  	
  	initial begin
      ss1 = new();
      ss2 = new();
      ss1.ds = 45;
      $display("ss2.ds=%0d",ss2.ds);
      ss2 = ss1.copy();
      $display("ss2.ds=%0d",ss2.ds);
      ss2.ds = 78;
      $display("ss1.ds=%0d ss2.ds=%0d", ss1.ds, ss2.ds);
      ss2.f1.data = 98;
      $display("ss1.f1.data=%0d  ss2.f1.data=%0d", ss1.f1.data, ss2.f1.data);
    end
  
/*********************************************************/ 
  
 
/**********************************************************/
   	generator g1;
    generator g2;
    
    initial begin
        g1 = new();                   
        g2 = g1.copy();                //perform deep copy, g1-> g2
        g2.wr = 0;
        g2.s = 11;
        g2.en = 0;
        g2.a = 4;
        g2.b = 9;
        g1.display();                  
        g2.display();
     end
/*********************************************************/
  

//Inheritance and virtual demonstration
/*********************************************************/
  	FIRST F;
  	SECOND S;
  	initial begin
      S = new();
      F = new();
      S.display();
      S.add();
      S.data = 16;
      S.display();
      F.display();
    end
  	
  	initial begin	
 //    F = new();
 //    F.display();
    end
/********************************************************/  

  
//inherits parent class's constructor 
/********************************************************/
  one o;	
  two t;
  	initial begin
      o = new(20);
      t = new(67,45);
      $display("Value of data in two: %0d, temp: %0d", t.data, t.temp);
      $display("Value of data in one: %0d", o.data);
    end
/*******************************************************/  
  
endmodule