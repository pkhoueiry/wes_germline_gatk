#!/bin/bash
#WES germline pipeline

help () {
	echo -en "usage: $(basename $0) /path/project/directory /path/to/cromwell.jar"
    echo " You have to specify project directory and the full path of the cromwell JAR file in this order."
}

projectDir=$1
cromwell=$2
scripts_path=$(readlink -f $0 | sed 's/run.sh//g')
cd $projectDir

if [ "$#" -ne 2 ]; then
    help
    exit 1
fi

if [ ! -d "${projectDir}"/fastq ] || [ ! -d "${projectDir}"/lists ]; then
    echo "There is missing directories - fastq or/and lists"
    echo "Check README.md for detailed help"
    exit 1
else {
    time (

    read -p 'Any adapters to trim?(Y/N): ' choice

    if [ "$choice" = "Y" ] || [ "$choice" = "y" ] || [ "$choice" = "Yes" ] || [ "$choice" = "yes" ] || [ "$choice" = "YES" ]; then
    printf -- '\033[33m You have chosen to trim adapters... \033[0m\n';

    java -jar ${cromwell} \
        run ${scripts_path}/data_processing.wdl \
        --inputs ${scripts_path}/bwa_and_gatk_wdl.json

    wait
    
    else
    printf -- '\033[33m Skipping adapters trimming... \033[0m\n';
    
    java -jar ${cromwell} \
        run ${scripts_path}/data_processing_without_trimming.wdl \
        --inputs ${scripts_path}/bwa_and_gatk_wdl.json

    wait
    fi

    ${scripts_path}/preparing_bams.sh ${projectDir}

    wait

    java -jar ${cromwell} \
        run ${scripts_path}/gatk_variant_calling.wdl \
        --inputs ${scripts_path}/bwa_and_gatk_wdl.json

    wait

    ${scripts_path}/preparing_gvcfs.sh ${projectDir}

    wait

    java -jar ${cromwell} \
        run ${scripts_path}/gathering_and_genotyping.wdl \
        --inputs ${scripts_path}/bwa_and_gatk_wdl.json

    wait

    rm -rf ${projectDir}/allgvcfs/
        )
    }
fi

