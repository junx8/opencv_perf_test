
python3 ../../modules/ts/misc/run.py -t gapi --gtest_filter=*CPU* --gtest_output=xml:gapi_cpu.xml
python3 ../../modules/ts/misc/run.py -t gapi --gtest_filter=*GPU* --gtest_output=xml:gapi_gpu.xml
python3 ../../modules/ts/misc/run.py -t gapi --gtest_filter=*Fluid* --gtest_output=xml:gapi_fluid.xml

python3 ../../modules/ts/misc/report.py gapi_cpu.xml -o html >gapi_cpu.ods
python3 ../../modules/ts/misc/report.py gapi_gpu.xml -o html >gapi_gpu.ods
python3 ../../modules/ts/misc/report.py gapi_fluid.xml -o html >gapi_fluid.ods

python3 parse_cpu_gpu_fluid.py