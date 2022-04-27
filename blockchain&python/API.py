from classBlockchain import Blockchain
from flask_ngrok import run_with_ngrok
from flask import Flask, jsonify

app = Flask(__name__)
run_with_ngrok(app)

app.config['JSONIFY_PRETTYPRINT_REGULAR'] = False

blockchain = Blockchain()

@app.route('/mine_block')
def mine_block():
    previous_block  = blockchain.get_previous_block()
    previous_proof  = previous_block['proof']
    proof           = blockchain.proof_of_work(previous_proof)
    previous_hash   = blockchain.hash(previous_block)
    block           = blockchain.create_block(proof, previous_hash)
    response = {
        'message'   : '¡En hora buena, has minado un bloque!',
        'index'     : block['index'],
        'timestamp' : block['timestamp'],
        'proof'     : block['proof'],
        'previous_hash' : block['previous_hash']
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


app.run()