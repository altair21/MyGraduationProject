import string
import sys
from pygr import seqdb
from pygr import worldbase
from optparse import OptionParser

exon_in_selector = []
patient_in_selector = []

def process_command_line(argv):
   parser = OptionParser()
   parser.add_option("-i", "--file", dest="input_filename", help="MAF file")
   parser.add_option("-a","--annotation", dest="annotation_file", help="GTF file from ensembl")
   parser.add_option("-r","--reference", dest="genome_reference_file", help="a genome reference file in fasta format")
   parser.add_option("-o","--output",dest="output_prefix", help="output_prefix")

   (options, args) = parser.parse_args()

   return options, args

def read_ensembl_annotation(ensembl_file):
   tx_dic = {}
   gene_dic = {}
   start_codon_dic = {}
   stop_codon_dic = {}

   for line in open(ensembl_file):
      if line[0] == "#":
         continue
      line_ele = string.split(string.strip(line),'\t')

      if string.find(line_ele[0], 'chr') == -1:
         chr = 'chr'+line_ele[0]
      else:
         chr = line_ele[0]   

      tx_type = line_ele[1]
      
      #if tx_type != "ensembl":
      #   continue
      
      exon_type = line_ele[2]
      exon_start_coor = int(line_ele[3])
      exon_end_coor = int(line_ele[4])
      strand = line_ele[6]
      exon_info = [string.split(ele) for ele in string.split(line_ele[8][:-1],';')]
      exon_info_dic = {}
      
      try:
         for ele in exon_info:
            exon_info_dic.setdefault(ele[0],ele[1].replace("\"",""))
      except IndexError:
         continue
      
      #print exon_info_dic
      gene_biotype = exon_info_dic["gene_biotype"]
      if gene_biotype != "protein_coding":
         continue

      try:
         tx_id = exon_info_dic["transcript_id"]
         gene_id = exon_info_dic["gene_id"]
         gene_name = exon_info_dic["gene_name"]
      except KeyError:
         continue

      if exon_type == "start_codon":
         if strand == "+":
            start_codon_coor = exon_start_coor
         elif strand == "-":
            start_codon_coor = exon_end_coor

         start_codon_dic.setdefault(gene_id,{})
         start_codon_dic[gene_id].setdefault(tx_id,[])
         if (chr,strand,start_codon_coor) not in start_codon_dic[gene_id][tx_id]:
               start_codon_dic[gene_id][tx_id].append((chr,strand,start_codon_coor))

      elif exon_type == "stop_codon":
         if strand == "+":
            stop_codon_coor = exon_end_coor
         elif strand == "-":
            stop_codon_coor = exon_start_coor

         stop_codon_dic.setdefault(gene_id,{})
         stop_codon_dic[gene_id].setdefault(tx_id,[])
         if (chr,strand,stop_codon_coor) not in stop_codon_dic[gene_id][tx_id]:
            stop_codon_dic[gene_id][tx_id].append((chr,strand,stop_codon_coor))         
      
      elif exon_type == "exon":
         bin_id = exon_start_coor/100000
         tx_dic.setdefault(chr,{})
         tx_dic[chr].setdefault(strand,{})
         tx_dic[chr][strand].setdefault(bin_id,{})
         if bin_id < 10:
            bin_range = range(0,bin_id+10)
         else:
            bin_range = range(bin_id-10,bin_id+10)
         flag = 0
         for i in bin_range:
            if tx_dic[chr][strand].has_key(i):
               if tx_dic[chr][strand][i].has_key(gene_id): 
                  tx_dic[chr][strand][i].setdefault(gene_id,{})
                  tx_dic[chr][strand][i][gene_id].setdefault(tx_id,[])
                  tx_dic[chr][strand][i][gene_id][tx_id].append((exon_start_coor,exon_end_coor))
                  flag = 1
                  break
         if flag == 0:
            tx_dic[chr][strand][bin_id].setdefault(gene_id,{})
            tx_dic[chr][strand][bin_id][gene_id].setdefault(tx_id,[])               
            tx_dic[chr][strand][bin_id][gene_id][tx_id].append((exon_start_coor,exon_end_coor))
 
   #return (tx_dic, start_codon_dic, stop_codon_dic) 
   return tx_dic

