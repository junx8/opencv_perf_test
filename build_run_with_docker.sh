docker build -t opencv_perf_test .
docker run -it -v $(pwd)/docker_results:/home/results/ opencv_perf_test bash
