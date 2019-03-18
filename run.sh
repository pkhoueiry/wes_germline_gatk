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

    #read -p 'Any adapters to trim?(Y/N): ' choice

    if [ "$choice" = "Y" ] || [ "$choice" = "y" ] || [ "$choice" = "Yes" ] || [ "$choice" = "yes" ] || [ "$choice" = "YES" ]; then
    printf -- '\033[33m You have chosen to trim adapters... \033[0m\n';

    java -jar /home/software/cromwell/cromwell-36.jar \
        run /home/scripts/wes-germline-scatter-gather/data_processing.wdl \
        --inputs /home/scripts/wes-germline-scatter-gather/bwa_and_gatk_wdl.json

    wait
    
    else
    printf -- '\033[33m Skipping adapters trimming... \033[0m\n';
    
    java -jar /home/software/cromwell/cromwell-36.jar \
        run /home/scripts/wes-germline-scatter-gather/data_processing_without_trimming.wdl \
        --inputs /home/scripts/wes-germline-scatter-gather/bwa_and_gatk_wdl.json

    wait
    fi

    /home/scripts/wes-germline-scatter-gather/preparing_bams.sh ${projectDir}

    wait

    java -jar /home/software/cromwell/cromwell-36.jar \
        run /home/scripts/wes-germline-scatter-gather/gatk_variant_calling.wdl \
        --inputs /home/scripts/wes-germline-scatter-gather/bwa_and_gatk_wdl.json

    wait

    /home/scripts/wes-germline-scatter-gather/preparing_gvcfs.sh ${projectDir}

    wait

    java -jar /home/software/cromwell/cromwell-36.jar \
        run /home/scripts/wes-germline-scatter-gather/gathering_and_genotyping.wdl \
        --inputs /home/scripts/wes-germline-scatter-gather/bwa_and_gatk_wdl.json

    wait

    rm -rf ${projectDir}/allgvcfs/
        )
    }
fi

