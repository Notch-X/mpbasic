from flask import Flask, jsonify, request
from opcua import Client

app = Flask(__name__)

# Create OPC UA client connection
opcua_client = Client("opc.tcp://192.168.250.11:4840")

try:
    opcua_client.connect()
    print("Successfully connected to OPC UA server")
except Exception as e:
    print(f"Failed to connect to OPC UA server: {e}")

# Define the Node IDs for each mode and valve
mode_nodes = {
    "auto": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_AUTO_PB"), # Main Process Page Auto Button
    "stop": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_STOP_PB"), # Main Process Page Stop Button
    "manual": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_MANUAL_PB"), # Main Process Page Manual Button
    # ==================================================================================================================================================
    # Manual Valves in PROGRESS
    "supply_pump": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Supply_Pump"), # Module 1 Water Supply Pump/Valve
    "stock_valve": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Stock_Valve"), #Module 2 Valve for Stock valve
    "diluent_valve": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Diluent_Valve"),  # Module 2 Valve for Diluent valve
    "stock_mixer": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Stock_Mixer"), #Module 2 Valve for Stock (Mixer)
    "diluent_mixer": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Diluent_Mixer_Valve"), #Module 3 Valve from Diluent to Mixer
    "stock_mixer_valve": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Stock_Mixer_Valve"),  # Module 3 Valve from Stock to Mixer
    "mixer_tank": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Mixer_Tank_Mixer"),  # Module 3 Valve from Mixer in Mixer Tank
    "mixer_output": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Mixer_Output_Valve"), # Module 3 Mixer Tank Valve
    "mixer_bottle": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Mixer_To_Bottle"), # Module 4  Valve inbetween the Mixer and Bottles, V16 valve
    "mixer_pump": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Mixer_Pump"), # Module 4 Valve for Mixer Pump
    "bottle_valve1": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Bottle_Valve1"),  # Module 4 : Bottle 1
    "bottle_valve2": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Bottle_Valve2"),  # Module 4 : Bottle 2
    "bottle_valve3": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Bottle_Valve3"),  # Module 4 : Bottle 3
    "bottle_valve4": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Bottle_Valve4"),  # Module 4 : Bottle 4
    "bottle_valve5": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Bottle_Valve5"),  # Module 4 : Bottle 5
    "bottle_valve6": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Bottle_Valve6"),  # Module 4 : Bottle 6
    "bottle_valve7": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Bottle_Valve7"),  # Module 4 : Bottle 7
    "bottle_valve8": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Bottle_Valve8"),  # Module 4 : Bottle 8
    "bottle_valve9": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Bottle_Valve9"),  # Module 4 : Bottle 9
    "bottle_valve10": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Bottle_Valve10"),  # Module 4 : Bottle 10
    "v18_valve": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Waste_Valve1"), # Module 5 Valve 18
    "v19_valve": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Waste_Valve2"), # Module 5 Valve 19
    "bottle_tray": opcua_client.get_node("ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Bottle_Tray_Waste"),  # Module 6 Waste Bottle Tray

    # ==================================================================================================================================================
}

def set_mode_state(mode, state):
    """Helper function to set the mode state on OPC UA server"""
    try:
        node = mode_nodes.get(mode)
        if node:
            node.set_value(state)
            print(f"Set {mode} to {state}")
            return True
        return False
    except Exception as e:
        print(f"Error setting {mode}: {e}")
        return False

@app.route('/', methods=['POST'])
def control_mode():
    try:
        # Get the button states from the request
        data = request.json
        print(f"Received data: {data}")
        
        # Set the state for each mode based on the button presses
        success = True
        if data.get("button1"):
            success = all([
                set_mode_state("auto", True),
                set_mode_state("stop", False),
                set_mode_state("manual", False)
            ])
        elif data.get("button2"):
            success = all([
                set_mode_state("auto", False),
                set_mode_state("stop", True),
                set_mode_state("manual", False)
            ])
        elif data.get("button3"):
            success = all([
                set_mode_state("auto", False),
                set_mode_state("stop", False),
                set_mode_state("manual", True)
            ])
        
        if success:
            return jsonify({
                "status": "success",
                "message": "Mode updated successfully"
            })
        else:
            return jsonify({
                "status": "error",
                "message": "Failed to update mode"
            }), 500
            
    except Exception as e:
        print(f"Error processing request: {e}")
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

@app.route('/health', methods=['GET'])
def health_check():
    """Endpoint to check if the server is running"""
    return jsonify({"status": "healthy"})

