/// EXAMPLE COMMAND
// nextflow run main.nf --vcfs "test_data/*/*/*.g.vcf.gz" --vcfs_tbi "test_data/*/*/*.g.vcf.gz.tbi" --reference "test_data/reference.fa" --reference_fai "test_data/reference.fa.fai" --reference_dict "test_data/reference.dict" -with-docker broadinstitute/gatk:latest

if (params.reference) {
  Channel.fromPath(params.reference)
    .ifEmpty{ exit 1, "We need a reference genome."}
    .into{ reference_genome }
}

if (params.reference_fai) {
  Channel.fromPath(params.reference_fai)
    .ifEmpty{ exit 1, "We need a reference genome fai."}
    .into{ reference_genome_fai }
}

if (params.reference_dict) {
  Channel.fromPath(params.reference_dict)
    .ifEmpty{ exit 1, "We need a reference genome dict."}
    .into{ reference_genome_dict }
}

if (params.vcfs) {
  Channel.fromPath(params.vcfs)
    .ifEmpty{ exit 1, "We need to specify vcf files." }
    .into{ all_vcfs }
}

if (params.vcfs_tbi) {
  Channel.fromPath(params.vcfs_tbi)
      .ifEmpty{ exit 1, "We need to specify vcf files index." }
      .into{ all_vcfs_tbi }
}

//
//process something {
//
//  input:
//  // all vcfs
//  file(vcf) from all_vcfs.collect()
//
//  output:
//  // [HOMER21, MARGE21, BART21]
//
//  script:
//  """
//  echo ${vcf}
//  """
//  // some parsing either bash
//
//}

process combineVcfs {
  container 'broadinstitute/gatk:latest'

  input:
  // [HOMER21, MARGE21, BART21]
  file(ref_dict) from reference_genome_dict
  file(ref_fai) from reference_genome_fai
  file(ref) from reference_genome
  file(vcf) from all_vcfs.collect()
  file(vcf_tbi) from all_vcfs_tbi.collect()

  output:
  file("*.cohort.g.vcf.gz") into someOutputChannel

  script:
  """
  echo ${vcf}
  NV='';
  for k in ${vcf}; do
    NV="\$NV --variant \$k";
  done;
  echo \$NV

   gatk CombineGVCFs \
     -R ${ref} \
     \$NV \
     -O cohort.g.vcf.gz
  """
}
//
//
//process genotypeGVCFs {
//
//  input:
//  // SIMPSONS21.g.vcf
//
//  output:
//  // SIMSONS21.vcf
//
//  script:
//  """
//  gatk --java-options "-Xmx4g" GenotypeGVCFs \
//     -R Homo_sapiens_assembly38.fasta \
//     -V input.g.vcf.gz \
//     -O output.vcf.gz
//  """
//}
//
//process mergeVcf {
//  input:
//  // SIMSPONS.vcf.collect()
//
//  output:
//  // ANOTHER SINGLE FILE SIMSPONS.vcf
//
//  script:
//  """
//  java -jar picard.jar MergeVcfs \
//            I=input_variants.01.vcf.gz \
//            I=input_variants.02.vcf.gz \
//            O=output_variants.vcf.gz
//  """
//}
