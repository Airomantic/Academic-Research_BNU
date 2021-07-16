
[matrix,ref]=readgeoraster('./Sentinel2_BNU.tif');

NIR=matrix(:,:,4)
Red=matrix(:,:,3)
Blue=matrix(:,:,1)
NDVI=(NIR-Red)./(NIR+Red);
%FVC=(NDVI-0.18)./(0.85-0.18); %ֲ�����Ƕ� ����������ֲ�� ������ ͳ�ƾ���ϵ��[0.18,0.85] 
FVC=(NDVI-0.05)./(0.95-0.05); %NDVIƵ�ʷ�Χ[0.05,0.95]
image(FVC);
%EVI
EVI=2.5.*((NIR-Red )./(NIR+6.*Red-7.5.*Blue+1));
geotiffwrite('./FVC_2.tif',FVC,ref,'CoordRefSysCode',32649)
% geotiffwrite('.\NDVI.tif',NDVI,ref,'CoordRefSysCode',32649)
% geotiffwrite('.\EVI.tif',EVI,ref,'CoordRefSysCode',32649)