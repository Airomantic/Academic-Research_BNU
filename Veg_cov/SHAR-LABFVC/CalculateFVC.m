function varargout = CalculateFVC(varargin)
% TEST M-file for test.fig
%      TEST, by itself, creates a new TEST or raises the existing
%      singleton*.
%
%      H = TEST returns the handle to a new TEST or the handle to
%      the existing singleton*.
%
%      TEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEST.M with the given input arguments.
%
%      TEST('Property','Value',...) creates a new TEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before test_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to test_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLESx
% Edit the above text to modify the response to help test

% Last Modified by GUIDE v2.5 22-Sep-2015 08:54:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CalculateFVC_OpeningFcn, ...
                   'gui_OutputFcn',  @CalculateFVC_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before CalculateFVC is made visible.
function CalculateFVC_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CalculateFVC (see VARARGIN)

% Choose default command line output for CalculateFVC
handles.output = hObject;

%Image cutting range
handles.height=0.75;
set(handles.txtHeight,'string',num2str(handles.height));
handles.width=0.75;
set(handles.txtWidth,'string',num2str(handles.width));

%Empirical threshold setting
set(handles.checkboxDEF,'value',0);
%Thrshold setting
handles.threshold=-4;
set(handles.txtThreshold,'string',num2str(handles.threshold));

% Image Adjust setting
set(handles.checkboxIA,'value',0);

%Input file path
fileType='*.jpg';
filePath='E:\';
filelist = dir([filePath filesep fileType]);
handles.filelist=filelist;
handles.filePath=filePath;
set(handles.txtFilePath,'string',handles.filePath);

%Output file path
handles.outputfilePath='E:\temp\';
set(handles.txtOutputPath,'string',handles.outputfilePath);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CalculateFVC wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CalculateFVC_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnBatchProcessImg.
function btnBatchProcessImg_Callback(hObject, eventdata, handles)
[row,col]=size(handles.filelist);
inputFileName_parameter=[handles.outputfilePath '_FVC_Result.wri'];
fid=fopen(inputFileName_parameter,'wt');
fprintf(fid,'Filename\t\t\t\t FVC\n');

