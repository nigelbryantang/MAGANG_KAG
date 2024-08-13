from flask import Flask, send_file, jsonify
import pandas as pd
import os
import logging
from firebase_admin import credentials, db, initialize_app

# logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')
pd.set_option('display.max_rows', None)
pd.set_option('display.max_columns', None)

app = Flask(__name__)

try:
    cred = credentials.Certificate('')
    default_app = initialize_app(cred, {
        'databaseURL': ''
    })
except Exception as e:
    # logging.error("Error initializing Firebase Admin SDK: %s", e)
    raise

def exp():
    try:
        # Reference to the database location
        ref = db.reference('Place 1')
        data = ref.get()

        if not data:
            raise ValueError("No data retrieved from Firebase for 'Place 1'.")
        cs1_data = data.get('CS 1', {})
        ch5_data = data.get('CH 5', {})

        if not cs1_data or not ch5_data:
            raise ValueError("Data for CS1 or CH5 is missing or empty.")
        def convert_to_list(data_dict, calib):
            rows = []
            for timestamp, readings in data_dict.items():
                calibrated = float(readings.get('Temp', 0) + calib)
                row = {
                    'Timestamp': timestamp,
                    'Temperature': calibrated,
                    'Humidity': readings.get('Hum')
                }
                rows.append(row)
            return rows

        cs1_list = convert_to_list(cs1_data, 4)
        ch5_list = convert_to_list(ch5_data, 1.2)

        # logging.debug("CS1 list:\n%s", cs1_list)
        # logging.debug("CH5 list:\n%s", ch5_list)

        cs1_list.sort(key=lambda x: x['Timestamp'])
        ch5_list.sort(key=lambda x: x['Timestamp'])

        cs1_df = pd.DataFrame(cs1_list)
        ch5_df = pd.DataFrame(ch5_list)

        # logging.debug("CS1 DataFrame:\n%s", cs1_df)
        # logging.debug("CH5 DataFrame:\n%s", ch5_df)

        current_dir = os.path.dirname(os.path.abspath(__file__))
        excel_file = os.path.join(current_dir, 'Monitoring_log.xlsx')

        with pd.ExcelWriter(excel_file, engine='openpyxl') as writer:
            cs1_df.to_excel(writer, sheet_name='CS1 Data', index=False)
            ch5_df.to_excel(writer, sheet_name='CH5 Data', index=False)

        # logging.info("Excel file created successfully: %s", excel_file)
        return excel_file

    except Exception as e:
        # logging.error("Error in exp function: %s", e)
        raise

@app.route('/export', methods=['GET'])
def export():
    try:
        file_path = exp()
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"File not found: {file_path}")

        return send_file(file_path, as_attachment=True)
    except Exception as e:
        # logging.error("Error in export endpoint: %s", e)
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