@app.route('/supply_pump', methods=['POST']) # Module 1 Water Supply Pump/Valve
def supply_pump():
    try:
        data = request.get_json()
        control = data.get('control')
        state = data.get('state')

        # Process the control and state as needed
        print(f"Received control: {control}, state: {state}")

        # Example: Write to the OPC UA node
        node = mode_nodes.get("supply_pump")
        if node:
            node.set_value(state)
            print(f"Set {control} to {state}")

        # Respond with a success message
        return jsonify({'message': 'Control updated successfully'}), 200
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'message': 'Failed to update control'}), 500
    
    # ==================================================================================================================================================
    
@app.route('/stock_valve', methods=['POST']) # Module 2 Valve for stock valve
def stock_valve():
    try:
        data = request.get_json()
        control = data.get('control')
        state = data.get('state')

        # Process the control and state as needed
        print(f"Received control: {control}, state: {state}")

        # Example: Write to the OPC UA node
        node = mode_nodes.get("stock_valve")
        if node:
            node.set_value(state)
            print(f"Set {control} to {state}")

        # Respond with a success message
        return jsonify({'message': 'Control updated successfully'}), 200
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'message': 'Failed to update control'}), 500
    
    # ==================================================================================================================================================
@app.route('/diluent_valve', methods=['POST']) # Module 2 Valve for Diluent valve
def diluent_valve():
    try:
        data = request.get_json()
        control = data.get('control')
        state = data.get('state')

        # Process the control and state as needed
        print(f"Received control: {control}, state: {state}")

        # Example: Write to the OPC UA node
        node = mode_nodes.get("diluent_valve")
        if node:
            node.set_value(state)
            print(f"Set {control} to {state}")

        # Respond with a success message
        return jsonify({'message': 'Control updated successfully'}), 200
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'message': 'Failed to update control'}), 500
     # ==================================================================================================================================================
@app.route('/stock_mixer', methods=['POST']) # Module 2 Valve for Stock (Mixer)
def stock_mixer():
    try:
        data = request.get_json()
        control = data.get('control')
        state = data.get('state')

        # Process the control and state as needed
        print(f"Received control: {control}, state: {state}")

        # Example: Write to the OPC UA node
        node = mode_nodes.get("stock_mixer")
        if node:
            node.set_value(state)
            print(f"Set {control} to {state}")

        # Respond with a success message
        return jsonify({'message': 'Control updated successfully'}), 200
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'message': 'Failed to update control'}), 500
    
     # ==================================================================================================================================================

@app.route('/diluent_mixer', methods=['POST']) # Module 3 Valve from Diluent to Mixer
def diluent_mixer():
    try:
        data = request.get_json()
        control = data.get('control')
        state = data.get('state')

        # Process the control and state as needed
        print(f"Received control: {control}, state: {state}")

        # Example: Write to the OPC UA node
        node = mode_nodes.get("diluent_mixer")
        if node:
            node.set_value(state)
            print(f"Set {control} to {state}")

        # Respond with a success message
        return jsonify({'message': 'Control updated successfully'}), 200
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'message': 'Failed to update control'}), 500

# ==================================================================================================================================================
@app.route('/stock_mixer_valve', methods=['POST']) # Module 3 Valve from Stock to Mixer
def stock_mixer_valve():
    try:
        data = request.get_json()
        control = data.get('control')
        state = data.get('state')

        # Process the control and state as needed
        print(f"Received control: {control}, state: {state}")

        # Example: Write to the OPC UA node
        node = mode_nodes.get("stock_mixer_valve")
        if node:
            node.set_value(state)
            print(f"Set {control} to {state}")

        # Respond with a success message
        return jsonify({'message': 'Control updated successfully'}), 200
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'message': 'Failed to update control'}), 500

# ==================================================================================================================================================
@app.route('/mixer_tank', methods=['POST']) # Module 3 Valve from Mixer in Mixer Tank
def mixer_tank():
    try:
        data = request.get_json()
        control = data.get('control')
        state = data.get('state')

        # Process the control and state as needed
        print(f"Received control: {control}, state: {state}")

        # Example: Write to the OPC UA node
        node = mode_nodes.get("mixer_tank")
        if node:
            node.set_value(state)
            print(f"Set {control} to {state}")

        # Respond with a success message
        return jsonify({'message': 'Control updated successfully'}), 200
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'message': 'Failed to update control'}), 500
    
# ==================================================================================================================================================
@app.route('/mixer_pump', methods=['POST']) # Module 3 Valve for Mixer Pump
def mixer_pump():
    try:
        data = request.get_json()
        control = data.get('control')
        state = data.get('state')

        # Process the control and state as needed
        print(f"Received control: {control}, state: {state}")

        # Example: Write to the OPC UA node
        node = mode_nodes.get("mixer_pump")
        if node:
            node.set_value(state)
            print(f"Set {control} to {state}")

        # Respond with a success message
        return jsonify({'message': 'Control updated successfully'}), 200
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'message': 'Failed to update control'}), 500


