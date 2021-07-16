
[matrix,ref]=readgeoraster('./Sentinel2_BNU.tif');

NIR=matrix(:,:,4)
Red=matrix(:,:,3)
Blue=matrix(:,:,1)
NDVI=(NIR-Red)./(NIR+Red);
%FVC=(NDVI-0.18)./(0.85-0.18); %植被覆盖度 纯裸土到纯植被 反射率 统计经验系数[0.18,0.85] 
FVC=(NDVI-0.05)./(0.95-0.05); %NDVI频率范围[0.05,0.95]
image(FVC);
%EVI
EVI=2.5.*((NIR-Red )./(NIR+6.*Red-7.5.*Blue+1));
geotiffwrite('./FVC_2.tif',FVC,ref,'CoordRefSysCode',32649)
% geotiffwrite('.\NDVI.tif',NDVI,ref,'CoordRefSysCode',32649)
% geotiffwrite('.\EVI.tif',EVI,ref,'CoordRefSysCode',32649)