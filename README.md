# nf-core/cnvfinder

## Introduction

**nf-core/cnvfinder** is a bioinformatics pipeline for detecting copy number variants (CNVs) in bacterial genomes from short-read sequencing data. Given paired reads and a matching genome assembly for each sample, the pipeline:

1. **QCs reads** – optionally downloads reads from the SRA/ENA, trims reads with fastp, runs FastQC and collates these outputs into a MultiQC report (reads and assemblies can optionally be downloaded ahead of time via a helper script — see Usage below)
2. **Builds a reference configuration** – generates a GC file and a CNVpytor-compatible configuration file for each assembly 
3. **Maps reads to the reference** – indexes the assembly, maps trimmed reads, converts SAM to BAM, and assesses mapping quality
4. **Calls copy number variants** – partitions the genome into bins (default 100 bp) and calls CNVs with [CNVpytor](https://github.com/abyzovlab/CNVpytor)

## Usage

> [!NOTE]
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/get_started/environment_setup/overview) on how to set up Nextflow. Make sure to test your setup with `-profile test` before running on real data.

### Input data

The pipeline takes **matched read and assembly pairs** rather than a standard samplesheet. Prepare:

- A CSV file (passed via `--accessions`) with two columns: read name and assembly name
- Read files named `<read_name>.fastq.gz`, placed in a folder called `reads/`
- Assembly files named `<assembly_name>.fasta` / `.fa` / `.fna`, placed in a folder called `assemblies/`

**Example `accessions.csv`:**

```csv
read_name,assembly_name
sample1_reads,sample1_assembly
sample2_reads,sample2_assembly
```

### Downloading data automatically (optional)

If your `accessions.csv` contains SRA accessions and BioSample IDs instead of local file names, reads and assemblies need to be downloaded **before** running the pipeline. A ready-made accessions file can be pulled straight from [NCBI/SRA](https://www.ncbi.nlm.nih.gov/sra): filter for the genomes you want, then use *Send to → File → RunInfo*. The downloaded file will contain `Run` and `BioSample` columns — copy those two columns into your `accessions.csv`.

Run:

```bash
bin/both_downloads.sh accessions.csv
```

This downloads reads from SRA/ENA (via iSeq) and, separately, downloads the matching assembly from [AllTheBacteria](https://www.allthebacteria.org) by BioSample name. Both are handled by this script but are downloaded as two distinct steps, run this ahead of the pipeline itself — the pipeline does not fetch assemblies during execution.

> [!NOTE]
> This requires `iSeq` installed and activated via conda.

If you already have your own reads and assemblies locally (e.g. private data), skip this step and set `--skip_download true`.

### Running the pipeline

```bash
nextflow run nf-core/cnvfinder \
   -profile <docker/apptainer/slurm> \
   --accessions accessions.csv \
   --outdir <OUTDIR>
```

### Parameters

| Parameter        | Description                                                                 | Default                |
| ----------------- | ---------------------------------------------------------------------------- | ----------------------- |
| `--accessions`    | CSV file mapping read names to assembly names (see format above)             | *required*              |
| `--profile`       | Execution profile: `docker`, `apptainer`, or `slurm`                        | *required*              |
| `--fasta`         | File extension of assemblies (e.g. `.fasta`, `.fa`, `.fna`)                  | `fa`                       |
| `--skip_download` | Skip automatic download of reads/assemblies (use for private/local data)     | `false`                 |
| `--bin_size`      | Read-depth bin size for CNV calling. Must be a multiple of 100.              | `100`                   |
| `--species`       | Target species (string)                                                     | `Klebsiella pneumoniae` |


## Pipeline output

Results are organised into the following subfolders of `--outdir`:

| Folder                       | Contents                                                            |
| ------------------------------ | ---------------------------------------------------------------------- |
| `calls/`                     | `.tsv` files of predicted CNVs, output by CNVpytor                  |
| `configs/`                   | CNVpytor genome configuration file (`.py`) for each strain          |
| `GC_files/`                  | CNVpytor `.pytor` files used in reference configuration             |
| `metadata/`                  | Per-strain metadata `.tsv` files from SRA/ENA download               |
| `Pytors/`                    | CNVpytor `.py` reference files                                       |
| `QC/`                        | FastQC logs/outputs, plus `samtools depth`/coverage files            |
| `Reads/`                     | Raw reads downloaded from SRA/ENA                                    |
| `Results/multiQC/`           | MultiQC summary report (`.html`)                                     |
| `Results/pipeline_info/`     | Pipeline execution report and software versions                      |
| `SAMs/`                      | SAM files from read mapping                                           |
| `Trimmed_reads/`             | Trimmed FASTQ read files                                              |


## Credits

nf-core/cnvfinder was originally written by Sarah Cameron.

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](docs/CONTRIBUTING.md).

## Citations

An extensive list of references for the tools used by the pipeline can be found in [`CITATIONS.md`](CITATIONS.md).

You can cite the `nf-core` publication as follows:

> **The nf-core framework for community-curated bioinformatics pipelines.**
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
> *Nat Biotechnol.* 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).nity-curated bioinformatics pipelines.**
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
> *Nat Biotechnol.* 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
