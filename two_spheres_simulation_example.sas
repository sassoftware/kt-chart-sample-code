/*********************************************************************************************************
                KTCHART IML Two Spheres Example
 The generate_two_modes macro generates a set of training and testing dataset for ktchart simulation.    
 The training data consists of uniform samples from of two spheres. In particular, 80% of the training 
 data come from a unit sphere centered at (0, 0, ..., 0) (mode 1) and the rest come from a unit sphere centered 
 at (2, 2, ..., 2) (mode 2). We then simulated 5 groups of samples in the testing data set. Distribution of 
 group 1 is identical to that of mode 1; distribution of group 2 differs from that of mode 1 by a location 
 change; distribution of group 3 is identical to that of mode 2; distribution of group 4 differs from that 
 of mode 2 by a scale change; distribution of group 5 is a unit sphere with center different from those 
 of mode 1 and mode 2. 

Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0

*********************************************************************************************************/

%macro generate_two_modes(window_size = 1000, window_num = 1000, dimension = 3, center_shift = 2, radius_multiplier = 2, outlier_fraction = 0.0001, seed = 12345);
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
    do i = 1 to &window_num;
        res = mod(i,5);
        if res = 0 then X[((i-1)*&window_size+1):(i*&window_size),] = X[((i-1)*&window_size+1):(i*&window_size),] + &center_shift;
    end;
    run Scatter(X[,1],X[,2]);
    varNames = cats("x",char(1:ncol(X)));
    create trainDisk from X [colname = varNames];
    append from X;
    close trainDisk;

    test_group = 5;
    group_size = &window_size * 10;
    test_size = group_size*test_group;
    X = j(test_size,&dimension,.);
    group = j(test_size,1,.);
    call randgen(X,"Normal",0,1);
    r = randfun(test_size,"Uniform",0,1)##(1/&dimension);
    r[(group_size+1):(2*group_size)] = r[(group_size+1):(2*group_size)] * &radius_multiplier;
    r[(3*group_size+1):(4*group_size)] = r[(3*group_size+1):(4*group_size)] * &radius_multiplier;
    norm = X[,##]##(0.5);
    g = randfun(test_size,"Bernoulli",&outlier_fraction);
    g = g#2 - ((g-1)#r);
    X = g#X/norm;
    X[(2*group_size+1):(4*group_size),] = X[(2*group_size+1):(4*group_size),] + 2;
    X[(4*group_size+1):(5*group_size),] = X[(4*group_size+1):(5*group_size),] + 1;
    do i = 1 to test_group;
        group[((i-1)*group_size+1):(i*group_size)] = i;
    end;
    run Scatter(X[,1],X[,3]) group = group;
    varNames = cats("x",char(1:ncol(X)));
    create testDisk from X [colname = varNames];
    append from X;
    close testDisk;

quit;

data mycas.train;
    set trainDisk;
    datetime = _N_;
run;

data mycas.test;
    set testDisk;
    datetime = _N_;
run;

%mend generate_two_modes;

%generate_two_modes;

ods graphics / imagemap=on;

proc kttrain data=mycas.train window=500 overlap=0 frac=1e-4 a_lcl=0.85; 
input x1-x3; 
kernel / bww = 0.3 bwc = trace; 
output out = mycas.out 
       centers = mycas.centers 
       kt = mycas.outkt 
       scoreInfo = mycas.scoreinfo 
       SV = mycas.SV; 
run; 
 
proc ktmonitor data = mycas.test sv = mycas.sv scoreinfo = mycas.scoreinfo; 
output out = mycas.outmon centers = mycas.centersmon; 
run; 