# ==================================================================================================================================================
@app.route('/mixer_output', methods=['POST']) # Module 3 Mixer Tank Valve
def mixer_output():
    try:
        data = request.get_json()
        control = data.get('control')
        state = data.get('state')

        # Process the control and state as needed
        print(f"Received control: {control}, state: {state}")

        # Example: Write to the OPC UA node
        node = mode_nodes.get("mixer_output")
        if node:
            node.set_value(state)
            print(f"Set {control} to {state}")

        # Respond with a success message
        return jsonify({'message': 'Control updated successfully'}), 200
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'message': 'Failed to update control'}), 500

# ==================================================================================================================================================
@app.route('/mixer_bottle', methods=['POST']) # Module 4  Valve in-between the Mixer and Bottles, V16 valve
def mixer_bottle():
    try:
        data = request.get_json()
        control = data.get('control')
        state = data.get('state')

        # Process the control and state as needed
        print(f"Received control: {control}, state: {state}")

        # Example: Write to the OPC UA node
        node = mode_nodes.get("mixer_bottle")
        if node:
            node.set_value(state)
            print(f"Set {control} to {state}")

        # Respond with a success message
        return jsonify({'message': 'Control updated successfully'}), 200
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'message': 'Failed to update control'}), 500

# ==================================================================================================================================================
@app.route('/bottle_valve1', methods=['POST']) # Module 4 : Bottle 1
def bottle_valve1():
    try:
        data = request.get_json()
        control = data.get('control')
        state = data.get('state')

        # Process the control and state as needed
        print(f"Received control: {control}, state: {state}")

        # Example: Write to the OPC UA node
        node = mode_nodes.get("bottle_valve1")
        if node:
            node.set_value(state)
            print(f"Set {control} to {state}")

        # Respond with a success message
        return jsonify({'message': 'Control updated successfully'}), 200
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'message': 'Failed to update control'}), 500

# ==================================================================================================================================================
@app.route('/bottle_valve2', methods=['POST']) # Module 4 : Bottle 2
def bottle_valve2():
    try:
        data = request.get_json()
        control = data.get('control')
        state = data.get('state')

        # Process the control and state as needed
        print(f"Received control: {control}, state: {state}")

        # Example: Write to the OPC UA node
        node = mode_nodes.get("bottle_valve2")
        if node:
            node.set_value(state)
            print(f"Set {control} to {state}")

        # Respond with a success message
        return jsonify({'message': 'Control updated successfully'}), 200
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'message': 'Failed to update control'}), 500

# ==================================================================================================================================================
@app.route('/bottle_valve3', methods=['POST']) # Module 4 : Bottle 3
def bottle_valve3():
    try:
        data = request.get_json()
        control = data.get('control')
        state = data.get('state')

        # Process the control and state as needed
        print(f"Received control: {control}, state: {state}")

        # Example: Write to the OPC UA node
        node = mode_nodes.get("bottle_valve3")
        if node:
            node.set_value(state)
            print(f"Set {control} to {state}")

        # Respond with a success message
        return jsonify({'message': 'Control updated successfully'}), 200
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'message': 'Failed to update control'}), 500

# ==================================================================================================================================================
@app.route('/bottle_valve4', methods=['POST']) # Module 4 : Bottle 4
def bottle_valve4():
    try:
        data = request.get_json()
        control = data.get('control')
        state = data.get('state')

        # Process the control and state as needed
        print(f"Received control: {control}, state: {state}")

        # Example: Write to the OPC UA node
        node = mode_nodes.get("bottle_valve4")
        if node:
            node.set_value(state)
            print(f"Set {control} to {state}")

        # Respond with a success message
        return jsonify({'message': 'Control updated successfully'}), 200
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'message': 'Failed to update control'}), 500

# ==================================================================================================================================================
@app.route('/bottle_valve5', methods=['POST']) # Module 4 : Bottle 5
def bottle_valve5():
    try:
        data = request.get_json()
        control = data.get('control')
        state = data.get('state')

        # Process the control and state as needed
        print(f"Received control: {control}, state: {state}")

        # Example: Write to the OPC UA node
        node = mode_nodes.get("bottle_valve5")
        if node:
            node.set_value(state)
            print(f"Set {control} to {state}")

        # Respond with a success message
        return jsonify({'message': 'Control updated successfully'}), 200
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'message': 'Failed to update control'}), 500

# ==================================================================================================================================================
@app.route('/bottle_valve6', methods=['POST']) # Module 4 : Bottle 6
def bottle_valve6():
    try:
        data = request.get_json()
        control = data.get('control')
        state = data.get('state')

        # Process the control and state as needed
        print(f"Received control: {control}, state: {state}")

        # Example: Write to the OPC UA node
        node = mode_nodes.get("bottle_valve6")
        if node:
            node.set_value(state)
            print(f"Set {control} to {state}")

        # Respond with a success message
        return jsonify({'message': 'Control updated successfully'}), 200
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'message': 'Failed to update control'}), 500
    
