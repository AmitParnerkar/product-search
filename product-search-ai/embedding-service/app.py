from flask import Flask, request, jsonify
from transformers import AutoTokenizer, AutoModel
import torch

# Initialize Flask app
app = Flask(__name__)

# Load tokenizer and model
MODEL_NAME = "sentence-transformers/all-MiniLM-L6-v2"
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
model = AutoModel.from_pretrained(MODEL_NAME)

@app.route('/generate_embedding', methods=['POST'])
def generate_embedding():
    try:
        # Get input text from request
        data = request.json
        text = data.get("text")
        if not text:
            return jsonify({"error": "Text is required"}), 400

        # Tokenize input text
        inputs = tokenizer(text, return_tensors="pt", padding=True, truncation=True)

        # Generate embeddings
        with torch.no_grad():
            outputs = model(**inputs)
            embeddings = outputs.last_hidden_state.mean(dim=1).squeeze().tolist()

        return jsonify({"embedding": embeddings})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Run the Flask app
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
