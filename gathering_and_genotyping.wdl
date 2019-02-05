#WDL gathering GVCFs and genotyping
#Takes list of GVCFs for many samples
#we need to assign samples names and text file for each sample
#listing full path of GVCFs

workflow gatk_variant_calling{

File GVCF_samples_lists
Array[File] gvcfs_all_samples = read_lines(GVCF_samples_lists)
File gatk
File tabix
File refFasta
File refIndex
File refDict
File refAMB
File refANN
File refBWT
File refPAC
File refSA

call MergeVcfs{
        input:
            gatk = gatk,
            tabix = tabix,
            refFasta = refFasta, 
            refIndex = refIndex, 
            refDict = refDict,
            gvcfs_all_samples = gvcfs_all_samples
    }

call GenotypeGVCFs {
        input:
            gatk = gatk,
            tabix = tabix,
            refFasta = refFasta, 
            refIndex = refIndex, 
            refDict = refDict,
            merged_gvcfs = MergeVcfs.merged_gvcfs
            
    }
}

task MergeVcfs{
    File gatk
    File tabix
    File refFasta
    File refIndex
    File refDict
    Array[File] gvcfs_all_samples

    command {
        for file in ${sep=' ' gvcfs_all_samples}; do

            filename=$(basename $file)
            output_filename=$(echo "$filename" | cut -f 1 -d '.')

            java -jar ${gatk} MergeVcfs \
                -I $file \
                -O $output_filename".vcf"
        done
    }

    output {
        Array[File] merged_gvcfs = glob("*.vcf")
    }
}

task GenotypeGVCFs{
    File gatk
    File tabix
    File refFasta
    File refIndex
    File refDict
    Array[File] merged_gvcfs

    command {
        for file in ${sep=' ' merged_gvcfs}; do
            filename=$(basename $file)
            output_filename=$(echo "$filename" | cut -f 1 -d '.')

            java -jar ${gatk} GenotypeGVCFs \
                -R ${refFasta} \
                -V $file \
                -O $output_filename"_genotyped.vcf"
        done
    }

    output {

    }
}