function [rslt v_pix_num]=cal_coverage(mat_bw) %rsltΪ���Ƕȣ�v_pix_numΪ��ɫ�����������
idx=find(1==mat_bw(:));
v_pix_num=length(idx);
rslt=v_pix_num/length(mat_bw(:));