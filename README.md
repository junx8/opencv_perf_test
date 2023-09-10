# opencv_perf_test


```
.
├── autotest.sh  ## test script for opencv_core opencv_imgproc
├── build_run_with_docker.sh  ## test script with docker
├── Dockerfile  ## test docker image Dockerfile
├── parse_result.py ## python parse script, will auto download in the script
└── README.md
```

## Run Test

```
source autotest.sh
```

- Only run All[5] test will generate the analysis reports

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