for i=1:row
    fileFullPathName=[handles.filePath '\' handles.filelist(i).name];
    img_rgb=imread(fileFullPathName);

%*******************Linear 2% adjustment************************
    if get(handles.checkboxIA,'value')==1    
        r=img_rgb(:,:,1);
        g=img_rgb(:,:,2);
        b=img_rgb(:,:,3);
        clear img_rgb;

        [ra,rb]=hist(r(:),0:1:255);
        pl=ra/sum(ra);
        pls=0;j=1;
        while pls<0.02
              pls=pls+pl(j)*1;
              j=j+1;
        end
        rb1=rb(j-1);

        while pls<0.98
              pls=pls+pl(j)*1;
              j=j+1;
        end
        rb2=rb(j-1);

        if rb1==rb2
            rb2=rb2+1;
        end

        rad=imadjust(r,[rb1/255 rb2/255],[0 1],1);
        clear r ra rb rb1 rb2 pl pls j;

        [ga,gb]=hist(g(:),0:1:255);
        pl=ga/sum(ga);
        pls=0;j=1;
        while pls<0.02
              pls=pls+pl(j)*1;
              j=j+1;
        end
        gb1=gb(j-1);

       while pls<0.98
              pls=pls+pl(j)*1;
              j=j+1;
        end
        gb2=gb(j-1);

        if gb1==gb2
            gb2=gb2+1;
        end

        gad=imadjust(g,[gb1/255 gb2/255],[0 1],1);
        clear g ga gb gb1 gb2 pl pls j;

        [ba,bb]=hist(b(:),0:1:255);
        pl=ba/sum(ba);
        pls=0;j=1;
        while pls<0.02
              pls=pls+pl(j)*1;
              j=j+1;
        end
        bb1=bb(j-1);

        while pls<0.98
              pls=pls+pl(j)*1;
              j=j+1;
        end
        bb2=bb(j-1);

        if bb1==bb2
            bb2=bb2+1;
        end

        bad=imadjust(b,[bb1/255 bb2/255],[0 1],1);
        clear b ba bb bb1 bb2 pl pls j;

        rad=im2double(rad);
        gad=im2double(gad);
        bad=im2double(bad);
        rgb=cat(3,rad,gad,bad); 
        img_rgb3 = max(min(rgb, 1), 0);
        clear rad gad bad rgb;  
        
%********Output and Save adjusted image*************
        defaultname=handles.filelist(i).name(1:length(handles.filelist(i).name)-4);
        img_rgb3_file=[defaultname 'Linear 2%.jpg'];   %setting filename
        inputFileName_img_rgb3=[handles.outputfilePath img_rgb3_file];
        imwrite(img_rgb3,inputFileName_img_rgb3,'jpg');
        clear img_rgb3 img_rgb3_file;

        fileFullPathName2=[inputFileName_img_rgb3];
        clear inputFileName_img_rgb3;
        img_rgb=imread(fileFullPathName2);
        clear fileFullPathName2;    
    end
    
%*****************Image cutting*******************
    [a,b,c]=size(img_rgb);
    rh=ceil((1-handles.height)*a/2);    %let the cut propotion could be 100%
    if rh==0
        rh=1;
    end
    rw=ceil((1-handles.width)*b/2);
    if rw==0
        rw=1;
    end
    
    img_rgb2=img_rgb(rh:a-rh,rw:b-rw,1:3);
    % change: output cutting image             by wangbing
    img_rgb4_file=[defaultname 'Linear 2%_cutimg.jpg'];   %setting filename
    inputFileName_img_rgb4=[handles.outputfilePath img_rgb4_file];
    imwrite(img_rgb2,inputFileName_img_rgb4,'jpg');
    clear img_rgb4_file;
    clear img_rgb a b c;
      
%*****************Preprocressing*******************
    lab=rgb2lab(img_rgb2);
    img_lab=lab2double(lab);
    img_lab_a=img_lab(:,:,2);
    img_lab_l=img_lab(:,:,1);
    clear lab img_lab;
    %*****************Drawing a* compoent histogram************
    [a,b]=hist(img_lab_a(:),-55:1:30);
    %*****************Finding peak point pa1,pa2***************
    pa=a/sum(a);
    sbound=size(pa);
    k=1;
    for j=1:sbound(2)-4
       if pa(j+1)-pa(j)<0 & pa(j+2)-pa(j)<0 & pa(j+3)-pa(j)<0 & pa(j+4)-pa(j)<0 & pa(j)>0.01
            patempt(k)=pa(j);
            btempt(k)=b(j);
            k=k+1;
        end
    end
    pa1=patempt(1);
    b1=btempt(1);
    b1Idx=find(b==b1);
    clear a k j patempt btempt b1;
    
    painvord=flipud(pa');   
    binvord=flipud(b');
    k=1;
    for j=1:sbound(2)-4
       if painvord(j+1)-painvord(j)<0 & painvord(j+2)-painvord(j)<0 & painvord(j+3)-painvord(j)<0 & painvord(j+4)-painvord(j)<0 & painvord(j)>0.01
            patempt(k)=painvord(j);
            btempt(k)=binvord(j);
            k=k+1;
        end
    end
    pa2=patempt(1);
    b2=btempt(1);
    b2Idx=find(b==b2);
    clear b k j patempt btempt painvord binvord b2 sbound;
    %******************Finding the lowest point pa3***************
    k=1;
    for j=b1Idx:b2Idx
        tmppa(k)=pa(j);
        k=k+1;
    end
    pa3=min(tmppa);
    b3=find(tmppa==pa3)+b1Idx-57;   
    clear k tmppa b1Idx b2Idx j;
    %*********************Division algorithm judgment****************
    if (pa1-pa3)/pa1>0.26 && (pa2-pa3)/pa2>0.26    %0.26  Rayleigh judgment   
        cutway=1;
    else
        cutway=0;
    end
    clear pa1 pa2 pa3 pa b;
    
    %****************Drawing L* compoent histogram******************
    [c,d]=hist(img_lab_l(:),0:1:100);
    clear d img_lab_l;
    %*****************Stretch or not*********************************
    pl=c/sum(c);
    pls=0;
    for j=1:50    
        pls=pls+pl(j)*1;
    end
    if pls>0.6    %empirical 0.6
        stretchway=1;
    else
        stretchway=0;
    end
    clear c pl pls j;
    
    %********************Division judgement result*********************
    if cutway==1 
        if stretchway==1
            way=1;    
            wayname='Stretch    Gaussian division';
        else
            way=2;    
            wayname='Do not stretch    Gaussian division';
        end
    else
        if stretchway==1
            way=4; 
            wayname='Stretch    -4';
       else
            way=5; 
            wayname='Do not stretch    -4';
        end
    end
    disp(wayname);
    clear cutway stretchway wayname;
    
%*******************Stretch***********************
    if(way == 1|| way == 4)
        rgb=im2double(img_rgb2);
        clear img_rgb2;
        r=rgb(:,:,1);
        g=rgb(:,:,2);
        b=rgb(:,:,3);
        clear rgb;
        num=0.5*((r-g)+(r-b));
        den=sqrt((r-g).^2+(r-b).*(g-b));
        theta=acos(num./(den+eps));
        H=theta;
        clear num den theta;
        H(b>g)=2*pi-H(b>g);
        H=H/(2*pi);
        num=min(min(r,g),b);
        den=r+g+b;
        den(den==0)=eps;
        S=1-3.*num./den;
        H(S==0)=0;
        I=(r+g+b)/3;
        I=histeq(I);  
        clear r g b num den theta;
        HSI=cat(3,H,S,I);
        
        H =H * 2 * pi;
        R = zeros(size(HSI, 1), size(HSI, 2)); 
        G = zeros(size(HSI, 1), size(HSI, 2)); 
        B = zeros(size(HSI, 1), size(HSI, 2)); 
        clear HSI;
        idx = find( (0 <= H) & (H < 2*pi/3)); 
        B(idx) = I(idx) .* (1 - S(idx));
        R(idx) = I(idx) .* (1 + S(idx) .* cos(H(idx)) ./cos(pi/3 - H(idx)));
        G(idx) = 3*I(idx) - (R(idx) + B(idx));
        idx = find( (2*pi/3 <= H) & (H < 4*pi/3) ); 
        R(idx) = I(idx) .* (1 - S(idx));
        G(idx) = I(idx) .* (1 + S(idx) .* cos(H(idx) - 2*pi/3) ./cos(pi - H(idx)));
        B(idx) = 3*I(idx) - (R(idx) + G(idx)); 
        idx = find( (4*pi/3 <= H) & (H <= 2*pi)); 
        G(idx) = I(idx) .* (1 - S(idx));
        B(idx) = I(idx) .* (1 + S(idx) .* cos(H(idx) - 4*pi/3) ./cos(5*pi/3 - H(idx)));
        R(idx) = 3*I(idx) - (G(idx) + B(idx)); 
        clear H S I idx;
        rgb = cat(3, R, G, B); 
        clear R G B;
        img_rgb1 = max(min(rgb, 1), 0);
        clear rgb;
        img_rgb2=im2uint8(img_rgb1);
        clear img_rgb1;

        lab=rgb2lab(img_rgb2);
        img_lab=lab2double(lab);
        simg_lab_a=img_lab(:,:,2);
        clear lab img_lab img_rgb2;

        img_lab_a=simg_lab_a;
        clear simg_lab_a;
        asize=size(img_lab_a);
        img_lab_a1=reshape(img_lab_a,asize(1)*asize(2),1);
        clear  asize;
        TIdx = find(img_lab_a1<0 & img_lab_a1>-13);
        Trange=img_lab_a1(TIdx);
        for j=-12:-1
            tmpIdx=find(Trange<=j&Trange>=j);
            Numi(j+13)=size(tmpIdx,1);
        end
        Tinitbg=find(Numi==min(Numi))-13; %the initial value T0
        clear TIdx Trange tmpIdx Numi j img_lab_a1;        
    else
        clear img_rgb2;
        asize=size(img_lab_a);
        img_lab_a1=reshape(img_lab_a,asize(1)*asize(2),1);
        clear  asize;
        TIdx = find(img_lab_a1<0 & img_lab_a1>-13);
        Trange=img_lab_a1(TIdx);
        for j=-12:-1
            tmpIdx=find(Trange<=j&Trange>=j);
            Numi(j+13)=size(tmpIdx,1);
        end
        Tinitbg=find(Numi==min(Numi))-13; %the initial value T0
        clear TIdx Trange tmpIdx Numi j img_lab_a1;
    end
%********************************************************
    Tinit=Tinitbg(1);
    clear Tinitbg;
    VegIdx=find(img_lab_a<Tinit);
    vegetation=img_lab_a(VegIdx);
    SoilIdx=find(img_lab_a>Tinit);
    soil=img_lab_a(SoilIdx);

    asize2=size(img_lab_a);
    sizeVeg=size(vegetation);
    sizeSoil=size(soil);

    rVeg1=sizeVeg/asize2;
    rSoil1=sizeSoil/asize2;
    rVeg=rVeg1/(rVeg1+rSoil1);%weight of vegetation
    rSoil=rSoil1/(rVeg1+rSoil1);%weight of soil
    clear VegIdx SoilIdx asize2 sizeVeg sizeSoil rVeg1 rSoil1;
    
    idv=find(vegetation==min(vegetation));
    vegm=vegetation(idv);
    if length(vegm)==0
        veg=vegetation;
    else
    veg=vegetation-vegm(1)+1;
    end
    parVeg=lognfit(veg);

    [muSoil,sigmaSoil,idxSoil,r1Soil]=EM(soil,1);

    [MuVeg,VVeg] = lognstat(parVeg(1),parVeg(2));
   if length(vegm)==0
        MuVeg=MuVeg;
    else
    MuVeg=MuVeg+vegm(1)-1;
   end
    clear idv vegetation soil vegm veg parVeg idxSoil r1Soil;
      
%******************threshold calculating***************
    if abs(MuVeg)/abs(muSoil)<3  && MuVeg<-2 &&muSoil<-2 %pure vegetation 10 as empirical threshold
        Threshold=10;
    elseif (abs(MuVeg)+4)/((abs(muSoil))+4)<3  && MuVeg>-2 &&muSoil>-2  %pure soil as empirical threshold
        Threshold=-10;
    elseif (get(handles.radioT0,'Value') == 1)&&(way == 1|| way == 2)%(way == 1|| way == 2||way == 3)%if T0 is choosen
        Threshold=Tinit;
    elseif (get(handles.radioT1,'Value') == 1)&&(way == 1|| way == 2)%(way == 1|| way == 2||way == 3)%if T1 is choosen
         %******************log-normal for T1**********************      
         A=VVeg-sigmaSoil;
         B=2*(MuVeg*sigmaSoil-muSoil*VVeg);
         C=VVeg*muSoil*muSoil-sigmaSoil*MuVeg*MuVeg+2*VVeg*2*sigmaSoil*log(sqrt(sigmaSoil)*rVeg/(sqrt(VVeg)*rSoil));
         delta=B*B-4*A*C;
        if VVeg~= sigmaSoil && delta >0  
            T1=(-B+sqrt(B*B-4*A*C))/(2*A);
            T2=(-B-sqrt(B*B-4*A*C))/(2*A);
            if T1>MuVeg && T1<muSoil && T1 >-15 && T1<0  
               Threshold=T1;
            elseif T2>MuVeg && T2<muSoil && T2 >-15 && T2<0
               Threshold=T2;
            else
               Threshold=(MuVeg+muSoil)/2+(rVeg*VVeg+rSoil*sigmaSoil)*log(rSoil/rVeg)/(muSoil-MuVeg);
            end
        else
             Threshold=(MuVeg+muSoil)/2+(rVeg*VVeg+rSoil*sigmaSoil)*log(rSoil/rVeg)/(muSoil-MuVeg);
        end
    elseif (get(handles.radioT2,'Value') == 1)&&(way == 1|| way == 2)%(way == 1|| way == 2||way == 3)%if T2 is choosen
        %******************log-normal for T2*********************
        func=@(x)rSoil*erfc((muSoil-x)/(sqrt(sigmaSoil)*sqrt(2)))-rVeg*erfc((x-MuVeg)/(sqrt(VVeg)*sqrt(2)));
        T=fzero(func,(muSoil+MuVeg)/2);   
        Threshold=T;
    elseif (get(handles.checkboxDEF,'Value') == 1)&&(way == 4|| way == 5) %-4
        Threshold=handles.threshold;
    else %if empirical alone is choosen
        Threshold=handles.threshold;
    end
    clear Tinit MuVeg VVeg muSoil sigmaSoil rVeg rSoil A B C delta T T1 T2;
    
%*******************Image division****************
    indx=find(img_lab_a<Threshold);
    bw=repmat(0,size(img_lab_a));
    bw(indx)=1;
    bw=logical(bw);
    colormap(gray);
    clear img_lab_a; 
    
%*******************FVC calculating*****************
    [v_coverage pix_num]=cal_coverage(bw);
    strFVC=num2str(v_coverage);
    if v_coverage == 1
        FVC=1.000;
    elseif v_coverage < 0.001
        FVC=0.000;
    else   
        strFVC2=strFVC((1:5));
        FVC=str2num(strFVC2);
    end
    clear img_lab_a v_coverage pix_num strFVC strFVC2 indx Threshold;
    
%*******************Output**************************
    defaultname=handles.filelist(i).name(1:length(handles.filelist(i).name)-4);
    bw_file=[defaultname '_SubRGB_BW.BMP'];
    inputFileName_bw=[handles.outputfilePath bw_file];
    imwrite(bw,inputFileName_bw,'BMP');
    clear bw defaultname bw_file inputFileName_bw;
   
    fid=fopen(inputFileName_parameter,'at+');
    fprintf(fid,'\n%s',fileFullPathName);
    fprintf(fid,'\t\t%0.3f', FVC);
    fclose(fid);
    clear fileFullPathName stretchfileFullPathName;
    
%***********************************************************************
    strInfo=['Computing FCover of ' num2str(i) '/' num2str(row) ', please wait...']
end


function txtOutputPath_Callback(hObject, eventdata, handles)
% hObject    handle to txtOutputPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtOutputPath as text
%        str2double(get(hObject,'String')) returns contents of txtOutputPath as a double


% --- Executes during object creation, after setting all properties.
function txtOutputPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtOutputPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtFilePath_Callback(hObject, eventdata, handles)
% hObject    handle to txtFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtFilePath as text
%        str2double(get(hObject,'String')) returns contents of txtFilePath as a double


% --- Executes during object creation, after setting all properties.
function txtFilePath_CreateFcn(hObject, eventdata, handles)

% hObject    handle to txtFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnFilePath.
function btnFilePath_Callback(hObject, eventdata, handles)
[filefullpathname filename]=getfilepath();
fileType='*.jpg';
filePath=fileparts(filefullpathname);
filelist = dir([filePath filesep fileType]);
handles.filelist=filelist;
handles.filePath=filePath;
set(handles.txtFilePath,'string',handles.filePath);
guidata(hObject,handles);
% hObject    handle to btnFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnOutputPath.
function btnOutputPath_Callback(hObject, eventdata, handles)
[outputfilefullpathname outputfilename]=getfilepath();
 handles.outputfilePath=[fileparts(outputfilefullpathname) '\'];
 set(handles.txtOutputPath,'string',handles.outputfilePath);
guidata(hObject,handles);
% hObject    handle to btnOutputPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function txtThreshold_Callback(hObject, eventdata, handles)
handles.threshold=str2double(get(handles.txtThreshold,'string'));
guidata(hObject,handles);
% hObject    handle to txtThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtThreshold as text
%        str2double(get(hObject,'String')) returns contents of txtThreshold as a double


% --- Executes during object creation, after setting all properties.
function txtThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnBWThreshold.
function btnBWThreshold_Callback(hObject, eventdata, handles)
fileFullPathName=[handles.filePath '\' handles.filelist(1).name];
CalculateThreshold(fileFullPathName);
% hObject    handle to btnBWThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in radioT0.
function radioT0_Callback(hObject, eventdata, handles)
set(handles.radioT0,'value',1);
set(handles.radioT1,'value',0);
set(handles.radioT2,'value',0);
set(handles.radioEm,'value',0);
% hObject    handle to radioT0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioT0


% --- Executes on button press in radioT1.
function radioT1_Callback(hObject, eventdata, handles)
set(handles.radioT0,'value',0);
set(handles.radioT1,'value',1);
set(handles.radioT2,'value',0);
set(handles.radioEm,'value',0);
% hObject    handle to radioT1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioT1


% --- Executes on button press in radioT2.
function radioT2_Callback(hObject, eventdata, handles)
set(handles.radioT0,'value',0);
set(handles.radioT1,'value',0);
set(handles.radioT2,'value',1);
set(handles.radioEm,'value',0);
% hObject    handle to radioT2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioT2



function txtHeight_Callback(hObject, eventdata, handles)
handles.height=str2double(get(handles.txtHeight,'string'));
guidata(hObject,handles);
% hObject    handle to txtHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtHeight as text
%        str2double(get(hObject,'String')) returns contents of txtHeight as a double


% --- Executes during object creation, after setting all properties.
function txtHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function txtWidth_Callback(hObject, eventdata, handles)
handles.width=str2double(get(handles.txtWidth,'string'));
guidata(hObject,handles);
% hObject    handle to txtWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtWidth as text
%        str2double(get(hObject,'String')) returns contents of txtWidth as a double


% --- Executes during object creation, after setting all properties.
function txtWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkboxDEF.
function checkboxDEF_Callback(hObject, eventdata, handles)
if get(handles.checkboxDEF,'value')==1
    set(handles.checkboxDEF,'value',1);
    set(handles.txtThreshold,'enable','on');
else 
    set(handles.checkboxDEF,'value',0);
    set(handles.txtThreshold,'enable','off');
end

% hObject    handle to checkboxDEF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxDEF


% --- Executes on button press in radioEm.
function radioEm_Callback(hObject, eventdata, handles)
set(handles.radioT0,'value',0);
set(handles.radioT1,'value',0);
set(handles.radioT2,'value',0);
set(handles.radioEm,'value',1);
set(handles.checkboxDEF,'value',1);
set(handles.txtThreshold,'enable','on');
% hObject    handle to radioEm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioEm


% --- Executes on button press in checkboxIA.
function checkboxIA_Callback(hObject, eventdata, handles)
if get(handles.checkboxIA,'value')==1
    set(handles.checkboxIA,'value',1);
else 
    set(handles.checkboxIA,'value',0);
end
% hObject    handle to checkboxIA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxIA


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over btnFilePath.
function btnFilePath_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to btnFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
