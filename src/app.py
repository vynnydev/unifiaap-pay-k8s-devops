from flask import Flask, jsonify, request
from datetime import datetime
import os
import logging

app = Flask(__name__)

# Configuração de logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Configurações via variáveis de ambiente
DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = os.getenv('DB_PORT', '5432')
DB_NAME = os.getenv('DB_NAME', 'pixdb')
API_VERSION = os.getenv('API_VERSION', 'v1.0.0')

# Simulação de banco de dados em memória
transactions = []
accounts = {
    "12345678900": {"name": "João Silva", "balance": 1000.00},
    "98765432100": {"name": "Maria Santos", "balance": 500.00}
}

@app.route('/')
def home():
    """Endpoint de health check"""
    return jsonify({
        "service": "UniFIAP Pay API",
        "status": "online",
        "version": API_VERSION,
        "timestamp": datetime.now().isoformat(),
        "database": f"{DB_HOST}:{DB_PORT}/{DB_NAME}"
    })

@app.route('/health')
def health():
    """Health check detalhado"""
    return jsonify({
        "status": "healthy",
        "checks": {
            "api": "ok",
            "database": "connected",
            "timestamp": datetime.now().isoformat()
        }
    }), 200

@app.route('/api/v1/pix/transfer', methods=['POST'])
def pix_transfer():
    """Realiza transferência PIX"""
    try:
        data = request.get_json()
        
        # Validações
        required_fields = ['from_cpf', 'to_cpf', 'amount', 'description']
        for field in required_fields:
            if field not in data:
                return jsonify({"error": f"Campo obrigatório: {field}"}), 400
        
        from_cpf = data['from_cpf']
        to_cpf = data['to_cpf']
        amount = float(data['amount'])
        
        # Validar contas
        if from_cpf not in accounts:
            return jsonify({"error": "Conta origem não encontrada"}), 404
        if to_cpf not in accounts:
            return jsonify({"error": "Conta destino não encontrada"}), 404
        
        # Validar saldo
        if accounts[from_cpf]['balance'] < amount:
            return jsonify({"error": "Saldo insuficiente"}), 400
        
        # Processar transação
        accounts[from_cpf]['balance'] -= amount
        accounts[to_cpf]['balance'] += amount
        
        transaction = {
            "id": f"PIX{len(transactions) + 1:06d}",
            "from_cpf": from_cpf,
            "from_name": accounts[from_cpf]['name'],
            "to_cpf": to_cpf,
            "to_name": accounts[to_cpf]['name'],
            "amount": amount,
            "description": data['description'],
            "timestamp": datetime.now().isoformat(),
            "status": "completed"
        }
        
        transactions.append(transaction)
        
        logger.info(f"PIX realizado: {transaction['id']} - R$ {amount:.2f}")
        
        return jsonify({
            "success": True,
            "transaction": transaction,
            "new_balance": accounts[from_cpf]['balance']
        }), 201
        
    except Exception as e:
        logger.error(f"Erro na transferência PIX: {str(e)}")
        return jsonify({"error": "Erro ao processar transferência"}), 500

@app.route('/api/v1/pix/transactions', methods=['GET'])
def get_transactions():
    """Lista todas as transações PIX"""
    return jsonify({
        "total": len(transactions),
        "transactions": transactions
    }), 200

@app.route('/api/v1/pix/balance/<cpf>', methods=['GET'])
def get_balance(cpf):
    """Consulta saldo de uma conta"""
    if cpf not in accounts:
        return jsonify({"error": "Conta não encontrada"}), 404
    
    return jsonify({
        "cpf": cpf,
        "name": accounts[cpf]['name'],
        "balance": accounts[cpf]['balance'],
        "timestamp": datetime.now().isoformat()
    }), 200

@app.route('/api/v1/audit/report', methods=['GET'])
def audit_report():
    """Endpoint para auditoria de transações"""
    total_volume = sum(t['amount'] for t in transactions)
    
    return jsonify({
        "audit_timestamp": datetime.now().isoformat(),
        "total_transactions": len(transactions),
        "total_volume": total_volume,
        "compliance_status": "OK",
        "bacen_homologation": "active"
    }), 200

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)