/*********************************************************************************************************
Using KT Chart Monitoring for Tennessee Eastman Process
In this example, we use KT chart monitoring to detect faults in Tennessee Eastman
process. The Tennessee Eastman (TE) process is a realistic model of a typical 
chemical industrial process. This is a nonlinear, open-loop, unstable process 
that is widely used in the academic community as a case study of multivariate 
statistical process control, plant-wide control, and sensor fault detection. 
MATLAB simulation code from Ricker (2002) was used to generate the TE process data. 
Data were generated for the normal operations of the process and for 20 different 
fault conditions.

Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0

*********************************************************************************************************/

/*---NOTE: you need to set up your CAS sessioon first. ---*
 *---Here it is assumed that the CAS libname is mycas.---*/
 
/*---put the correct location of the data folder here---*/

libname d '.\TE';

%macro expand(input=, output=, time=);
   data in;
      merge &time &input;
      time=t*3600;
   run;

   proc expand data=in out=tmp to=second method=spline(natural);
      var x1-x41;
      id time;
   run;

   proc expand data=tmp out=&output factor=20:1 method=spline(natural);
      var x1-x41;
      id time;
   run;
%mend;

/*---TRAINING---*/

%expand(input=d.normal, output=train, time=d.t00);

data mycas.train; set train; where time<5400; run;

title "TE Plant";

ods graphics / imagemap=on;

proc kttrain data=mycas.train window=600 overlap=0;
input x1-x41;
timeid time;
output out = mycas.out
       centers = mycas.centers
       kt = mycas.outkt
       scoreInfo = mycas.scoreinfo
       SV = mycas.SV;
run;

/*---SCORING FOR ONE FAULT---*/

%expand(input=d.fault13, output=mycas.score, time=d.t13);

title "TE Plant Fault 13";

proc ktmonitor data=mycas.score sv=mycas.SV scoreInfo = mycas.scoreinfo a_lcl=0.6;
output out = mycas.scoreout
       centers = mycas.scorecenters;
run;

/*---SCORING FOR ALL FAULTS---*/

%macro a;
%do i=1 %to 20;
%if %eval(&i<10) %then %let f=0&i; %else %let f=&i;

%expand(input=d.fault&f, output=mycas.score, time=d.t&f);

title "TE Plant Fault &f";

proc ktmonitor data=mycas.score sv=mycas.SV scoreInfo = mycas.scoreinfo;
output out = mycas.scoreout
       centers = mycas.scorecenters;
run;
%end;
%mend;

%a;

