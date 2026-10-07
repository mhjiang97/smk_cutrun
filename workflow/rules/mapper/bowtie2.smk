files_bowtie2_index = multiext(
    config["index_bowtie2"],
    ".1.bt2",
    ".2.bt2",
    ".3.bt2",
    ".4.bt2",
    ".rev.1.bt2",
    ".rev.2.bt2",
)

files_bowtie2_index_spikein = multiext(
    config["index_bowtie2_spikein"],
    ".1.bt2",
    ".2.bt2",
    ".3.bt2",
    ".4.bt2",
    ".rev.1.bt2",
    ".rev.2.bt2",
)


rule bowtie2:
    input:
        unpack(get_fastq_files),
        index=ancient(files_bowtie2_index),
    output:
        bam=protected("bowtie2/{sample}/{sample}.sorted.bam"),
        bai=protected("bowtie2/{sample}/{sample}.sorted.bam.csi"),
    log:
        "logs/{sample}/bowtie2.log",
    conda:
        "../../envs/bowtie2.yaml"
    threads: 1
    params:
        prefix=config["index_bowtie2"],
    shell:
        """
        exec 1>{log} 2>&1

        bowtie2 \\
            -p {threads} \\
            -x {params.prefix} \\
            --local \\
            --very-sensitive-local \\
            --no-mixed \\
            --no-discordant \\
            --minins 10 \\
            --maxins 700 \\
            --dovetail \\
            --rg-id {wildcards.sample} \\
            --rg SM:{wildcards.sample} \\
            --rg LB:{wildcards.sample} \\
            --rg PL:ILLUMINA \\
            --rg PU:1 \\
            -1 {input.fq1} \\
            -2 {input.fq2} \\
                | samtools sort -@ {threads} --write-index -o {output.bam} -
        """


rule bowtie2_spikein:
    input:
        unpack(get_fastq_files),
        index=ancient(files_bowtie2_index_spikein),
    output:
        bam=protected("bowtie2/{sample}/{sample}.spikein.sorted.bam"),
        bai=protected("bowtie2/{sample}/{sample}.spikein.sorted.bam.csi"),
    log:
        "logs/{sample}/bowtie2_spikein.log",
    conda:
        "../../envs/bowtie2.yaml"
    threads: 1
    params:
        prefix=config["index_bowtie2_spikein"],
    shell:
        """
        exec 1>{log} 2>&1

        bowtie2 \\
            -p {threads} \\
            -x {params.prefix} \\
            --end-to-end \\
            --very-sensitive \\
            --no-overlap \\
            --no-dovetail \\
            --no-mixed \\
            --no-discordant \\
            --no-unal \\
            --minins 10 \\
            --maxins 700 \\
            --rg-id {wildcards.sample}-spikein \\
            --rg SM:{wildcards.sample}-spikein \\
            --rg LB:{wildcards.sample}-spikein \\
            --rg PL:ILLUMINA \\
            --rg PU:1 \\
            -1 {input.fq1} \\
            -2 {input.fq2} \\
                | samtools sort -@ {threads} --write-index -o {output.bam} -
        """
