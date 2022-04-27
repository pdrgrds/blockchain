from classBlockchain import Blockchain
import datetime
import hashlib
import json
import requests
from uuid import uuid4
from flask import Flask, jsonify, request
from urllib.parse import urlparse
from flask_ngrok import run_with_ngrok 

app = Flask(__name__)
#run_with_ngrok(app)

app.config['JSONIFY_PRETTYPRINT_REGULAR'] = False

#crear la direccion del nodo
node_address = str(uuid4()).replace('-', '')

blockchain = Blockchain()

@app.route('/mine_block')
def mine_block():
    previous_block  = blockchain.get_previous_block()
    previous_proof  = previous_block['proof']
    proof           = blockchain.proof_of_work(previous_proof)
    previous_hash   = blockchain.hash(previous_block)
    blockchain.add_transaction(sender = node_address, receiver = 'Puhip', amount = 10)
    block           = blockchain.create_block(proof, previous_hash)
    response = {
        'message'   : '¡En hora buena, has minado un bloque!',
        'index'     : block['index'],
        'timestamp' : block['timestamp'],
        'proof'     : block['proof'],
        'previous_hash' : block['previous_hash'],
        'transactions'  : block['transactions']
    }

    return jsonify(response), 200

@app.route('/get-chain')
def get_chain():
    response = {
        'chain'     : blockchain.chain,
        'length'    : len(blockchain.chain)
    }

    return jsonify(response), 200

@app.route('/is-valid')
def is_valid():
    is_valid = blockchain.is_chain_valid(blockchain.chain)
    if is_valid:
        response = { 'message': '¡La cadena de bloques es válida!' }
    else :
        response = { 'message': '¡La cadena de bloques NO es válida!' }

    return jsonify(response), 200

@app.route('/add_transaction', methods=['POST'])
def add_transaction():
    json = request.get_json()
    transaction_keys = ['sender', 'receiver', 'amount']
    if not all(key in json for key in transaction_keys):
        return 'Faltan algunos elementos de la transacción'
    index = blockchain.add_transaction(json['sender'], json['receiver'], json['amount'])
    response = { 'message': f'La transacción será añadida al bloque {index}' }
    return jsonify(response), 201

@app.route('/connect_node', methods=['POST'])
def connect_node():
    json  = request.get_json()
    nodes = json.get('nodes')
    if nodes is None:
        return 'No hay nodos por añadir', 400
    for node in nodes:
        blockchain.add_node(node)

    response = { 
        'message'       : 'Todos los nodos han sido conectados. La blockchain de VillitaCoins contiene ahora los nodos siguientes',
        'total_nodes'   : len(blockchain.nodes) 
    } 

    return jsonify(response), 201

@app.route('/replace_chain')
def replace_chain():

    is_chain_replaced = blockchain.replace_chain()
    if is_chain_replaced:
        response = {
            'message'   : 'Los nodos tenían diferentes cadenas, se ha remplazado por la blockchain mas larga.',
            'new_chain' : blockchain.chain
        }
    else:
        response = {
            'message'   : 'Todo correcto. La blockchain en todos los nodos ya es la más larga.',
            'new_chain' : blockchain.chain
        }
    return jsonify(response), 200

app.run(host='localhost',port=5002)