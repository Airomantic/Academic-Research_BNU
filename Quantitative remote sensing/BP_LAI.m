load data.mat  
%读取数据，data.mat中包含一个个矩阵为data，其中矩阵的第1行到第7行依次对应Landsat8反射率的1-7波段，第8行为LAI地面实测数据
[trainl,test]=dividerand(data,0.75, 0.25); %dividerand()使用随机索引将目标分为三组
inputn=trainl(1:7,:); %用于训练的反射率
outputn=trainl(8,:);  %用于训练的LAI
inputsim=test(1:7,:); %用于验证的反射率
LAI_sim=test(8,:);    %用于验证的LAI
net=newff(inputn,outputn,[10,12],{'tansig' 'tansig' 'purelin'},'traingd'); 
%创建一个BP神经网络，第一个隐含层有10个神经元，第二个隐含层有12个神经元，输出层有1个神经元，隐含层的激活函数均为tansig，输出层的激活函数为purelin，训练函数为trainlm
net.trainParam.epochs=3000;%设置迭代次数为3000
net.trainParam.goal=0.001;%设置最小目标误差为0.001
net.trainParam.lr=0.01;%设置学习速率为0.01
net=train(net,inputn,outputn); %BP神经网络训练
%利用上一步训练好的神经网络，即net，输入未参与神经网络训练的反射率数据LAI_sim，即可得到估计的LAI值
LAI_BP=sim(net,inputsim);
%计算参与建模的地面实测LAI与BP神经网络估计的LAI的相关系数和决定系数
Rva=corrcoef(LAI_sim,LAI_BP); %获取矩阵相关系数
R2va=Rva(2)^2; %相对虚拟地址到虚拟地址的转换
R2va=roundn(R2va,-4);  %roundn(x,n)四舍五入到x的n倍数
 figure(3)
scatter(LAI_BP,LAI_sim)  %在向量和指定的位置创建一个带有圆形标记的散点图
LAI_BP
LAI_sim
hold on;
plot([8,0],[8,0],'black');
ylabel('LAI反演值','FontName','宋体','FontSize',18);
xlabel('LAI测量值','FontName','宋体','FontSize',18);
set(gca,'FontSize',14);
set(gca, 'XTick', [1 2 3 4 5 6 7 8]); 
set(gca, 'YTick', [1 2 3 4 5 6 7 8]); 
box on;
axis square;
text(0.5,7,['R^2=',num2str(R2va)],'fontsize',16,'fontname','Times new roman'); 