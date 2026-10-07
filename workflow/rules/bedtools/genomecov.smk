rule fragment_bedpe:
    input:
        bedpe="bedtools/{sample}/{sample}.clean.bedpe",
    output:
        bedpe="bedtools/{sample}/{sample}.fragment.bedpe",
    log:
        "logs/{sample}/fragment_bedpe.log",
    conda:
        "../../envs/bedtools.yaml"
    shell:
        """
        cut -f 1,2,6 {input.bedpe} \\
            | sort -k1,1 -k2,2n -k3,3n - \\
                1>{output.bedpe} 2>{log}
        """


rule bedtools_genomecov:
    input:
        bedpe="bedtools/{sample}/{sample}.fragment.bedpe",
        fai=f"{config['fasta']}.fai",
    output:
        bedgraph="bedtools/{sample}/{sample}.bedgraph",
    log:
        "logs/{sample}/genomecov.log",
    conda:
        "../../envs/bedtools.yaml"
    shell:
        """
        bedtools genomecov -bg -i {input.bedpe} -g {input.fai} \\
            1>{output.bedgraph} 2>{log}
        """
