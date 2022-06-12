%Dobson's model to calculate the real and imaginary part of moist soil 计算湿润土壤的实部和虚部
%[1] Dobson, M. C., et al. (1985), Microwave Dielectric Behavior of wet
%Soil-Part II: Dielectric Mixing Models, IEEE Trans. Geosci. Remote Sens.,
%GE-23(1), 35-46.
%[2] Peplinski, N. R., et al. (1995), Dielectric properties of soils in the
%0.3-1.3-GHz range, IEEE Trans. Geosci. Remote Sens., 33(3), 803-807.
%[3] Klein, L., and C. Swift (1977), An improved model for the dielectric
%constant of sea water at microwave frequencies, IEEE Trans. Antennas
%Propag., 25(1), 104-111.
%[4] Stogryn, A. (1971), Equations for Calculating the Dielectric Constant
% of Saline Water, IEEE Trans. Microwave Theory Tech., 19(8), 733-736.
% input:
%       f  frequency in GHz  
%       T  soil temperature in Celsius degree          土壤温度以摄氏度为单位
%      bd  soil bulk density, in g/cm3                 土壤容重，单位为g/cm3
%     vwc  volumetric water content, e.g. 0.3 for 30%  体积含水量，例如0.3代表30%
%   vsand  fraction of sand of the soil in %           v土壤中砂粒的比例，为%
%   vclay 粘粒含量
% 按顺序Dobson(f,T,vwc,vsand,vclay,bd)
% Shaojie Zhao, 2019/07/25

function [dcsr,dcsi]=Dobson(f,T,vwc,vsand,vclay,bd)
    
    if nargin<6    %输入参数个数
        error('Not enough input arguments.'); %输入参数不够
    elseif nargin>6
        error('Too many input arguments.'); %输入参数太多
    else %参数赋值输入要刚刚好6个
        alpha=0.65;
        dcs=4.7;
        sd=2.65; %标准差
        dc0=0.008854;
        dcw0 = 88.045-0.4147.*T+6.295e-4.*T.^2+1.075e-5.*T.^3; % Refer to [3]
        tpt=0.11109-3.824e-3.*T+6.938e-5.*T.^2-5.096e-7.*T.^3; %2*pi*tao, Refer to [4]
        dcwinf=4.9;
        if f>=1.4
           sigma = -1.645+1.939*bd-0.0225622*vsand +0.01594*vclay; % Refer to [2]
        else
           sigma = 0.0467+0.2204*bd-0.004111*vsand +0.006614*vclay;% Refer to [2]
        end
        dcwr=dcwinf+((dcw0-dcwinf)./(1+(tpt.*f).^2));
        dcwi=(tpt.*f.*(dcw0-dcwinf))./(1+(tpt.*f).^2)...
        +sigma*(1.0-(bd/sd))./(8.0*atan(1.0)*dc0.*f.*vwc);% Refer to [1]
        betar=1.2748-0.00519*vsand-0.00152*vclay;
        betai=1.33797-0.00603*vsand-0.00166*vclay;
        
        dcsr=(1.0+(bd/sd)*((dcs^alpha)-1.0)+(vwc.^betar)*(dcwr^alpha)-vwc).^(1/alpha);% Result real part 实部
        dcsi=(vwc.^(betai/alpha)).*dcwi;%Result imaginary part 虚部
     end
end