def retrieve_exon_sequence(exon_coor_info, reference_file): #exon_coor_info include chromosome id, strand, exon start and exon end
   
   #hg38 = seqdb.SequenceFileDB('/home/jwan/workspace/genome_seq/hg38/hg38.fa')
   hg38 = seqdb.SequenceFileDB(reference_file)
   hg38.__doc__ = "human genome sequence 38"
   worldbase.Bio.Seq.Genome.Human.hg38 = hg38
   worldbase.commit()   

   (chr,strand,exon_start,exon_end, HUGO_symbol, ensembl_gene, ensembl_tx) = exon_coor_info
   nt_list = []
   if strand == "+":

      for i in range(exon_start, exon_end +1):
         try:
            nt = string.upper(str(hg38[chr][i-1])) #convert 1-based to 0-based coordinate
            nt_list.append(nt)
         except IndexError:
            break
           
      sequence = string.join(nt_list,"")

   elif strand == "-":

      for i in range(exon_end, exon_start -1, -1):
         try:
            nt = string.upper(str(-hg38[chr][i-1]))
            nt_list.append(nt)
         except IndexError:
            break

      sequence = string.join(nt_list,"")
   return sequence  

def retreive_SNV_exon_info(SNV_coor_info,tx_annotation_dic):
   
   (chr_no, strand, start_coor, end_coor, HUGO_symbol, ensembl_gene, ensembl_tx) = SNV_coor_info
   bin_id = start_coor/100000
   
   #print ensembl_gene,ensembl_tx
   if bin_id < 10:
      bin_range = range(0,bin_id+10)
   else:
      bin_range = range(bin_id-10,bin_id+10)   
   if tx_annotation_dic.has_key(chr_no):
      if tx_annotation_dic[chr_no].has_key(strand):
          
         for i in bin_range:
            if tx_annotation_dic[chr_no][strand].has_key(i):
              #print tx_annotation_dic[chr_no][strand][i]  
               try:
                  for (exon_start,exon_end) in tx_annotation_dic[chr_no][strand][i][ensembl_gene][ensembl_tx]:
                     if exon_start <= start_coor <= end_coor <= exon_end:
                        #print exon_start,start_coor,end_coor,exon_end 
                        return (chr_no,strand,exon_start,exon_end, HUGO_symbol, ensembl_gene, ensembl_tx)
               except KeyError:
                  #print i    
                  continue  
   return ()

def calculate_RI(exon_SNV_dic):
   exon_RI_dic = {}
   patient_exon_dic = {}
   
   for exon_info in exon_SNV_dic:
      patient_list = []
      exon_length = exon_info[3] - exon_info[2] + 1
      for SNV_coor_info in exon_SNV_dic[exon_info]:
         for SNV_basic_info in exon_SNV_dic[exon_info][SNV_coor_info]:
            patient_list.append(SNV_basic_info[0]) #TCGA UUID
      num_patient_covered = len(patient_list)
      RI = float(num_patient_covered * 1000)/exon_length
      exon_RI_dic.setdefault(exon_info,(num_patient_covered,RI,patient_list))
      patient_exon_dic.setdefault(num_patient_covered,{})
      patient_exon_dic[num_patient_covered].setdefault(RI,[])
      patient_exon_dic[num_patient_covered][RI].append((exon_info,patient_list))
   return (exon_RI_dic,patient_exon_dic)         

