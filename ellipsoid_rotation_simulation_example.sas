/*********************************************************************************************************
                KTCHART IML Ellipsoid Rotation Example
 The generate_ellipsoid macro generates a set of training and testing dataset for ktchart simulation.    
 The training data consists of uniform samples from a 3-dimensional ellipsoid centered at origin 
 with radii (x,y,z). The testing data consists of groups of uniform samples each generated from the training
 distribution after some rotation.

Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0

*********************************************************************************************************/

%macro generate_rotating_ellipsoids(window_size = 1000, window_num = 1000, rotation_number = 3, x_radius = 1, y_radius = 2, z_radius = 5, outlier_fraction = 1e-4, seed = 12345);
proc iml;
    call randseed(&seed);
    train_size = &window_size*&window_num;
    X = j(train_size,3,.);
    call randgen(X,"Normal",0,1);
    r = randfun(train_size,"Uniform",0,1)##(1/3);
    norm = X[,##]##(0.5);
    g = randfun(train_size,"Bernoulli",&outlier_fraction);
    g = g#2 - ((g-1)#r);
    X = g#X/norm;
    M = I(3);
    M[1,1] = &x_radius;
    M[2,2] = &y_radius;
    M[3,3] = &z_radius;
    X = X*M;
    run Scatter(X[,1],X[,2]);
    varNames = cats("x",char(1:ncol(X)));
    create trainEllipsoid from X [colname = varNames];
    append from X;
    close trainEllipsoid;

    group_size = &window_size*10;
    test_size = group_size*&rotation_number;
    X = j(test_size,3,.);
    group = j(test_size,1,.);
    call randgen(X,"Normal",0,1);
    r = randfun(test_size,"Uniform",0,1)##(1/3);
    pi = constant('pi');
    norm = X[,##]##(0.5);
    g = randfun(test_size,"Bernoulli",&outlier_fraction);
    g = g#2 - ((g-1)#r);
    X = g#X/norm;
    M[1,1] = &x_radius;
    M[2,2] = &y_radius;
    M[3,3] = &z_radius;
    X = X*M;
    R = I(3);
    do i = 1 to 3;
        R[1,1] = cos(i*pi/3);
        R[2,2]= cos(i*pi/3);
        R[1,2]= -sin(i*pi/3);
        R[2,1]= sin(i*pi/3);
        X[((i-1)*group_size+1):(i*group_size),] = X[((i-1)*group_size+1):(i*group_size),]*R;
        group[((i-1)*group_size+1):(i*group_size)] = i;
    end;
    run Scatter(X[,1],X[,2]) group = group;
    varNames = cats("x",char(1:ncol(X)));
    create testEllipsoid from X [colname = varNames];
    append from X;
    close testEllipsoid;

quit;

data mycas.train;
    set trainEllipsoid;
    datetime = _N_;
run;

data mycas.test;
    set testEllipsoid;
    datetime = _N_;
run;
%mend generate_rotating_ellipsoids;

%generate_rotating_ellipsoids(window_size = 1000, window_num = 1000, rotation_number = 3, x_radius = 1, y_radius = 2, z_radius = 5, outlier_fraction = 1e-4, seed = 12345);

ods graphics / imagemap=on;

proc kttrain data=mycas.train window=500 overlap=0 frac=1e-4 a_lcl=0.85; 
input x1-x3; 
kernel / bww = 0.5 bwc = trace; 
output out = mycas.out 
       centers = mycas.centers 
       kt = mycas.outkt 
       scoreInfo = mycas.scoreinfo 
       SV = mycas.SV; 
run; 

 
proc ktmonitor data = mycas.test sv = mycas.sv scoreinfo = mycas.scoreinfo a_lcl=0.8; 
output out = mycas.outmon centers = mycas.centersmon; 
run; 