# ==================================================================================================================================================
@app.route('/bottle_valve7', methods=['POST']) # Module 4 : Bottle 7
def bottle_valve7():
    try:
        data = request.get_json()
        control = data.get('control')
        state = data.get('state')

        # Process the control and state as needed
        print(f"Received control: {control}, state: {state}")

        # Example: Write to the OPC UA node
        node = mode_nodes.get("bottle_valve7")
        if node:
            node.set_value(state)
            print(f"Set {control} to {state}")

        # Respond with a success message
        return jsonify({'message': 'Control updated successfully'}), 200
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'message': 'Failed to update control'}), 500

# ==================================================================================================================================================
@app.route('/bottle_valve8', methods=['POST']) # Module 4 : Bottle 8
def bottle_valve8():
    try:
        data = request.get_json()
        control = data.get('control')
        state = data.get('state')

        # Process the control and state as needed
        print(f"Received control: {control}, state: {state}")

        # Example: Write to the OPC UA node
        node = mode_nodes.get("bottle_valve8")
        if node:
            node.set_value(state)
            print(f"Set {control} to {state}")

        # Respond with a success message
        return jsonify({'message': 'Control updated successfully'}), 200
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'message': 'Failed to update control'}), 500

# ==================================================================================================================================================
@app.route('/bottle_valve9', methods=['POST']) # Module 4 : Bottle 9
def bottle_valve9():
    try:
        data = request.get_json()
        control = data.get('control')
        state = data.get('state')

        # Process the control and state as needed
        print(f"Received control: {control}, state: {state}")

        # Example: Write to the OPC UA node
        node = mode_nodes.get("bottle_valve9")
        if node:
            node.set_value(state)
            print(f"Set {control} to {state}")

        # Respond with a success message
        return jsonify({'message': 'Control updated successfully'}), 200
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'message': 'Failed to update control'}), 500

# ==================================================================================================================================================

@app.route('/bottle_valve10', methods=['POST']) # Module 4 : Bottle 10
def bottle_valve10():
    try:
        data = request.get_json()
        control = data.get('control')
        state = data.get('state')

        # Process the control and state as needed
        print(f"Received control: {control}, state: {state}")

        # Example: Write to the OPC UA node
        node = mode_nodes.get("bottle_valve10")
        if node:
            node.set_value(state)
            print(f"Set {control} to {state}")

        # Respond with a success message
        return jsonify({'message': 'Control updated successfully'}), 200
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'message': 'Failed to update control'}), 500

# ==================================================================================================================================================

@app.route('/v18_valve', methods=['POST']) # Module 5 : V18 Valve
def v18_valve():
    try:
        data = request.get_json()
        control = data.get('control')
        state = data.get('state')

        # Process the control and state as needed
        print(f"Received control: {control}, state: {state}")

        # Example: Write to the OPC UA node
        node = mode_nodes.get("v18_valve")
        if node:
            node.set_value(state)
            print(f"Set {control} to {state}")

        # Respond with a success message
        return jsonify({'message': 'Control updated successfully'}), 200
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'message': 'Failed to update control'}), 500


# ==================================================================================================================================================

@app.route('/v19_valve', methods=['POST']) # Module 5 : V19 Valve
def v19_valve():
    try:
        data = request.get_json()
        control = data.get('control')
        state = data.get('state')

        # Process the control and state as needed
        print(f"Received control: {control}, state: {state}")

        # Example: Write to the OPC UA node
        node = mode_nodes.get("v19_valve")
        if node:
            node.set_value(state)
            print(f"Set {control} to {state}")

        # Respond with a success message
        return jsonify({'message': 'Control updated successfully'}), 200
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'message': 'Failed to update control'}), 500


# ==================================================================================================================================================

@app.route('/bottle_tray', methods=['POST']) # Module 6 Waste Bottle Tray
def bottle_tray():
    try:
        data = request.get_json()
        control = data.get('control')
        state = data.get('state')

        # Process the control and state as needed
        print(f"Received control: {control}, state: {state}")

        # Example: Write to the OPC UA node
        node = mode_nodes.get("bottle_tray")
        if node:
            node.set_value(state)
            print(f"Set {control} to {state}")

        # Respond with a success message
        return jsonify({'message': 'Control updated successfully'}), 200
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'message': 'Failed to update control'}), 500

# ==================================================================================================================================================
if __name__ == '__main__':
    try:
        app.run(host='0.0.0.0', port=5000, debug=True)
    finally:
        opcua_client.disconnect()

      