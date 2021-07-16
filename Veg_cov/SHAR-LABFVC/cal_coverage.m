function [rslt v_pix_num]=cal_coverage(mat_bw) %rslt为覆盖度，v_pix_num为绿色点的总像素数
idx=find(1==mat_bw(:));
v_pix_num=length(idx);
rslt=v_pix_num/length(mat_bw(:));