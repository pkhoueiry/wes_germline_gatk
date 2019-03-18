#WDL GATK Variant Calling

workflow gatk_variant_calling{

File BAM_LIST
Array[File] BAM_FILE_LIST = read_lines(BAM_LIST)
File SCATTER_CALLING_INTERVALS_LIST
Array[File] scatter_intervals = read_lines(SCATTER_CALLING_INTERVALS_LIST)
File samtools
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
File dbsnp38
File dbsnp38_index
File phase1snps
File phase1snps_index
File mills
File mills_index
File hapmap
File hapmap_index
File omni
File omni_index
File axiom
File axiom_index


scatter (interval in scatter_intervals){
    call haplotypeCaller {
        input: 
            gatk = gatk, 
            refFasta = refFasta, 
            refIndex = refIndex, 
            refDict = refDict,
            samtools = samtools,
            interval_list = interval,
            recal_bam = BAM_FILE_LIST
  }
}

    # call VariantFiltration {
    #     input:
    #         gatk = gatk,
    #         refFasta = refFasta, 
    #         refIndex = refIndex, 
    #         refDict = refDict,
    #         sampleName = "genotyped_VF",
    #         genotyped = GenotypeGVCFs.genotyped,
    #         genotyped_index = GenotypeGVCFs.genotyped_index
    # }

    # call VariantRecalibratorSNP {
    #     input:
    #         gatk = gatk,
    #         genotyped_VF = VariantFiltration.genotyped_VF,
    #         genotyped_VF_index = VariantFiltration.genotyped_VF_index,
    #         dbsnp38 = dbsnp38,
    #         dbsnp38_index = dbsnp38_index,
    #         phase1snps = phase1snps,
    #         phase1snps_index = phase1snps_index,
    #         hapmap = hapmap,
    #         hapmap_index = hapmap_index,
    #         omni = omni,
    #         omni_index = omni_index,
    #         sampleName = "genotyped_VF_VR"
    # }

    # call applyVQSR_snp {
    #     input:
    #         gatk = gatk,
    #         genotyped_VF = VariantFiltration.genotyped_VF,
    #         genotyped_VF_index = VariantFiltration.genotyped_VF_index,
    #         snp_recal = VariantRecalibratorSNP.snp_recal,
    #         snp_recal_index = VariantRecalibratorSNP.snp_recal_index,
    #         snp_tranches = VariantRecalibratorSNP.snp_tranches,
    #         sampleName = "genotyped_VF_VR"
    # }

    # call VariantRecalibratorINDEL {
    #     input:
    #         gatk = gatk,
    #         genotyped_VF = VariantFiltration.genotyped_VF,
    #         genotyped_VF_index = VariantFiltration.genotyped_VF_index,
    #         dbsnp38 = dbsnp38,
    #         dbsnp38_index = dbsnp38_index,
    #         mills = mills,
    #         mills_index = mills_index,
    #         axiom = axiom,
    #         axiom_index = axiom_index,
    #         sampleName = "genotyped_VF_VR"
    # }

    # call applyVQSR_indel {
    #     input:
    #         gatk = gatk,
    #         genotyped_VF = VariantFiltration.genotyped_VF,
    #         genotyped_VF_index = VariantFiltration.genotyped_VF_index,
    #         indel_recal = VariantRecalibratorINDEL.indel_recal,
    #         indel_recal_index = VariantRecalibratorINDEL.indel_recal_index,
    #         indel_tranches = VariantRecalibratorINDEL.indel_tranches,
    #         sampleName = "genotyped_VF_VR"
    # }

}

task haplotypeCaller {
    File gatk
    File refFasta
    File refIndex
    File refDict
    Array[File] recal_bam
    File interval_list
    File samtools
  
    command {
    for file in ${sep=' ' recal_bam}; do
        ${samtools} index -@ 2 $file
        
        filename=$(basename $file)
        output_filename=$(echo "$filename" | cut -f 1 -d '_')
        
        java -jar ${gatk} HaplotypeCaller \
          -R ${refFasta} \
          -I $file \
          -L ${interval_list} \
          -O $output_filename".g.vcf" \
          -ERC GVCF
    done
  }
    output {

  }
}

# task VariantFiltration{
#     File gatk
#     File refFasta
#     File refIndex
#     File refDict
#     File genotyped
#     File genotyped_index
#     String sampleName

#     command {
#         java -jar ${gatk} VariantFiltration \
#           -R ${refFasta} \
#           --filter-expression "ExcessHet > 54.69" \
#           --filter-name ExcessHet \
#           -V ${genotyped} \
#           -O ${sampleName}_VF.vcf
#     }

#     output {
#         File genotyped_VF = "${sampleName}_VF.vcf"
#         File genotyped_VF_index = "${sampleName}_VF.vcf.idx"

