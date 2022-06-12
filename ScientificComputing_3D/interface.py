
import main as m
import PySimpleGUI as ps_GUI
'''
蒋宗青 202011069017 地理信息科学
'''
####程序入口
if __name__=='__main__':
    # 改变窗口主题
    # 设置布局方案一

    layout = [
        [ps_GUI.Text('请选择文件：',size=(10, 1), auto_size_text=False, justification='right'),
         ps_GUI.InputText('***.asc/***.tif'), ps_GUI.FileBrowse(key='_filename_')],  # Default File
        [ps_GUI.Button('查看文件内容', size=(60, 1), button_color=('black', 'grey'), key='查看文件内容')],
        [ps_GUI.Text('设置观测角度：（注！数字，绕y轴和绕z轴旋转的角度）:',size=(60, 1))],
        [ps_GUI.Text('y：',size=(3, 1)),ps_GUI.Input(default_text='90',
                                                    key='y:',size=(10, 1)),
         ps_GUI.Text('z：',size=(3, 1)),ps_GUI.Input(default_text='0',key='z:',size=(10, 1)),ps_GUI.Submit('确认',auto_size_button=True)],
        [ps_GUI.Text('设置观察范围（切片大小）：',size=(30, 1))],
        [ps_GUI.Radio('4倍',key='4',group_id=1),ps_GUI.Radio('3倍',key='3',group_id=1),ps_GUI.Radio('2倍',key='2',group_id=1),ps_GUI.Radio('1倍',key='1',group_id=1),
         ps_GUI.OK('确认',auto_size_button=True)],
        [ps_GUI.Button('绘制3维空间分布图', size=(60, 1))],

        # 选择计算目标
        [ps_GUI.Text('选择计算目标：', size=(35, 1))],
        [ps_GUI.Button('计算坡度', size=(30, 1)),ps_GUI.Button('计算坡向', size=(30, 1))],
        [ps_GUI.Text('统计DEM属性：', size=(35, 1))],
        [ps_GUI.Button('查看DEM属性', size=(30, 1))],
        [ps_GUI.Button('将高程差分布排序', size=(20, 1)), ps_GUI.Button('Plot_折线_条形图',size=(20,1)), ps_GUI.Button('Plot_频率分布直方图',size=(20,1))],
        [ps_GUI.Button('关闭退出', size=(65, 1), button_color=('black', 'grey'))]
    ]
    # 设置窗口
    window_system = ps_GUI.Window('栅格流域坡度坡向数据计算门户', layout)

    # 点击事件
    while True:
        event, value = window_system.Read()
        if event is None or event == '关闭退出':
            break
        else:
            #判断导入文件的后缀名
            if ".asc" in value['_filename_']:
                ASC=value['_filename_']
                m.choose(ASC,event,value)
            elif ".tif" in value['_filename_']:
                TIF=value['_filename_']
                m.HanleTIF(TIF,event,value)