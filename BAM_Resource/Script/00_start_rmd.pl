#!/bin/perl

use strict;
use warnings;

if ( 1 != @ARGV ) {
    printUsage();
}

my %info;
my $in_config = $ARGV[0];
read_config ($in_config, \%info);

my $project_path = $info{project_path};
my $result_path = "$project_path/result/";
my $html_report_path = "$result_path/61_html_report/";
mkdir_dir($html_report_path);

my $author = $info{author};

my $total_rmd_file = "$html_report_path/html_report.Rmd";
open my $fh_html,'>',$total_rmd_file or die;

print $fh_html "---\n";
print $fh_html "title: \"General BAM File\"\n";
print $fh_html "author: \"[$author](http://theragenetex.com)\"\n";
print $fh_html "date: \"\`r Sys.Date()\`\"\n";
print $fh_html "output: \n";
print $fh_html "\tpdf_document: \n";
print $fh_html "\t\ttoc: true \n";
print $fh_html "\t\tnumber_sections: true \n";
print $fh_html "\t\ttoc_depth: 2 \n";
print $fh_html "\t\ttheme: united \n";
print $fh_html "\t\thighlight: zenburn \n";
print $fh_html "---\n\n";

print $fh_html "\`\`\`{r opt, cache=FALSE, echo=FALSE}\n";
print $fh_html "library(knitr)\n";
print $fh_html "library(rmarkdown)\n";
print $fh_html "knitr::opts_chunk\$set(tidy=TRUE, highlight=TRUE, dev=\"png\", \\\n";
print $fh_html "cache=FALSE, highlight=TRUE, autodep=TRUE, \\\n";
print $fh_html "warning=FALSE, error=FALSE, \\\n";
print $fh_html "eval=TURE, fig.width=9, echo=FALSE, \\\n";
print $fh_html "verbose=FALSE, \\\n";
print $fh_html "message=FALSE, prompt=TRUE, comment=\'\',fig.cap=\'\',bootstrap.show.code=FALSE) \\\n";
print $fh_html "\`\`\`\n\n";

print $fh_html "\`\`\`{r custom. results=\'hide\'}\n";
print $fh_html "library(ggplot2);library(pheatmap);library(scales);library(gridExtra)\n";
print $fh_html "library(gtools);library(RColorBrewer);library(knitr);library(tidyr)\n";
print $fh_html "library(reshape2);library(rmarkdown);library(dplyr);library(DT)\n\n";

print $fh_html "number_ticks \<\- function(n) {function(limits) pretty(limits, n)} \n";
print $fh_html "options(bitmapType = \'cairo\')\n\n";

print $fh_html "path_result = \"$result_path\\n";
print $fh_html "\`\`\`\n\n";

print $fh_html "\`\`\`{r creat-report, echo=FALSE, eval=FALSE}\n";
print $fh_html "render(file.path(path_result,\"report-ready.Rmd\"))\n";
print $fh_html "\`\`\`\n\n";

close $fh_html;

sub mkdir_dir {
    my $dir_name = shift;
    unless (-d $dir_name){
        my $cmd_dir = "mkdir -p $dir_name";
        system($cmd_dir);
    }
}

sub read_config {
    my ($config, $hash_ref) = @_;
    open my $fh, '<:encoding(UTF-8)', $config or die;
    while (my $row = <$fh>){
        chomp $row;
        if ($row =~ /^#/) {next;}
        if (length($row) == 0) {next;}
        my ($key, $value) = split /\=/, $row;
        $key = trim ($key);
        $value = trim ($value);
        $hash_ref->{$key}=$value;
    }
    close ($fh);
}

sub trim {
    my @result = @_;
    foreach (@result) {
        s/^\s+//;
        s/\s+$//;
    }
    return wantarray ? @result:$result[0];
}

sub printUsage {
    print "Usage: perl $0 <in.config> \n";
    print "Example: perl $0 wes_config_human.txt \n";
    exit;
}

