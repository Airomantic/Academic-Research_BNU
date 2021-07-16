%获取文件完全路径
function [filefullpathname filename]=getfilepath()
[filename, pathname] = uigetfile({'*.jpg';'*.*'},'选择图片');
filefullpathname=fullfile(pathname,filename);