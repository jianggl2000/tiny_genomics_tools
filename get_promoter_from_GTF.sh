# This awk script processes a GTF file to extract promoter regions for genes and outputs them in a tab-separated SAF format.
# Promoter is defined as +1500 ~ -500 bp. Change the numbers if you a different regions
#

GTF=/dir/to/your/gtf/gencode.v33.primary_assembly.annotation.gtf

awk 'BEGIN {
    OFS="\t"
    print "GeneID\tChr\tStart\tEnd\tStrand"
}

$3 == "gene" {
    split($0, a, "\t")
    chr = $1
    start = $4
    end = $5
    strand = $7
    
    split(a[9], attrs, ";")
    for (i in attrs) {
        if (attrs[i] ~ /gene_name/) {
            split(attrs[i], gene_name, " ")
            gsub(/"/, "", gene_name[2])
            break
        }
    }
    
    if (strand == "+") {
        promoter_start = start - 500
        promoter_end = start + 1500
    } else if (strand == "-") {
        promoter_start = end - 1500
        promoter_end = end + 500
    }
    
    if (promoter_start < 1) promoter_start = 1
    
    print gene_name[2], chr, promoter_start, promoter_end, strand
}' $GTF > promoters.saf

