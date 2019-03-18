#!/bin/bash

projectDir=$1

##create a directory called "gvcfs" where we gather all gvcfs in one place by creating hard link
echo ${projectDir}/
mkdir ${projectDir}/gvcfs/
for f in ${projectDir}/cromwell-executions/gatk_variant_calling/*/call-haplotypeCaller/shard-*/execution/*.g.vcf; do 
    foldername="$f";
    
    file=${foldername##*/}
    parent=${foldername#*"${foldername%/*/"$file"}"/}
    shard=${foldername#*"${foldername%/*/"$parent"}"/}
    
    folder=$(echo "$shard" | cut -f 1 -d'/');

    filename=$(basename $f);
    filename1=$(echo "$filename" | cut -f 1 -d '.');
    echo $filename1;
    mkdir "$projectDir/gvcfs/$folder/"; 
    ln -P $f "$projectDir/gvcfs/$folder/";
done

##after gathering gvcfs, we do rename them according to their location
##then we remove the "gvcfs" directory created above
mkdir ${projectDir}/allgvcfs/
for gf in ${projectDir}/gvcfs/shard-*/*.g.vcf; do
    parent_name=$gf;
    echo ${parent_name};

    file=${parent_name##*/}
    parent_dir=${parent_name#*"${parent_name%/*/"$file"}"/}
    shard=${foldername#*"${foldername%/*/"$parent"}"/}
    echo $shard;
    parent=$(echo "$parent_dir" | cut -f 1 -d'/');
    file_name=$(basename $gf);
    filename2=$(echo "$file_name" | cut -f 1 -d '.');
    name=${parent}_${filename2};
    mv $gf "$projectDir/allgvcfs/$name.g.vcf";
done

rm -rf ${projectDir}/gvcfs

#create a list of gvcfs full paths
for f in ${projectDir}/allgvcfs/*.g.vcf ; do
    echo "$f" >> ${projectDir}/lists/gvcfs.txt; 
done

#get samples names
cut -f 1 ${projectDir}/lists/fastq_list.txt > ${projectDir}/lists/samples_names.txt

#from the list created above, we just split each sample in a text file
while IFS= read -r line; do
	line+=".g.vcf"	
	grep -F "${line}" ${projectDir}/lists/gvcfs.txt >> ${projectDir}/lists/$line.list;
done < ${projectDir}/lists/samples_names.txt

for f in ${projectDir}/lists/*.g.vcf.list; do 
        bn=$(basename $f | cut -f 1 -d"."); mv $f ${projectDir}/lists/$bn.list;
done

#creating list of lists
for f in ${projectDir}/lists/*.list ; do
    echo $f >> ${projectDir}/lists/gvcfs_samples_lists.list
done

rm -f ${projectDir}/lists/gvcfs.txt
echo "GVCFs are ready"
