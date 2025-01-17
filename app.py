from flask import Flask, jsonify, request
from opcua import Client
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Create OPC UA client connection
opcua_client = Client("opc.tcp://192.168.250.11:4840")

try:
    opcua_client.connect()
    logger.info("Successfully connected to OPC UA server")
except Exception as e:
    logger.error(f"Failed to connect to OPC UA server: {e}")

# Define all nodes with their OPC UA addresses
node_definitions = {
    # Mode controls
    "auto": "ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_AUTO_PB",
    "stop": "ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_STOP_PB",
    "manual": "ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_MANUAL_PB",
    
    # Module 1
    "supply_pump": "ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Supply_Pump",
    
    # Module 2
    "stock_valve": "ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Stock_Valve",
    "diluent_valve": "ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Diluent_Valve",
    "stock_mixer": "ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Stock_Mixer",
    
    # Module 3
    "diluent_mixer": "ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Diluent_Mixer_Valve",
    "stock_mixer_valve": "ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Stock_Mixer_Valve",
    "mixer_tank": "ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Mixer_Tank_Mixer",
    "mixer_output": "ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Mixer_Output_Valve",
    
    # Module 4
    "mixer_bottle": "ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Mixer_To_Bottle",
    "mixer_pump": "ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Mixer_Pump",
    
    # Waste valves
    "v18_valve": "ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Waste_Valve1",
    "v19_valve": "ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Waste_Valve2",
    "bottle_tray": "ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Bottle_Tray_Waste"
}

# Add bottle valves
for i in range(1, 11):
    node_definitions[f"bottle_valve{i}"] = f"ns=4;s=|var|Turck/ARM/WinCE TV.Application.GVL_ThirdPartyIO.EXT_PB_Bottle_Valve{i}"

# Create OPC UA nodes dictionary
mode_nodes = {name: opcua_client.get_node(address) for name, address in node_definitions.items()}

def set_node_value(node_name, state):
    """Set value for a node with error handling"""
    try:
        node = mode_nodes.get(node_name)
        if not node:
            logger.error(f"Node not found: {node_name}")
            return False
        node.set_value(state)
        logger.info(f"Successfully set {node_name} to {state}")
        return True
    except Exception as e:
        logger.error(f"Error setting {node_name}: {e}")
        return False

def control_component(component_name):
    """Generic component control function"""
    try:
        data = request.get_json()
        state = data.get('state')
        
        if state is None:
            return jsonify({"status": "error", "message": "State not provided"}), 400
        
        if set_node_value(component_name, state):
            return jsonify({
                "status": "success",
                "message": f"Successfully set {component_name} to {state}"
            })
        return jsonify({
            "status": "error",
            "message": f"Failed to set {component_name}"
        }), 500
    except Exception as e:
        logger.error(f"Error controlling {component_name}: {e}")
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

# Create all routes dynamically
for component_name in mode_nodes.keys():
    if component_name not in ['auto', 'stop', 'manual']:  # Skip mode controls
        app.add_url_rule(
            f'/{component_name}',
            f'control_{component_name}',
            lambda x=component_name: control_component(x),
            methods=['POST']
        )

# Mode control endpoint
@app.route('/', methods=['POST'])
def control_mode():
    """Handle mode switching between auto, stop, and manual"""
    try:
        data = request.json
        logger.info(f"Received mode control request: {data}")
        
        if data.get("button1"):  # Auto mode
            states = {"auto": True, "stop": False, "manual": False}
        elif data.get("button2"):  # Stop mode
            states = {"auto": False, "stop": True, "manual": False}
        elif data.get("button3"):  # Manual mode
            states = {"auto": False, "stop": False, "manual": True}
        else:
            return jsonify({"status": "error", "message": "Invalid button state"}), 400

        success = all(set_node_value(mode, state) for mode, state in states.items())
        return jsonify({
            "status": "success" if success else "error",
            "message": "Mode updated successfully" if success else "Failed to update mode"
        })
    except Exception as e:
        logger.error(f"Error in mode control: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({"status": "healthy"})

if __name__ == '__main__':
    try:
        app.run(host='0.0.0.0', port=5000, debug=True)
    finally:
        opcua_client.disconnect()