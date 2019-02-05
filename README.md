WES Germline scatter-gather pipeline

This pipeline runs by just invoking run.sh <projectDirectory> in command line.
the <projectDir> should have the following structure:
    
    1- "fastq" directory which contains FASTQ files. FASTQ files should have the following naming style:
        sampleName_R1.fastq.gz and sampleName_R2.fastq.gz
    
    2- "lists" directory which contains two txt files:
        - "fastq_list.txt"
        - "scatter_calling_intervals.txt"

            "fastq_list.txt" is a tab separated file and should contain all samples required for analysis:
                sampleName1    sampleName1_R1.fastq.gz    sampleName1_R2.fastq.gz
                sampleName2    sampleName2_R1.fastq.gz    sampleName2_R2.fastq.gz

            "scatter_calling_intervals.txt" should contain a list of full path of all intervals:
            path/to/intervals/scattered_calling_intervals/temp_0001_of_50/scattered.interval_list
            path/to/intervals/scattered_calling_intervals/temp_0002_of_50/scattered.interval_list
            path/to/intervals/scattered_calling_intervals/temp_0003_of_50/scattered.interval_list
            path/to/intervals/scattered_calling_intervals/temp_0004_of_50/scattered.interval_list
            path/to/intervals/scattered_calling_intervals/temp_0005_of_50/scattered.interval_list

        Finally, we have to specify the path of both "fastq_list.txt" and "scatter_calling_intervals.txt" in the JSON file

We can invoke each WDL and shell scripts separately.
