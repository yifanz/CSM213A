from bottle import route, get, view, post, run, template, request, redirect, static_file
import re
import os
import subprocess
import time
from multiprocessing import Process, Manager, Queue

@get('/pru')
@get('/pru/<pru_num>')
@view('editor')
def route_editor(pru_num=0):
	return dict(pru_num=pru_num)

@route('/static/<filepath:path>')
def server_static(filepath):
    return static_file(filepath, root='static')

@get('/pru/<pru_num>/out')
def route_output(pru_num):
	if int(pru_num) == 0:
		buf_out = pru_0_out
	else:
		buf_out = pru_1_out
	output = ""
	for i in range(10):
		try:
			output += buf_out.get_nowait() + "\n"
		except:
			break
	return output

@post('/pru/<pru_num>/compile')
def route_compile(pru_num):
	src = request.forms.getunicode('src')
	shared['src' + str(pru_num)] = src	

def compile_process(pru_num, buf_out):
	while True:
		time.sleep(0.1)
		src_key = 'src' + str(pru_num)
		src = shared.get(src_key)
		if src:
			shared[src_key] = None
			print("PRU " + str(pru_num) + " compile this: {0}".format(src))
			cur_path = os.path.dirname(os.path.realpath(__file__))	
			tmp_dir = cur_path + "/_tmp/"
			try:
				os.mkdir(tmp_dir)
				print("mkdir " + tmp_dir)
			except OSError as e:
				print(e)
			try:
				src_file = open(tmp_dir + "pru_" + str(pru_num) + ".p", "w")
				src_file.write(src)
				src_file.close()
			except IOError as e:
				print(e)
			process = subprocess.Popen([cur_path + "/../scripts/compile-pru.sh", str(pru_num)], \
						stdout=subprocess.PIPE, stderr=subprocess.PIPE)
			while True:
				output = process.stdout.readline()
				err_output = process.stderr.readline()
				if output == '' and process.poll() is not None:
					break
				else:
					if output:
						print str(pru_num) + '@ ' + output.rstrip()
						buf_out.put_nowait(output.rstrip())
					if err_output:
						print str(pru_num) + '! ' + err_output
						buf_out.put_nowait(err_output.rstrip())
			print "Compile Done"

manager = Manager()
shared = manager.dict()
pru_0_out = manager.Queue()
pru_1_out = manager.Queue()
pru_0_out.put_nowait("PRU0 Enabled\n")
pru_1_out.put_nowait("PRU1 Enabled\n")
compile_processor_0 = Process(target=compile_process, args=(0, pru_0_out))
compile_processor_0.start()
compile_processor_1 = Process(target=compile_process, args=(1, pru_1_out))
compile_processor_1.start()

run(host='192.168.7.2', port=8081, quiet=True)