def iterative_selector(exon_RI_dic, patient_exon_dic, patient_cutoff):
   
   high_coverage_RI_dic = {}
   #patient_in_selector = []
   #exon_in_selector = []

   for num_patient_covered in patient_exon_dic:
      if num_patient_covered > patient_cutoff:
         for RI in patient_exon_dic[num_patient_covered]:
            high_coverage_RI_dic.setdefault(RI,patient_exon_dic[num_patient_covered][RI])
   
   sorted_RI_list = sorted(high_coverage_RI_dic,reverse=True)
   
   while True:
      flag = 0
      for RI in sorted_RI_list:
         min_overlap_num = 10000
         difference_patient_list = []
         exon_info_min_overlap = ()
         for (exon_info, patient_list) in high_coverage_RI_dic[RI]:

            if exon_info in exon_in_selector:
               continue

            if len(patient_list) <= patient_cutoff:
               continue

            difference_patient_list = list(set(patient_list) - set(patient_in_selector))
            if len(difference_patient_list) == 0: # no increment, next
               continue
            overlap_patient_list = list(set(patient_in_selector).intersection(patient_list))
            overlap_patient_num = len(overlap_patient_list)

            if overlap_patient_num < min_overlap_num:
               min_overlap_num = overlap_patient_num
               exon_info_min_overlap = exon_info
               patient_list_min_overlap = patient_list
         
         if exon_info_min_overlap != ():
            exon_in_selector.append(exon_info_min_overlap)               
            patient_in_selector.extend(difference_patient_list)
            flag = 1  
            break

      if flag == 0:
         break
     
   return   

def iterative_selector_single_SNV_reduction(patient_exon_SNV_dic, exon_SNV_patient_dic, exon_RI_dic, RI_cutoff):


   while True:
      max_reduced_num = 0
      RI_max_reduced = 0
      exon_max_reduced = ()
      for exon_info in exon_RI_dic:
         if exon_info in exon_in_selector:
            continue
         RI = exon_RI_dic[exon_info][1]
         #print RI

         if RI < RI_cutoff:
            continue
         
         reduced_patient_dic = {}
         list_reduced_single_SNV_patient = []


         for SNV_coor_info in exon_SNV_patient_dic[exon_info]:
            for patient_info in exon_SNV_patient_dic[exon_info][SNV_coor_info]:
               patient_id = patient_info[0]

               if not patient_id in patient_in_selector:
                  continue
               
               num_SNV_in_selector = 0
               num_SNV_not_in_selector = 0

               for exon_current_patient in patient_exon_SNV_dic[patient_id]:
                  if exon_current_patient in exon_in_selector:
                     num_SNV_in_selector += len(patient_exon_SNV_dic[patient_id][exon_current_patient])
                  elif exon_current_patient == exon_info:
                     num_SNV_not_in_selector += len(patient_exon_SNV_dic[patient_id][exon_current_patient])   
               
               if num_SNV_in_selector > 1:
                  continue
               elif num_SNV_in_selector == 1 and num_SNV_not_in_selector != 0:
                  if not patient_id in list_reduced_single_SNV_patient:
                     list_reduced_single_SNV_patient.append(patient_id)
                            
         num_reduced_single_SNV_patient = len(list_reduced_single_SNV_patient)
         if num_reduced_single_SNV_patient > max_reduced_num:
            max_reduced_num = num_reduced_single_SNV_patient
            RI_max_reduced = RI
            exon_max_reduced = exon_info
         elif num_reduced_single_SNV_patient == max_reduced_num: 
            if RI > RI_max_reduced:
               max_reduced_num = num_reduced_single_SNV_patient
               RI_max_reduced = RI
               exon_max_reduced = exon_info  
      if max_reduced_num != 0:
         exon_in_selector.append(exon_max_reduced)
      else:
         break
    
   return                     
                  
                                                            

         
   