#     }
# }

# task VariantRecalibratorSNP{
#     File gatk
#     File genotyped_VF
#     File genotyped_VF_index
#     File dbsnp38
#     File dbsnp38_index
#     File phase1snps
#     File phase1snps_index
#     File hapmap
#     File hapmap_index
#     File omni
#     File omni_index
#     String sampleName

#     command {
#         java -jar ${gatk} VariantRecalibrator \
#           -V ${genotyped_VF} \
#           -resource hapmap,known=false,training=true,truth=true,prior=15:${hapmap} \
#           -resource omni,known=false,training=true,truth=true,prior=12:${omni} \
#           -resource 1000G,known=false,training=true,truth=false,prior=10:${phase1snps} \
#           -resource dbsnp,known=true,training=false,truth=false,prior=2:${dbsnp38} \
#           -mode SNP \
#           -tranche 100.0 \
# 		  -tranche 99.95 \
# 		  -tranche 99.9 \
# 		  -tranche 99.6 \
# 		  -tranche 99.5 \
# 		  -tranche 99.4 \
# 		  -tranche 99.3 \
# 		  -tranche 99.0 \
# 		  -tranche 98.0 \
# 		  -tranche 97.0 \
# 		  -tranche 90.0 \
#           -an QD -an MQRankSum -an ReadPosRankSum -an FS -an SOR \
#           --output-model ${sampleName}_snp.model.report \
#           --tranches-file ${sampleName}_snp.tranches \
#           -O ${sampleName}_snp.recal
#     }

#     output {
#         File snp_recal = "${sampleName}_snp.recal"
#         File snp_recal_index = "${sampleName}_snp.recal.idx"
#         File snp_tranches = "${sampleName}_snp.tranches"
#     }
# }

# task applyVQSR_snp{
#     File gatk
#     File genotyped_VF
#     File genotyped_VF_index
#     File snp_recal
#     File snp_recal_index
#     File snp_tranches
#     String sampleName
    
#     command {
#         java -jar ${gatk} ApplyVQSR \
#             -V ${genotyped_VF} \
#             --recal-file ${snp_recal} \
#             --tranches-file ${snp_tranches} \
#             -mode SNP \
#             -O ${sampleName}_final_snp.vcf
#     }

#     output {
#         File snp_final = "${sampleName}_final_snp.vcf"
#         File snp_final_index = "${sampleName}_final_snp.vcf.idx"

#     }
# }


# task VariantRecalibratorINDEL{
#     File gatk
#     File genotyped_VF
#     File genotyped_VF_index
#     String sampleName
#     File mills
#     File mills_index
#     File dbsnp38
#     File dbsnp38_index
#     File axiom
#     File axiom_index

#     command {
#         java -jar ${gatk} VariantRecalibrator \
#         -V ${genotyped_VF} \
#         -resource mills,known=false,training=true,truth=true,prior=12:${mills} \
# 		-resource axiomPoly,known=false,training=true,truth=false,prior=10:${axiom} \
# 		-resource dbsnp,known=true,training=false,truth=false,prior=2:${dbsnp38} \
#         -mode INDEL \
#         -tranche 100.0 \
# 		-tranche 99.95 \
# 		-tranche 99.9 \
# 		-tranche 99.6 \
# 		-tranche 99.5 \
# 		-tranche 99.4 \
# 		-tranche 99.3 \
# 		-tranche 99.0 \
# 		-tranche 98.0 \
# 		-tranche 97.0 \
# 		-tranche 90.0 \
# 		-an QD -an DP -an FS -an SOR -an ReadPosRankSum -an MQRankSum \
#         --max-gaussians 4 \
#         --output-model ${sampleName}_indel.model.report \
#         --tranches-file ${sampleName}_indel.tranches \
#         -O ${sampleName}_indel.recal
#     }

#     output {
#         File indel_recal = "${sampleName}_indel.recal"
#         File indel_recal_index = "${sampleName}_indel.recal.idx"
#         File indel_tranches = "${sampleName}_indel.tranches"
#     }
# }

# task applyVQSR_indel{
#     File gatk
#     File genotyped_VF
#     File genotyped_VF_index
#     File indel_recal
#     File indel_recal_index
#     File indel_tranches
#     String sampleName

#     command {
#         java -jar ${gatk} ApplyVQSR \
#             -V ${genotyped_VF} \
#             --recal-file ${indel_recal} \
#             --tranches-file ${indel_tranches} \
#             -mode INDEL \
#             -O ${sampleName}_final_indel.vcf
#     }

#     output {
#         File indel_final = "${sampleName}_final_indel.vcf"
#         File indel_final_index = "${sampleName}_final_indel.vcf.idx"
#     }
#}