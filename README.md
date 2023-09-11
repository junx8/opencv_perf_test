# opencv_perf_test


```
.
├── autotest.sh  ## test script for opencv_core opencv_imgproc
├── parse_result.py ## python parse script, will auto download in the script
└── README.md
```

## Run Test

```
source autotest.sh 5
```
> Run All Test

```
            1. Baseline Single Thread
            2. Baseline Multi Thread
            3. SIMD Single Thread
            4. SIMD Multi Thread
            5. All
```


### Run Single Test

```
source autotest.sh
```

```
You are run on /home/4T1/jun/works/ov_ats/test/opencv_perf_test
Logs will save in /home/4T1/jun/works/ov_ats/test/opencv_perf_test/script_log.txt 
Reports will save in /home/4T1/jun/works/ov_ats/test/opencv_perf_test/perf_test_reports 

You Can Run the test: 
            1. Baseline Single Thread
            2. Baseline Multi Thread
            3. SIMD Single Thread
            4. SIMD Multi Thread
            5. All
        
        
Please select the number: [1/2/3/4/5]
```

