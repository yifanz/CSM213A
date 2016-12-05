from bottle import route, get, view, post, run, template, request, redirect, static_file
import re
import os
import subprocess
import time
from multiprocessing import Process, Manager

@get('/pru')
@get('/pru/<pru_num>')
@view('editor')
def route_editor(pru_num=0):
	return dict(pru_num=pru_num)

@route('/static/<filepath:path>')
def server_static(filepath):
    return static_file(filepath, root='static')

@post('/pru/<pru_num>/compile')
def route_compile(pru_num):
	src = request.forms.getunicode('src')
	shared['src'] = src	

def compile_process():
	while True:
		time.sleep(1)
		src = shared.get('src')
		if src:
			shared['src'] = None
			print("compile this: {0}".format(src))

manager = Manager()
shared = manager.dict()
compile_processor = Process(target=compile_process)
compile_processor.start()

run(host='192.168.7.2', port=8081)
