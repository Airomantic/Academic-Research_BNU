%Dobson模型作为一个函数，输入参数为：频率，温度，体积含水量，砂粒含量，粘粒含量，容重
clear;
clc;
f=3;
T=30;
vwc=linspace(1,100,1000); %体积含水量-自变量
vsand=0.4;
vclay=0.2;
bd=1.1;
[real,imaginary]=Dobson(f,T,vwc,vsand,vclay,bd) %这里的real和imaginary都是矩阵(行为一）
% E=real+imaginary*i;
theta_i=55*pi/180;

%反射率（系数）与土壤体积含水量关系
% for i=1:1000
%     E(i)=sqrt(real(i)^2+imaginary(i)^2); %因变量取整个复数E
%     R1(i)=DC_R('V_pol',theta_i,real(i)); %只取实部
%     R2(i)=DC_R('V_pol',theta_i,E(i)); %因变量
% end
%plot(vwc,R1,'k','linewidth',3);
%plot(vwc,R2,':','linewidth',3);
%穿透深度与土壤体积含水量关系
for i=1:1000
    depth(i)=Penetration_d(real(i),imaginary(i),theta_i,f);
end
plot(vwc,depth,'linewidth',3);

xlabel('土壤体积含水量');
ylabel('穿透深度(m)');
title('不同频率下土壤含水量—介电常数');
grid;
hold on;