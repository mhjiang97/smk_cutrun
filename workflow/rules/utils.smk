def get_filtered_bam(sample):
    decision = checkpoints.check_duplication_rate.get(sample=sample).output.txt

    with open(decision) as fh:
        infix = ".md" if fh.read().strip() == "remove" else ""

    return f"bowtie2/{sample}/{sample}.sorted{infix}.filtered.bam"


def get_targets():
    targets = []

    # targets += [get_filtered_bam(sample) for sample in SAMPLES]
    targets += [
        f"bowtie2/{sample}/{sample}.spikein.sorted.bam" for sample in SAMPLES
    ]
    targets += [f"seacr/{sample}/{sample}.stringent.bed" for sample in SAMPLES]

    if TO_CLEAN_FQ:
        targets += [f"fastp/{sample}/{sample}.json" for sample in SAMPLES]
        if TO_RUN_FASTQC:
            targets += [f"fastqc/fastp/{sample}" for sample in SAMPLES]
            if TO_RUN_MULTIQC:
                targets += ["multiqc/fastp/multiqc_report.html"]
    else:
        if TO_RUN_FASTQC:
            targets += [f"fastqc/{sample}" for sample in SAMPLES]
            if TO_RUN_MULTIQC:
                targets += ["multiqc/multiqc_report.html"]

    return targets


def get_fastq_files(wildcards, named=True):
    sample = wildcards.sample
    dir_base = "fastp/{sample}" if TO_CLEAN_FQ else DIR_DATA

    if named:
        return {
            "fq1": f"{dir_base}/{{sample}}_R1.fq.gz",
            "fq2": f"{dir_base}/{{sample}}_R2.fq.gz",
        }
    else:
        return [f"{dir_base}/{{sample}}_R1.fq.gz", f"{dir_base}/{{sample}}_R2.fq.gz"]


def get_extra_arguments(rule_name):
    if "args_extra" in config and rule_name in config["args_extra"]:
        return config["args_extra"][rule_name]

    return ""
