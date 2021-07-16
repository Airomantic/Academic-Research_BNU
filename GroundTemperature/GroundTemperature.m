
%geotiffread ��ʱ
[matrix4,ref4]=readgeoraster('./LC08_L1TP_122044_20210220_20210303_02_T1_Red_Radiance.tif'); 
[matrix5,ref5]=readgeoraster('./LC08_L1TP_122044_20210220_20210303_02_T1_Nir_Radiance.tif');
[QA,~]=readgeoraster('./LC08_L1TP_122044_20210220_20210303_02_T1_QA_PIXEL.tif');
NDVI=(matrix5-matrix4)./(matrix5+matrix4);
%geotiffwrite('LST_surfaceNDVI.tif',NDVI,ref4,'CoordRefSysCode',32649);
FVC=(NDVI-0.117)./(0.816-0.117); %ֲ�����Ƕ�
%geotiffwrite('LST_surfaceFVC.tif',FVC,ref4,'CoordRefSysCode',32649);
r_s=0.971;  r_v=0.982 ;
e=r_s*(1-FVC)+r_v*FVC;
e(NDVI<0.117)=r_s;
e(NDVI>0.816)=r_v;
e(QA==21952)=0.991;
% if NDVI<0.117
%     r=r_s;
% elseif NDVI>0.816
%     r=r_v;
% else
%     r=r_s*(1-FVC)+r_v*FVC;
% end
%ˮ�巢������Ϊ0.991 %�Ⱥ�����䴫�䷽��
%�ر�����
geotiffwrite('LST_emissivity.tif',e,ref4,'CoordRefSysCode',32649);
%����ر��¶� 
[Rad,~]=readgeoraster('.\LC08_L1TP_122044_20210220_20210303_02_T1_B10.tif');
L=0.00033420.*double(Rad)+0.1 ;
B=((L-1.42)./0.81-(1-e).*2.36)./e ;
Rad(Rad==0)=nan;
B(B<0)=nan;
T=1321.0789./log(774.8853./B+1) ; %��ά���󣬴���д��tif
% image(T)
%CoordRefSysCode=26904;      %PCS_NAD83_UTM_zone_4N =26904    %����ϵ���룬��ѯ��ַ���������
%R = maprefcells(latlim,lonlim,rasterSize);%latlim,lonlim�ֱ�Ϊ1*2���ϱ�������������ޡ������ָref4
geotiffwrite('LST_Temperature.tif',T,ref4,'CoordRefSysCode',32649);


