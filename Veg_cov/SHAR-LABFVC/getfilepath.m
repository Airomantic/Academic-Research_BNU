%��ȡ�ļ���ȫ·��
function [filefullpathname filename]=getfilepath()
[filename, pathname] = uigetfile({'*.jpg';'*.*'},'ѡ��ͼƬ');
filefullpathname=fullfile(pathname,filename);