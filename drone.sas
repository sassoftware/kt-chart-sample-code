/*********************************************************************************************************
Using KT chart monitoring on the Air Lab Fault and Anomaly (ALFA) data set
In this example, we use KT chart monitoring to detect faults using
unmanned aerial vehicle (UAV) flight data from the Air Lab Fault and Anomaly (ALFA) data set. 
The ALFA data set is a published real-flight data set (Keipour, Mousaei, & Scherer, ALFA: 
A dataset for UAV Fault and Anomaly Detection. DOI:10.1184/R1/12707963, 2020).
 
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0

*********************************************************************************************************/

/*---NOTE: you need to set up your CAS sessioon first. ---*
 *---Here it is assumed that the CAS libname is mycas.---*/
 
/*---put the correct location of the data folder here---*/

%let dataloc=.\drone; 

%let engine=6;

proc import datafile ="&dataloc\fault_engine_0&engine..csv" out= trainscore dbms=csv replace;
datarow=3;
getnames=yes;
run;

symbol i=j;

legend1 label=none position=(top right inside) value=('Commanded' 'Measured') mode=share cborder=black;

proc gplot data=trainscore;
   title "Flight = &engine Var = roll";
   plot (roll_c roll_m)*datetime/overlay legend=legend1;
   title "Flight = &engine Var = vy";
   plot (vy_c vy_m)*datetime/overlay legend=legend1;
   title "Flight = &engine Var = vz";
   plot (vz_c vz_m)*datetime/overlay legend=legend1;
run; quit;

data tsd;
set trainscore;
retain t;
diff = datetime-t;
t=datetime;
run;

title "Flight = &engine";
proc univariate data=tsd;
histogram diff;
run;


%macro lag;
%local i var vars all_vars;
%let vars=roll yaw pitch;

%let i=1;
%let var=%scan(&vars,&i);
%do %while (&var ne);
   %let all_vars = &all_vars &var._c &var._m;
   %let i =%eval(&i+1);
   %let var=%scan(&vars,&i);
%end;

proc sql noprint;
select min(datetime), max(datetime) into :fault_time, :tot_time from trainscore
where fault=1;
quit;
 
data ts; set trainscore; datetime=datetime*100; run;

proc expand data=ts out=tsn to=second method=step;
var &all_vars;
id datetime;
format datetime best12.;
run;

data tsn; set tsn; datetime=datetime/100; run;

data mycas.ts; set tsn; where datetime<&fault_time; run;

%let i=1;
%let var=%scan(&vars,&i);
%do %while (&var ne);

proc cas;
 action tsInfo.selectLag result=r /
   casOut={name="lagOut_&var" replace="yes"}
   dttmName="datetime"
   minLag=0
   maxLag=400
   timeSeriesTable={name="ts"}
   targetName="&var._m"
   xVarNames={"&var._c"};
 run; 
 quit;

proc sql noprint;
select distinct lags into :&var._lag from mycas.lagout_&var having ccf=max(ccf);
quit;

%let i =%eval(&i+1);
%let var=%scan(&vars,&i);

%end;

data lags;
%let i=1;
%let var=%scan(&vars,&i);
%do %while (&var ne);
   &var = &&&var._lag;
   %let i =%eval(&i+1);
   %let var=%scan(&vars,&i);
%end;
fault_time = &fault_time; tot_time = &tot_time;
run;

%mend;
%lag;

%let ttime = 90;
proc sql noprint;
select roll, yaw, pitch into :roll_lag, :yaw_lag, :pitch_lag
from lags;
quit;

%macro diff;
%let vars=roll yaw pitch;

data tsdiff;
set tsn;
%let i=1;
%let var=%scan(&vars,&i);
%do %while (&var ne);
&var._d = &var._m-lag%sysfunc(strip(&&&var._lag))(&var._c);
%let i =%eval(&i+1);
%let var=%scan(&vars,&i);
%end;
run;
%mend;
%diff;

data work.train work.score;
set tsdiff;
if datetime<&ttime then output work.train;
else output work.score;
run;

data mycas.train; set train; run;
data mycas.score; set score; run;

ods graphics / imagemap=on;

title "Flight = &engine";
proc kttrain data=mycas.train window=100 overlap=0 a_lcl=.9;
input roll_d yaw_d pitch_d ;
output out = mycas.out
       centers = mycas.centers
       kt = mycas.outkt
       scoreInfo = mycas.scoreinfo
       SV = mycas.SV;
run;

proc ktmonitor data=mycas.score sv=mycas.SV scoreInfo = mycas.scoreinfo ;
output out = mycas.scoreout
       centers = mycas.scorecenters;
run;
