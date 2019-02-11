#!/bin/bash
#WES germline pipeline

help () {
	echo -en "usage: $(basename $0) /path/project/directory"
    echo " You have to specify project directory."
}

projectDir=$1
cd $projectDir

if [ "$#" -ne 1 ]; then
    help
    exit 1
fi

if [ ! -d "${projectDir}"/fastq ] || [ ! -d "${projectDir}"/lists ]; then
    echo "There is missing directories - fastq or/and lists"
    echo "Check README.md for detailed help"
    exit 1
else {
    time (

    java -jar ~/software/cromwell-36.jar \
        run ~/scripts/wes-germline-scatter-gather/data_processing.wdl \
        --inputs ~/scripts/wes-germline-scatter-gather/bwa_and_gatk_wdl.json

    wait
    
    ~/scripts/wes-germline-scatter-gather/preparing_bams.sh ${projectDir}

    wait

    java -jar ~/software/cromwell-36.jar \
        run ~/scripts/wes-germline-scatter-gather/gatk_variant_calling.wdl \
        --inputs ~/scripts/wes-germline-scatter-gather/bwa_and_gatk_wdl.json

    wait

    ~/scripts/wes-germline-scatter-gather/preparing_gvcfs.sh ${projectDir}

    wait

    java -jar ~/software/cromwell-36.jar \
        run ~/scripts/wes-germline-scatter-gather/gathering_and_genotyping.wdl \
        --inputs ~/scripts/wes-germline-scatter-gather/bwa_and_gatk_wdl.json

    wait

    rm -rf ${projectDir}/allgvcfs/
    exit 0
    printf -- '\033[32m Success - the end \033[0m\n';
        )
    }
fi

