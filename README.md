# KT Chart Sample Code

## Overview
KT chart monitoring is a powerful tool for monitoring high-frequency multivariate data that has the following features:

- Easy setup
- Easy interpretation and easy visualization
- Provide early alerts
- Alerts can be automated

The [following](#ref) SAS technical report contains several applications of KT chart monitoring. This project contains code
for the examples in the the technical report.

## What is KT Chart Monitoring?
The KT chart monitoring method is intended to provide the means to monitor high-frequency multivariate data. The method is based 
on the SVDD [Tax & Duin, 2004](#svdd) algorithm that is applied to a moving window of observations. This approach enables you to 
reduce noise that can be present in high-frequency data and eliminates the need to monitor individual observations. KT chart 
monitoring has two steps:

1.	Training, which is implemented in the [KTTRAIN](#kttrain) procedure. The training process uses the data from normal 
operations to define the state of statistical control—that is, to determine the central tendency and the spread of the process. 
The KT chart training calculates the control limits for allowed deviations in both the central tendency and the spread. 
The KT chart for monitoring the process center is called the a chart, and the KT chart for monitoring the process variation is called the R2 chart.
2.	Monitoring, which is implemented in the [KTMONITOR](#ktmon) procedure. The monitoring process uses the data from the 
ongoing process to monitor the process for stability in both the central tendency and the spread by using the control limits 
that are calculated in the training step.

## List of examples
| File/Folder|Application|
|-----------------------|------------------|
|drone.sas| KT chart monitoring for drone fault data.|
|drone| A folder containing data for drone.sas. Adapted from [Keipour et al. (2020).](#dronedata)|
|TE.sas| KT chart monitoring for Tennessee Eastman chemical plant process.|
|TE| A folder containing data for TE.sas. Generated using the code from [Ricker (2002).](#te)|
|ellipsoid_rotation_simulation_example.sas| KT chart monitoring using simulated hyperellipsoid data.|
|hypersphere_simulation_example.sas| KT chart monitoring using simulated hypersphere data.|
|two_spheres_simulation_example.sas| KT chart monitoring using simulated two spheres data.|



## Installation
Required software offered as part of [**SAS Visual Forecasting**](https://support.sas.com/en/software/visual-forecasting-support.html).

## Contributing
We are not accepting any contributions to this project.

## License
This project is licensed under the [Apache 2.0 License](LICENSE).

## <a name="ref"> </a> References
[1] Monitoring Machine Health Using KT Charts: Sergiy Peredriy, Deovrat Kakde, Arin Chaudhuri, and Steven Xu, SAS Institute Inc., URL to be updated

[2] <a name="ktmon"> </a> SAS Institute Inc. (2021). KTMONITOR Procedure. Retrieved from SAS® Viya® Programming Documentation: https://go.documentation.sas.com/doc/en/pgmsascdc/v_010/casforecast/casforecast_ktmonitor_toc.htm

[3] <a name="kttrain"> </a> SAS Institute Inc. (2021). KTTRAIN Procedure. Retrieved from SAS® Viya® Programming Documentation: https://go.documentation.sas.com/doc/en/pgmsascdc/v_010/casforecast/casforecast_kttrain_toc.htm

[4] Kakde, D., Peredriy, S., & Chaudhuri, A. (2017). A Non-parametric Control Chart for High Frequency Multivariate Data. Annual Reliability and Maintainability Symposium (RAMS). Piscataway, NJ: Institute of Electrical and Electronics Engineers.

[5] Keipour, A. (2020). ALFA Dataset Tools. Retrieved from github.com: https://github.com/castacks/alfa-dataset-tools/

[6] <a name="dronedata"> </a> Keipour, A., Mousaei, M., & Scherer, S. (2020). ALFA: A Dataset for UAV Fault and Anomaly Detection. DOI:10.1184/R1/12707963. Retrieved from https://doi.org/10.1184/R1/12707963

[7] Montgomery, D. C. (2019). Introduction to Statistical Quality Control. New York: John Wiley & Sons.

[8] <a name="te"> </a> Ricker, N. L. (2002). Tennessee Eastman Challenge Archive, MATLAB 7.x Code. Retrieved from University of Washington, Seattle, Department of Chemical Engineering: http://depts.washington.edu/control/LARRY/TE/download.html

[9] <a name="svdd"> </a> Tax, D. M., & Duin, R. P. (2004). Support Vector Data Description. Machine Learning, 54: 45-66.

