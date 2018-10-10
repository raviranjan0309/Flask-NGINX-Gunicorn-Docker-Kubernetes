import json
from flask_cors import CORS
from flask import Flask, request, Response, jsonify
from flask_restful import reqparse, Resource, Api
import os
import json
import logging
import pyrebase

app = Flask(__name__)
api = Api(app)
CORS(app)

#Create and configure logger
logging.basicConfig(filename="newfile.log",
                    format='%(asctime)s %(message)s',
                    filemode='w')

#Creating an object
logger=logging.getLogger()

#Setting the threshold of logger to DEBUG
logger.setLevel(logging.DEBUG)

#test service
@app.route('/test',methods = ['GET'])
def test():
    return "hello world"

if __name__ == '__main__':
    logger.info("Service is up")
    app.run()