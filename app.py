from flask import Flask, jsonify, request
import psycopg2
import os
from datetime import datetime
 
app = Flask(__name__)
 
# connecting to postgres using env variables
def get_db_connection():
    return psycopg2.connect(
        dbname=os.environ['DB_NAME'],
        user=os.environ['DB_USER'],
        password=os.environ['DB_PASSWORD'],
        host=os.environ['DB_HOST']
    )
 
# getting monthly budget for brands 
@app.route('/brands/budget', methods=['GET'])
def get_monthly_budget():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT brand_name, monthly_budget FROM tbrand;')
    brands = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify([{'brand_name': b[0], 'monthly_budget': b[1]} for b in brands])

# restarting total amount spent today
@app.route('/brands/reset_spent_today', methods=['POST'])
def reset_spent_today():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('UPDATE tbrand SET spent_today = 0;')
    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({'message': 'spent_today reseteado a 0'}), 200
 
# restarting total amount spent during this month
@app.route('/brands/reset_spent_monthly', methods=['POST'])
def reset_spent_monthly():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('UPDATE tbrand SET spent_monthly = 0;')
    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({'message': 'spent_monthly reseteado a 0'}), 200

# managing dayparting
@app.route('/campaigns/deactivate_out_of_time', methods=['POST'])
def deactivate_campaigns_out_of_time():
    conn = get_db_connection()
    cursor = conn.cursor()
 

    now = datetime.now().time()
    cursor.execute("""
        UPDATE TCampaign
        SET status = 'inactive'
        WHERE NOT (start_time::time <= %s AND end_time::time >= %s);
    """, (now, now))
 
    conn.commit()
    cursor.close()
    conn.close()
 
    return jsonify({'message': 'out of time campaigns will be set as inactive'}), 200

#activates campaign if no debt is detected for the brand
@app.route('/campaigns/activate_if_no_debt', methods=['POST'])
def activate_campaigns_if_no_debt():
    conn = get_db_connection()
    cursor = conn.cursor()
 
    # search for brands without debt
    cursor.execute("SELECT id FROM TBrand WHERE debt = 0;")
    brands = cursor.fetchall()
 
    if brands:
        brand_ids = tuple([brand[0] for brand in brands])
 
        # set active status for campaigns associated with those brands
        query = """
            UPDATE TCampaign
            SET status = 'active'
            WHERE brand_id IN %s;
        """
        cursor.execute(query, (brand_ids,))
 
        conn.commit()
 
    cursor.close()
    conn.close()
 
    return jsonify({'message': 'Activated campaigns for brands without debt'}), 200


#allows us to regsiter nmoney spent on a given brand
@app.route('/spend/add', methods=['POST'])
def add_spend():
    conn = get_db_connection() 
    cursor = conn.cursor()
 
    # getting parameters
    data = request.get_json()
    spend_id = data.get('id')
    brand_id = data.get('brand_id')  
    spend_amount = data.get('spend_amount')
    spend_date = data.get('spend_date')  
 
    # checking parameters
    if not spend_id or not spend_amount or not spend_date:
        return jsonify({'error': 'missing parameters'}), 400
 
    try:
        # Insert
        cursor.execute("""
            INSERT INTO TSpend (id, brand_id, spend_amount, spend_date)
            VALUES (%s, %s, %s, %s);
        """, (spend_id, brand_id, spend_amount, spend_date))
 
        conn.commit()
        cursor.close()
        conn.close()
 
        return jsonify({'message': 'Registered correctly'}), 201
    except Exception as e:
        conn.rollback()
        cursor.close()
        conn.close()
        return jsonify({'error': str(e)}), 500


 
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
    
