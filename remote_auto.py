import os
import sys
import configparser
import argparse
import platform

CONFIG = "setting.ini"

def get_parameters():
    osc = platform.system()
    current_path = os.getcwd()
    project = os.path.basename(os.path.abspath(os.path.join(current_path, '..')))

    extra = None
    tmp = configparser.ConfigParser()
    # conf = c
    if osc == "Windows":
        tmp.read("{}{}{}".format(current_path,'\\',CONFIG))
    else:
        tmp.read("{}{}{}".format(current_path,'/',CONFIG))
    extra=tmp[osc]

    extra.setdefault('Vivado_cmd',os.path.join(os.path.abspath(extra['VivadoInstallPath']), extra['VivadoVersion'], 'bin', 'vivado'))

    index = ['name','board','path','os','pwd','vivado','tcl','version']
    value =[ project,extra['Board'],extra['WorkPath'],osc,current_path,extra['Vivado_cmd'],extra['TclPath'],extra['VivadoVersion'] ]

    config=dict(zip(index,value))

    return config

def run_script(vivado,script,*argv,**args):

    try:
        mode = args["mode"]
    except KeyError:
        mode = "batch"

    argvs = ' '.join(argv)

    vivado_cmd="{} -mode {} -source {} -tclargs {} ".format(vivado,mode,script,argvs)



    return vivado_cmd
    

def test():
    conf = get_parameters()
    run_script(conf['vivado'],conf['tcl'],"adas","dasdasd",mode="2333")

def stage():
    conf = get_parameters()
    cmd=run_script(conf['vivado'],conf['tcl'],conf['name'],conf['path'],conf['board'])
    print(cmd)

def realtime():
    conf = get_parameters()
    cmd=run_script(conf['vivado'],conf['tcl'],conf['name'],conf['path'],conf['board'])
    print(cmd)
    os.system(cmd)

if __name__ == "__main__":
    realtime()


