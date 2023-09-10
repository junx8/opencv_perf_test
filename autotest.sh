
scriptpath=$(pwd)
logfile="script_log.txt"
rm -f $logfile
touch $logfile
logfpath=$(realpath ${logfile})
echo -e "You are run on $scriptpath" |tee $logfpath
echo -e "Logs will save in $logfpath "  |tee -a $logfpath
makecore=$(($(free -g|grep Mem|awk '{print $2}')/8+1))
mkdir -p perf_test_reports
report_path=$(realpath perf_test_reports)
echo -e "Reports will save in $report_path \n"  |tee -a $logfpath

function install_prerequisites(){
    sudo apt update |tee -a $logfpath
    sudo apt install -y cmake g++ wget python3 python3-pip|tee -a $logfpath
    pip3 install pandas openpyxl
}

function download_opencv(){
    rm -f 4.8.0.tar.gz
    wget https://github.com/opencv/opencv/archive/refs/tags/4.8.0.tar.gz|tee -a $logfpath
    tar zvxf 4.8.0.tar.gz|tee -a $logfpath
}

function parse_result(){
    cd $scriptpath/
    rm parse_result.py
    wget https://gist.githubusercontent.com/junxnone/64e547777de73775b1425f6caf259755/raw/f418241b56338a2f06c668f62c6b8f553575ae4a/parse_result.py |tee -a $logfpath

    cd $report_path/

    python3 ../parse_result.py -bs core_base_singleTH.json \
        -bm core_base_multiTH.json \
        -ss core_simd_singleTH.json \
        -sm core_simd_multiTH.json \
        -s core_summary.csv |tee -a $logfpath
    python3 ../parse_result.py -bs imgproc_base_singleTH.json \
        -bm imgproc_base_multiTH.json \
        -ss imgproc_simd_singleTH.json \
        -sm imgproc_simd_multiTH.json \
        -s imgproc_summary.csv |tee -a $logfpath
    python3 ../parse_result.py -m "core linux" core_summary.csv "imgproc linux" imgproc_summary.csv |tee -a $logfpath
}

function testif(){
    install_prerequisites
    download_opencv

    if [ $1 -eq 1 ] ||  [ $2 -eq 1 ] ;then
        cd $scriptpath/opencv-4.8.0
        echo "Run in $(pwd)" |tee -a $logfpath

        echo -e "\nStarting build for Baseline... " |tee -a $logfpath;
        mkdir -p build_baseline
        cd build_baseline
        cmake -DCV_DISABLE_OPTIMIZATION=ON -DWITH_OPENCL=ON .. |tee -a $logfpath
        make -j${makecore} |tee -a $logfpath
    fi
    if [ $3 -eq 1 ] ||  [ $4 -eq 1 ];then
        cd $scriptpath/opencv-4.8.0
        echo "Run in $(pwd)" |tee -a $logfpath

        echo -e "\nStarting build for SIMD... " |tee -a $logfpath;
        mkdir -p build_simd
        cd build_simd
        cmake .. |tee -a $logfpath
        make -j${makecore} |tee -a $logfpath
    fi


    if [ $3 -eq 1 ];then
        echo -e "\nStarting test for SIMD Single Thread... " |tee -a $logfpath;
        cd $scriptpath/opencv-4.8.0/build_simd/bin

        ./opencv_perf_core --perf_threads=1 --gtest_output=json |tee -a $logfpath
        mv test_detail.json $report_path/core_simd_singleTH.json
        ./opencv_perf_imgproc --perf_threads=1 --gtest_output=json |tee -a $logfpath
        mv test_detail.json $report_path/imgproc_simd_singleTH.json
    fi
    if [ $4 -eq 1 ];then
        echo -e "\nStarting test for SIMD Multi Thread... " |tee -a $logfpath;
        cd $scriptpath/opencv-4.8.0/build_simd/bin

        ./opencv_perf_core --gtest_output=json |tee -a $logfpath
        mv test_detail.json $report_path/core_simd_multiTH.json
        ./opencv_perf_imgproc --gtest_output=json |tee -a $logfpath
        mv test_detail.json $report_path/imgproc_simd_multiTH.json
    fi

    export OPENCV_IPP=disabled
    export OPENCV_OPENCL_DEVICE=disbaled

    if [ $1 -eq 1 ];then
        echo -e "\nStarting test for Baseline Single Thread... " |tee -a $logfpath;
        cd $scriptpath/opencv-4.8.0/build_baseline/bin

        ./opencv_perf_core --perf_threads=1 --gtest_output=json |tee -a $logfpath
        mv test_detail.json $report_path/core_base_singleTH.json
        ./opencv_perf_imgproc --perf_threads=1 --gtest_output=json |tee -a $logfpath
        mv test_detail.json $report_path/imgproc_base_singleTH.json

    fi

    if [ $2 -eq 1 ];then
        echo -e "\nStarting test for Baseline Multi Thread... " |tee -a $logfpath;
        cd $scriptpath/opencv-4.8.0/build_baseline/bin

        ./opencv_perf_core --gtest_output=json |tee -a $logfpath
        mv test_detail.json $report_path/core_base_multiTH.json
        ./opencv_perf_imgproc --gtest_output=json |tee -a $logfpath
        mv test_detail.json $report_path/imgproc_base_multiTH.json
    fi
}


while true
do
    echo -e "You Can Run the test: 
            1. Baseline Single Thread
            2. Baseline Multi Thread
            3. SIMD Single Thread
            4. SIMD Multi Thread
            5. All
        
        " |tee -a $logfpath

    echo $#
    if [ $# -eq 1 ];then
        input=$1
    else
        read -r -p "Please select the number: [1/2/3/4/5] " input 
    fi

    case $input in
        1)
            echo -e "\nOnly Build and Test Baseline Single Thread... " |tee -a $logfpath;
            testif 1 0 0 0
            break
            ;;

        2)
            echo -e "\nOnly Build and Test Baseline Multi Thread... " |tee -a $logfpath;
            testif 0 1 0 0
            break
            ;;
        3)
            echo -e "\nOnly Build and Test SIMD Single Thread... " |tee -a $logfpath;
            testif 0 0 1 0
            break
            ;;
        4)
            echo -e "\nOnly Build and Test SIMD Multi Thread... " |tee -a $logfpath;
            testif 0 0 0 1
            break
            ;;
        5)
            echo -e "\nBuild and Test All ... " |tee -a $logfpath;
            testif 1 1 1 1
            parse_result
            break
            ;;
        *)
            echo "Invalid input..." |tee -a $logfpath
            ;;
    esac
done
cd $scriptpath
