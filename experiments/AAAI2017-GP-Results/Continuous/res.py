from __future__ import print_function
import numpy as np                                                                                                                
import sys                                                                                                                        
import os                                                                                                                         
path = sys.argv[1] +'Episodes/resultsProdInt.txt'                                                                                 
if os.path.isfile(path):                                                                                                          
        print(path)
	A = np.loadtxt(path)
	print(A.mean(axis=0))
path = sys.argv[1] +'Episodes/results.txt'                                                                                        
if os.path.isfile(path):                                                                                                          
        print(path)
	A = np.loadtxt(path)
	print(A.mean(axis=0))
path = sys.argv[1] +'Episodes/resultsALL2.txt'
if os.path.isfile(path):                                                                                                          
        print('*'*10 + path)
	A = np.loadtxt(path)
	m = A.mean(axis=0) 
	s = 2 * A.std(axis=0) / np.sqrt(A.shape[0])
	print(m)
	print(s)
	for i in range(len(m)):
		print('${:.3f} \pm {:.3f}$'.format(m[i], s[i]))
path = sys.argv[1] +'Episodes/resultsALL1.txt'
if os.path.isfile(path):                                                                                                          
        print('*'*10 + path)
	A = np.loadtxt(path)
	m = A.mean(axis=0) 
	s = 2 * A.std(axis=0) / np.sqrt(A.shape[0])
	print(m)
	print(s)
	for i in range(len(m)):
		print('${:.3f} \pm {:.3f}$'.format(m[i], s[i]))
path = sys.argv[1] +'Episodes/resultsALL.txt'
if os.path.isfile(path):                                                                                                          
        print('*'*10 + path)
	A = np.loadtxt(path)
	m = A.mean(axis=0) 
	s = 2 * A.std(axis=0) / np.sqrt(A.shape[0])
	print(m)
	print(s)
	for i in range(len(m)):
		print('${:.3f} \pm {:.3f}$'.format(m[i], s[i]))
path = sys.argv[1] +'Episodes/resultsALL23.txt'
if os.path.isfile(path):                                                                                                          
        print('*'*10 + path)
	A = np.loadtxt(path)
	m = A.mean(axis=0) 
	s = 2 * A.std(axis=0) / np.sqrt(A.shape[0])
	print(m)
	print(s)
	for i in range(len(m)):
		print('${:.3f} \pm {:.3f}$'.format(m[i], s[i]))
path = sys.argv[1] +'Episodes/resultsALL2.txt'
if os.path.isfile(path):                                                                                                          
        print('*'*10 + path)
	A = np.loadtxt(path)
	m = A.mean(axis=0) 
	s = 2 * A.std(axis=0) / np.sqrt(A.shape[0])
	print(m)
	print(s)
	for i in range(len(m)):
		print('${:.3f} \pm {:.3f}$'.format(m[i], s[i]))

path = sys.argv[1] +'Episodes/resultsALL3.txt'
if os.path.isfile(path):                                                                                                          
        print('*'*10 + path)
	A = np.loadtxt(path)
	m = A.mean(axis=0) 
	s = 2 * A.std(axis=0) / np.sqrt(A.shape[0])
	print(m)
	print(s)
	for i in range(len(m)):
		print('${:.3f} \pm {:.3f}$'.format(m[i], s[i]))

path = sys.argv[1] +'Episodes/resultsALL12.txt'
if os.path.isfile(path):                                                                                                          
        print('*'*10 + path)
	A = np.loadtxt(path)
	m = A.mean(axis=0) 
	s = 2 * A.std(axis=0) / np.sqrt(A.shape[0])
	print(m)
	print(s)
	for i in range(len(m)):
		print('${:.3f} \pm {:.3f}$'.format(m[i], s[i]))
