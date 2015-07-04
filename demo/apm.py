# Import
import csv
import math
import os
import random
import string
import time
import urllib
import webbrowser
from contextlib import closing


def apm(server,app,aline):
    '''Send a request to the server \n \
       server = address of server \n \
       app      = application name \n \
       aline  = line to send to server \n'''
    try:
        # Web-server URL address
        url_base = string.strip(server) + '/online/apm_line.php'
        params = urllib.urlencode({'p':app,'a':aline})
        f = urllib.urlopen(url_base,params)
        # Send request to web-server
        response = f.read()
    except:
        response = 'Failed to connect to server'
    return response

def apm_load(server,app,filename):
    '''Load APM model file \n \
       server   = address of server \n \
       app      = application name \n \
       filename = APM file name'''
    # Load APM File
    f = open(filename,'r')
    aline = f.read()
    response = apm(server,app,' '+aline)
    return

def csv_load(server,app,filename):
    '''Load CSV data file \n \
       server   = address of server \n \
       app      = application name \n \
       filename = CSV file name'''
    # Load CSV File
    f = open(filename,'r')
    aline = f.read()
    response = apm(server,app,'csv '+aline)
    return

def apm_ip(server):
    '''Get current IP address \n \
       server   = address of server'''
    # get ip address for web-address lookup
    url_base = string.strip(server) + '/ip.php'
    f = urllib.urlopen(url_base)
    ip = string.strip(f.read())
    return ip

def apm_t0(server,app,mode):
    '''Retrieve restart file \n \
       server   = address of server \n \
       app      = application name \n \
       mode = {'ss','mpu','rto','sim','est','ctl'} '''
    # Retrieve IP address
    ip = apm_ip(server)
    # Web-server URL address
    url = string.strip(server) + '/online/' + ip + '_' + app + '/' + string.strip(mode) + '.t0'
    f = urllib.urlopen(url)
    # Send request to web-server
    solution = f.read()
    return solution

def apm_sol(server,app):
    from array import array
    '''Retrieve solution results\n \
       server   = address of server \n \
       app      = application name '''
    # Retrieve IP address
    ip = apm_ip(server)
    # Web-server URL address
    url = string.strip(server) + '/online/' + ip + '_' + app + '/results.csv'
    f = urllib.urlopen(url)
    # Send request to web-server
    solution = f.read()
    # Save local variables
    with closing(urllib.urlopen(url)) as f:
        reader = csv.reader(f, delimiter=',')
        result={}
        for row in reader:
            myarray = array('f', [float(col) for col in row[1:]])
            result[row[0]] = myarray
    
    return (solution, result)

def apm_get(server,app,filename):
    '''Retrieve any file from web-server\n \
       server   = address of server \n \
       app      = application name '''
    # Retrieve IP address
    ip = apm_ip(server)
    # Web-server URL address
    url = string.strip(server) + '/online/' + ip + '_' + app + '/' + filename
    f = urllib.urlopen(url)
    # Send request to web-server
    file = f.read()
    return (file)

def apm_option(server,app,name,value):
    '''Load APM option \n \
       server   = address of server \n \
       app      = application name \n \
       name     = {FV,MV,SV,CV}.option \n \
       value    = numeric value of option '''
    aline = 'option %s = %f' %(name,value)
    response = apm(server,app,aline)
    return response

def apm_web(server,app):
    '''Open APM web viewer in local browser \n \
       server   = address of server \n \
       app      = application name '''
    # Retrieve IP address
    ip = apm_ip(server)
    # Web-server URL address    
    url = string.strip(server) + '/online/' + ip + '_' + app + '/' + ip + '_' + app + '_oper.htm'
    webbrowser.open_new_tab(url)
    return url

def apm_web_var(server,app):
    '''Open APM web viewer in local browser \n \
       server   = address of server \n \
       app      = application name '''
    # Retrieve IP address
    ip = apm_ip(server)
    # Web-server URL address    
    url = string.strip(server) + '/online/' + ip + '_' + app + '/' + ip + '_' + app + '_var.htm'
    webbrowser.open_new_tab(url)
    return url
    
def apm_web_root(server,app):
    '''Open APM root folder \n \
       server   = address of server \n \
       app      = application name '''
    # Retrieve IP address
    ip = apm_ip(server)
    # Web-server URL address    
    url = string.strip(server) + '/online/' + ip + '_' + app + '/'
    webbrowser.open_new_tab(url)
    return url

def apm_info(server,app,type,aline):
    '''Classify parameter or variable as FV, MV, SV, or CV \n \
       server   = address of server \n \
       app      = application name \n \
       type     = {FV,MV,SV,CV} \n \
       aline    = parameter or variable name '''
    x = 'info' + ' ' +  type + ', ' + aline
    response = apm(server,app,x)
    return response


def csv_data(filename):
    '''Load CSV File into MATLAB
       A = csv_data(filename)

       Function csv_data extracts data from a comma
       separated value (csv) file and returns it
       to the array A'''
    try:
        f = open(filename, 'rb')
        reader = csv.reader(f)
        headers = reader.next()
        c = [float] * (len(headers))
        A = {}
        for h in headers:
            A[h] = []
        for row in reader:
            for h, v, conv in zip(headers, row, c):
                A[h].append(conv(v))
    except ValueError:
        A = {}
    return A

def csv_lookup(name,replay):
    '''Lookup Index of CSV Column \n \
       name     = parameter or variable name \n \
       replay   = csv replay data to search'''
    header = replay[0]
    try:
        i = header.index(string.strip(name))
    except ValueError:
        i = -1 # no match
    return i

def csv_element(name,row,replay):
    '''Retrieve CSV Element \n \
       name     = parameter or variable name \n \
       row      = row of csv file \n \
       replay   = csv replay data to search'''
    # get row number
    if (row>len(replay)): row = len(replay)-1
    # get column number
    col = csv_lookup(name,replay)
    if (col>=0): value = float(replay[row][col])
    else: value = float('nan')
    return value

def apm_tag(server,app,name):
    '''Retrieve options for FV, MV, SV, or CV \n \
       server   = address of server \n \
       app      = application name \n \
       name     = {FV,MV,SV,CV}.{MEAS,MODEL,NEWVAL} \n \n \
         Valid name combinations \n \
        {FV,MV,CV}.MEAS \n \
        {SV,CV}.MODEL \n \
        {FV,MV}.NEWVAL '''
    # Web-server URL address
    url_base = string.strip(server) + '/online/get_tag.php'
    params = urllib.urlencode({'p':app,'n':name})
    f = urllib.urlopen(url_base,params)
    # Send request to web-server
    value = eval(f.read())
    return value

def apm_meas(server,app,name,value):
    '''Transfer measurement to server for FV, MV, or CV \n \
       server   = address of server \n \
       app      = application name \n \
       name     = name of {FV,MV,CV} '''
    # Web-server URL address
    url_base = string.strip(server) + '/online/meas.php'
    params = urllib.urlencode({'p':app,'n':name+'.MEAS','v':value})
    f = urllib.urlopen(url_base,params)
    # Send request to web-server
    response = f.read()
    return response
