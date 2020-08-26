#! /bin/bash
set -x

export OUTUPT_DIR=/output
export CGC_SOURCE=/home/haochen/work/cgc/cb-multios_gcov
export CONFIG_DIR=/workdir/env/config

function eval() {
    NAME_PATH=$(echo $1 | cut -d '_' -f 1)_$(echo $1 | cut -d '_' -f 2)
    VERSION=$2
    NAME=$(echo $NAME_PATH | cut -d '/' -f 3)
    CB_NAME=$(python $CONFIG_DIR/cb_dic.py -n $NAME)
    cd $OUTUPT_DIR/${NAME}_${VERSION}
    mv ./qsym/queue/* ./afl-master/queue
    rm -rf ./qsym
    if [ -d ./cov ]; then
        rm -rf ./cov
    fi
    /afl-cov/afl-cov -d $1 --coverage-cmd "${CGC_SOURCE}/${CB_NAME}_${VERSION}/build/challenges/${CB_NAME}/${CB_NAME} < AFL_FILE"  --code-dir ${CGC_SOURCE}/${CB_NAME}_${VERSION} --enable-branch-coverage --coverage-include-lines --clang --cov_all --overwrite && kill -9 $(ps aux|grep "${CB_NAME}_${VERSION}" | awk '{print $2}')
}

cd /workdir
. job_pool.sh
job_pool_init $1 0
# compute lcov report
for result_dir in $OUTUPT_DIR/*; do
    if [ -d ${result_dir} ]; then
        job_pool_run eval $result_dir $2
    fi
done
job_pool_wait
job_pool_shutdown
exit 0