if __name__ == "__main__":

   (options, args) = process_command_line(sys.argv)
   
   tx_annotation_dic = read_ensembl_annotation(options.annotation_file)   
   outfile_info = open(options.output_prefix+'_info','w')
   outfile_bed = open(options.output_prefix+'.bed','w')
   reference_file = options.genome_reference_file
   exon_SNV_patient_dic = {}
   patient_exon_SNV_dic = {}

   for variation_info in open(options.input_filename):
      
      if variation_info[0] == "#":
         continue
      #15: TCGA barcode; 32: Universal Unique ID; #0: HUGO symbol; 1: Entrez ID; 4: chrmosome ID; 5: start coor; 6 end coor; 7 strand; 9: variant type; 37: ensembl tx; 38: exon order; 47: ensembl gene; 60: HGNC symbol; 94 variant type
      variation_ele = string.split(string.strip(variation_info),'\t')
      if variation_ele[0] == "Hugo_Symbol":
         continue
      HUGO_gene_symbol = variation_ele[0]
      entrez_ID = variation_ele[1]
      chr_no = variation_ele[4]
      start_coor = int(variation_ele[5])
      end_coor = int(variation_ele[6])
      strand = variation_ele[7]
      variation_type = variation_ele[9]
      patient_TCGA_barcode = variation_ele[15]
      patient_UUID = variation_ele[32]
      ensembl_tx = variation_ele[37]
      ensembl_gene = variation_ele[47]

      ref_allele = variation_ele[11]
      mutant_allele = variation_ele[12]
      
      SNV_coor_info = (chr_no,strand,start_coor,end_coor,HUGO_gene_symbol, ensembl_gene, ensembl_tx)
      SNV_basic_info = (patient_UUID, patient_TCGA_barcode, ref_allele, mutant_allele)

      exon_info_SNV = retreive_SNV_exon_info(SNV_coor_info,tx_annotation_dic)
      if exon_info_SNV != ():
         exon_SNV_patient_dic.setdefault(exon_info_SNV,{})
         exon_SNV_patient_dic[exon_info_SNV].setdefault(SNV_coor_info,[])
         exon_SNV_patient_dic[exon_info_SNV][SNV_coor_info].append(SNV_basic_info)
         patient_exon_SNV_dic.setdefault(patient_UUID,{})
         patient_exon_SNV_dic[patient_UUID].setdefault(exon_info_SNV,[])
         patient_exon_SNV_dic[patient_UUID][exon_info_SNV].append(SNV_coor_info)
   
   num_patient_in_dataset = len(patient_exon_SNV_dic.keys())                
   (exon_RI_dic,patient_exon_dic) = calculate_RI(exon_SNV_patient_dic)
   #(exon_in_selector,patient_in_selector) = iterative_selector(exon_RI_dic, patient_exon_dic)
   iterative_selector(exon_RI_dic, patient_exon_dic, 5)

   #patient_in_selector_p = len(patient_in_selector)/float(num_patient_in_dataset)
   #for i in range(30,1,-1):
   #   iterative_selector_single_SNV_reduction(patient_exon_SNV_dic, exon_SNV_patient_dic, exon_RI_dic, i)
   #   patient_in_selector_c = len(patient_in_selector)/float(num_patient_in_dataset)
   #   print i, patient_in_selector_c
   #   if patient_in_selector_c > 0.98:
   #      break

   iterative_selector_single_SNV_reduction(patient_exon_SNV_dic, exon_SNV_patient_dic, exon_RI_dic, 30)
   iterative_selector_single_SNV_reduction(patient_exon_SNV_dic, exon_SNV_patient_dic, exon_RI_dic, 20)
  
   print len(patient_in_selector) 
   for exon_info in exon_in_selector:
      exon_sequence = retrieve_exon_sequence(exon_info, reference_file)
      
      for ele in exon_info:
         outfile_info.write(str(ele)+'\t')
      outfile_info.write(exon_sequence+'\t')
      
      for SNV_coor_info in exon_SNV_patient_dic[exon_info]:
         outfile_info.write(':'.join([str(ele) for ele in SNV_coor_info[:4]])+';')
      outfile_info.write('\n')

      outfile_bed.write(exon_info[0]+'\t'+str(exon_info[2])+'\t'+str(exon_info[3])+'\t'+str(exon_info[4])+'\t'+str(0)+'\t'+str(exon_info[1])+'\n')   