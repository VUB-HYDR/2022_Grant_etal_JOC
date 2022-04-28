# 2022_Grant_etal_JOC

## To install

This analysis uses Climate Data Operators (CDO) in bash and Python. 

Python scripts are run on python3. The [environment](https://github.com/VUB-HYDR/2022_Grant_etal_JOC/blob/main/da.yml) for this analysis is available for installing necessary packages.

## For users

Bash scripts are used for coarsening model and observational inputs to the time-frame of this analysis.

Python scripts are used for the detection and attribution analysis, which is built on adapted python code from [pinplex](https://github.com/pinplex/PyDnA).

Python code is labelled as follows:
- 'analysisname_main.py'; the main script for adapting analysis factors
- 'analysisname_sr_routine_name.py'; a sub-routine script for doing some stuff
- 'analysisname_funcs.py'; a script holding all processing and plotting functiosn for a given analysis

Where an 'analysisname' indicates:
- 'da'; regularized optimal fingerprinting analysis
- 'pca'; EOF analysis
- 'lu'; trend and correlation analysis of LU and treeFrac/cropFrac

## License

This project is licensed under the MIT License. See also the [LICENSE](https://github.com/VUB-HYDR/2022_Grant_etal_JOC/LICENSE.md) file.
