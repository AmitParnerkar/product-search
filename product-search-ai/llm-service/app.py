from flask import Flask, request, jsonify
from sentence_transformers import SentenceTransformer
import numpy as np

app = Flask(__name__)

# Load a pre-trained SentenceTransformer model
model = SentenceTransformer('all-MiniLM-L6-v2')

# In-memory storage for item embeddings
item_embeddings = {}

@app.route('/train', methods=['POST'])
def train_model():
    """
    Endpoint to train the model (or save embeddings in memory for simplicity).
    Expects a list of items with name, description, and category fields.
    """
    try:
        data = request.json
        if not isinstance(data, list):
            return jsonify({"error": "Invalid input. Must be a list of items."}), 400

        for item in data:
            text = f"{item['name']} {item['description']} {item['category']}"
            embedding = model.encode(text).tolist()  # Convert embedding to a list for JSON serialization
            item_embeddings[item['name']] = {
                "embedding": embedding,
                "description": item['description'],
                "category": item['category']
            }

        return jsonify({"message": "Training completed. Embeddings saved in memory."}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/generate_embedding', methods=['POST'])
def generate_embedding():
    """
    Endpoint to generate an embedding for the provided text.
    Expects a JSON payload with a "text" field.
    """
    try:
        data = request.json
        text = data.get("text")
        if not text:
            return jsonify({"error": "Text is required."}), 400

        # Generate the embedding
        embedding = model.encode(text).tolist()

        return jsonify({"embedding": embedding}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
