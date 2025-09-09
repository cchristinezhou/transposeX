from flask import Flask, request, jsonify
from music21 import converter, interval as m21interval, metadata, key
import tempfile
import os

app = Flask(__name__)

@app.route('/transpose', methods=['POST'])
def transpose():
    data = request.get_json()
    xml = data.get('xml')
    interval = data.get('interval')

    print("🚀 Received XML:")
    print(xml[:500] if xml else "❌ No XML received")
    print(f"🔁 Interval to transpose: {interval}")

    if not xml or interval is None:
        print("❌ Missing XML or interval in request")
        return jsonify({"error": "Missing xml or interval"}), 400

    try:
        interval = int(interval)
    except ValueError:
        print("❌ Interval is not an integer")
        return jsonify({"error": "Interval must be an integer"}), 400

    try:
        # Save original XML to temp file
        with tempfile.NamedTemporaryFile(delete=False, suffix=".musicxml") as f:
            f.write(xml.encode("utf-8"))
            temp_path = f.name
        print(f"📁 Temp input file saved at: {temp_path}")

        # Parse with music21
        score = converter.parse(temp_path)
        print("✅ music21 parsed score successfully")

        # Transpose the score
        transposed_score = score.transpose(m21interval.Interval(interval))
        print("🎼 Transposition completed")

        # 📌 Set metadata
        original_title = (score.metadata.title if score.metadata and score.metadata.title else "Untitled Piece")
        new_key = transposed_score.analyze('key')
        key_name = f"{new_key.tonic.name} {new_key.mode.capitalize()}"  # e.g., A Major, F# Minor

        full_title = f"{original_title} in {key_name}"
        print(f"📝 Setting title to: {full_title}")

        transposed_score.metadata = metadata.Metadata()
        transposed_score.metadata.title = full_title
        transposed_score.metadata.composer = "TransposeX"

        # Save to another temp file
        with tempfile.NamedTemporaryFile(delete=False, suffix=".musicxml") as out_f:
            out_path = out_f.name
            transposed_score.write("musicxml", fp=out_path)
        print(f"📁 Transposed file written to: {out_path}")

        # Read the result
        with open(out_path, "r", encoding="utf-8") as result:
            result_xml = result.read()

        print("📦 Preview of transposed XML:")
        print(result_xml[:500])

        return jsonify({"transposedXml": result_xml})

    except Exception as e:
        print(f"❌ Exception occurred during transposition: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(port=5000)