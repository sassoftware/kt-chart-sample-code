/*********************************************************************************************************
                KTCHART IML Hypersphere Example
 The generate_sphere macro generates a set of training and testing dataset for ktchart simulation.    
 The training data consists of uniform samples from a k-dimensional sphere centered at origin 
 with radius 1. The testing data consists of three groups of uniform samples. The first group   
 is generated in the same way that the training data was generated. The second group is generated  
 from a unit sphere with a shifted center. The thrid group is generated from sphere centered at origin  
 with a scaled radius. Some random noise are generated for both training and testing data.  

Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0

*********************************************************************************************************/

%macro generate_sphere(window_size = 1000, window_num = 1000, dimension = 2, center_shift = 1, radius_multiplier = 2, outlier_fraction = 0.0001, seed = 12345);

proc iml;
    call randseed(&seed);
    train_size = &window_size*&window_num;
    X = j(train_size,&dimension,.);
    call randgen(X,"Normal",0,1);
    r = randfun(train_size,"Uniform",0,1)##(1/&dimension);
    norm = X[,##]##(0.5);
    g = randfun(train_size,"Bernoulli",&outlier_fraction);
    g = g#2 - ((g-1)#r);
    X = g#X/norm;
    run Scatter(X[,1],X[,2]);
    varNames = cats("x",char(1:ncol(X)));
    create trainSphere from X [colname = varNames];
    append from X;
    close trainSphere;

    group_size = &window_size*10;
    test_size = group_size*3;
    X = j(test_size,3,.);
    group = j(test_size,1,.);
    call randgen(X,"Normal",0,1);
    r = randfun(test_size,"Uniform",0,1)##(1/3);
    r[(test_size-group_size+1):test_size] = r[(test_size-group_size+1):test_size] * &radius_multiplier;
    norm = X[,##]##(0.5);
    g = randfun(test_size,"Bernoulli",&outlier_fraction);
    g = g#2 - ((g-1)#r);
    X = g#X/norm;
    do i = 1 to 3;
        group[((i-1)*group_size+1):(i*group_size)] = i;
    end;
    X[(group_size+1):(2*group_size),] = X[(group_size+1):(2*group_size),] + &center_shift;
    run Scatter(X[,1],X[,2]) group = group;
    varNames = cats("x",char(1:ncol(X)));
    create testSphere from X [colname = varNames];
    append from X;
    close testSphere;

quit;

data mycas.train;
    set trainSphere;
    datetime = _N_;
run;

data mycas.test;
    set testSphere;
    datetime = _N_;
run;
%mend generate_sphere;

%generate_sphere(window_size = 1000, window_num = 1000, dimension = 2, center_shift = 1, radius_multiplier = 2, outlier_fraction = 0.0001, seed = 12345);

proc kttrain data=mycas.train window=500 overlap=0 frac=1e-4 a_lcl=0.85; 

input x1-x3; 

kernel / bww = 1 bwc = trace; 

output out = mycas.out 

       centers = mycas.centers 

       kt = mycas.outkt 

       scoreInfo = mycas.scoreinfo 

       SV = mycas.SV; 

run; 

 
proc ktmonitor data = mycas.test sv = mycas.sv scoreinfo = mycas.scoreinfo a_lcl=0.8; 

output out = mycas.outmon centers = mycas.centersmon; 

run; 