#Illumiprocessor - trimming adapters and low qaulity bases from raw fastq files
create config file containing adapters, tag (i7 & i5 barcode) sequences, tag map, and new names for fastq files
critical part is Illumiprocessor accepts fastq files only in a particular name format, ex. XXXXXXXX_XX_R1/R2_001.fastq.gz. Thus, rename all fastq files to the required format, ex. SL409988_s4_1_R1/R2_001.fastq.gz
use sample ID or genus_species name information to name the output trimmed fastq file 
note : avoid full stop (.) in genus_species naming. use only underscore (_)
root@DESKTOP-UEBV6LS:/mnt/c/Users/Niemiller$ Downloads/yes/bin/illumiprocessor --input Desktop/Pseudanophthalmus/FastQ/ --output Desktop/Pseudanophthalmus/FastQ/ --config Desktop/Pseudanophthalmus/illumiprocessor.conf --cores 12

#Abyss assembly - assembling reads to contigs and scaffolds
create config file with genus_species name to name the output file and location of the corresponding trimmed fastq file 
make 'Abyss_assembly_log' directory for log file
note : the phyluce_assembly_assemblo_abyss code was tweaked slightly to bypass an IOerror
niemiller@DESKTOP-UEBV6LS:/mnt/c/Users/Niemiller$ Downloads/yes/bin/phyluce_assembly_assemblo_abyss --config Desktop/Pseudanophthalmus/abyss.conf --output Desktop/Pseudanophthalmus/Abyss_assembly --kmer 60 --cores 12 --clean --log-path Desktop/Pseudanophthalmus/Abyss_assembly_log/

#Assembly QC
niemiller@DESKTOP-UEBV6LS:/mnt/c/Users/Niemiller$ for i in Desktop/Pseudanophthalmus/Abyss_assembly/contigs/*.fasta; do Downloads/yes/bin/phyluce_assembly_get_fasta_lengths --input $i --csv; done

#Finding UCE loci 
download the UCE probe sets (beetle order : Coleoptera) fasta sequences from https://www.ultraconserved.org/
make 'UCE_contigs_log' directory for log file
niemiller@DESKTOP-UEBV6LS:/mnt/c/Users/Niemiller$ Downloads/yes/bin/phyluce_assembly_match_contigs_to_probes --contigs Desktop/Pseudanophthalmus/Abyss_assembly/contigs/ --probes Desktop/Pseudanophthalmus/ColeopteraUCE1.1Kv1.fasta/Coleoptera-UCE-1.1K-v1.fasta --output Desktop/Pseudanophthalmus/UCE_contigs --log-path Desktop/Pseudanophthalmus/UCE_contigs_log/

#Creating a incomplete data matrix configuration file
create config file with genus_species name - all 48 taxa
make 'taxon-set' directory for output
niemiller@DESKTOP-UEBV6LS:/mnt/c/Users/Niemiller$ Downloads/yes/bin/phyluce_assembly_get_match_counts --locus-db Desktop/Pseudanophthalmus/UCE_contigs/probe.matches.sqlite --taxon-list-config Desktop/Pseudanophthalmus/datasets.conf --taxon-group 'dataset' --output Desktop/Pseudanophthalmus/Taxon_set/dataset.conf --incomplete-matrix

#Extracting FASTA data using the data matrix configuration file
niemiller@DESKTOP-UEBV6LS:/mnt/c/Users/Niemiller$ Downloads/yes/bin/phyluce_assembly_get_fastas_from_match_counts --contigs Desktop/Pseudanophthalmus/Abyss_assembly/contigs/ --locus-db Desktop/Pseudanophthalmus/UCE_contigs/probe.matches.sqlite --match-count-output Desktop/Pseudanophthalmus/Taxon_set/dataset.conf --incomplete-matrix Desktop/Pseudanophthalmus/Taxon_set/dataset.incomplete --output Desktop/Pseudanophthalmus/Taxon_set/dataset.fasta

#Exploding the monolithic FASTA file
niemiller@DESKTOP-UEBV6LS:/mnt/c/Users/Niemiller$ Downloads/yes/bin/phyluce_assembly_explode_get_fastas_file --input Desktop/Pseudanophthalmus/Taxon_set/dataset.fasta --output Desktop/Pseudanophthalmus/Taxon_set/exploded-fastas --by-taxon

#Summary stats on UCE assemblies
niemiller@DESKTOP-UEBV6LS:/mnt/c/Users/Niemiller$ for i in Desktop/Pseudanophthalmus/Taxon_set/exploded-fastas/*.fasta; do Downloads/yes/bin/phyluce_assembly_get_fasta_lengths --input $i --csv; done

#Aligning and trimming FASTA data
niemiller@DESKTOP-UEBV6LS:/mnt/c/Users/Niemiller$ Downloads/yes/bin/phyluce_align_seqcap_align --fasta Desktop/Pseudanophthalmus/Taxon_set/dataset.fasta --output Desktop/Pseudanophthalmus/Taxon_set/mafft-nexus/ --taxa 48 --aligner mafft --cores 12 --incomplete-matrix

#Alignment stats
niemiller@DESKTOP-UEBV6LS:/mnt/c/Users/Niemiller$ Downloads/yes/bin/phyluce_align_get_align_summary_data --alignments Desktop/Pseudanophthalmus/Taxon_set/mafft-nexus/ --cores 12

#Removing locus name
niemiller@DESKTOP-UEBV6LS:/mnt/c/Users/Niemiller$ Downloads/yes/bin/phyluce_align_remove_locus_name_from_nexus_lines --alignments Desktop/Pseudanophthalmus/Taxon_set/mafft-nexus/ --output Desktop/Pseudanophthalmus/Taxon_set/mafft-nexus-clean --cores 12

#Finalizing matrix completeness
niemiller@DESKTOP-UEBV6LS:/mnt/c/Users/Niemiller$ Downloads/yes/bin/phyluce_align_get_only_loci_with_min_taxa --alignments Desktop/Pseudanophthalmus/Taxon_set/mafft-nexus-clean/ --taxa 48 --percent 0.75 --output Desktop/Pseudanophthalmus/Taxon_set/mafft-nexus-min-25-taxa --cores 12

#Preparing alignment data for analysis
niemiller@DESKTOP-UEBV6LS:/mnt/c/Users/Niemiller$ Downloads/yes/bin/phyluce_align_format_nexus_files_for_raxml --alignments Desktop/Pseudanophthalmus/Taxon_set/mafft-nexus-min-25-taxa/ --output Desktop/Pseudanophthalmus/Taxon_set/mafft-raxml
