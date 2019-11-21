//params.referenceGenome = 'some.fasta'
//params.vcfs = 'test_data/*/*/*.g.vcf.gz'

if (params.reference) {
  Channel.fromPath(params.reference)
    .ifEmpty{ exit 1, "We need a reference genome."}
    .into{ reference_genome }
}

if (params.vcfs) {
  Channel.fromPath(params.vcfs)
    .ifEmpty{ exit 1, "We need to specify vcf files." }
    .into{ all_vcfs }
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
  file(ref) from reference_genome
  file(vcf) from all_vcfs.collect()

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
