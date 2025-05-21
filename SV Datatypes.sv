`timescale 1ns/1ps

module tb();        

   //array initialization with unique values demonstration
   /*******************************************************/
  
   int arr[10] = '{0,1,4,9,16,25,36,49,64,81};
   initial begin
   $display("arr: %0p",arr);
//   $finish;
   end
  
   //repetitive operation using a for loop
   /*******************************************************/
  
    reg arr_1 [14:0];

    int i=0;
    initial begin
        for(int i=0; i<15; i++)begin		
          arr_1[i] = {$random}%2;		//generate random values either 0 or 1
        end
    end
    
    initial begin
      $display("arr_1: %0p",arr_1);
      // $finish;
    end

  	/*****************************************************/
  
  	
  	//dynamic array 
  	/*****************************************************/
  	int arr_2[];  //create a dynamic array
    int i;
    int j;
    
    initial begin		//assign initial value to variables
    i=0;
    j=0;
    end
    
    initial begin        
        arr_2=new[7];            //allocate 7 spaces
        repeat(7)begin			
          arr_2[i]=7*i+7;
          i++;
          $display("%0d:%0d",i,arr_2[i]);       
        end
    end
    
     initial begin
      #20
       arr_2=new[20](arr_2);    //allocate 13 more spaces and transfer existing data to expanded array
      repeat(13)begin
        arr_2[j+7]=5*j+5;
        j++;
      end
       $display("arr_2: %0p",arr_2);
       arr_2.delete();			//delete the dynamic array
       $finish;
     end
      
     initial begin
     $dumpfile("dump.vcd");
     $dumpvars;
     end
 
    /********************************************************/
  
  

  	//queue
  	/********************************************************/
  	
  	int arr_3[20];		//fixed array with 20 elements
    int k=0;
  	int arr2[$];        //initialize a queue
    
  	initial begin
        for(int i=0; i<20; i++)begin
            arr_3[i]={$random}%2;            //assign random value to fixed size array
        end
    end
    
    initial begin
        for(int j=0; j<20; j++)begin
          arr2.insert(j,arr_3[19-j]);            //insert data into queue in reverse order
        end
    end
    
    initial begin
    $display("fixed size array: %0p",arr_3);
    $display("queue: %0p",arr2);
    arr2.delete();						//delete the queue
    $finish;
    end

endmodule