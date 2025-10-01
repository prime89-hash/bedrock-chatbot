import boto3
import streamlit as st
import os
import logging
import re

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create Bedrock client
bedrock_client = boto3.client(
    service_name="bedrock-runtime",
    region_name=os.getenv("BEDROCK_REGION", "us-west-2")
)

# Model ID (Claude Sonnet 4 Inference Profile)
model_id = "us.anthropic.claude-sonnet-4-20250514-v1:0"

def validate_input(text):
    """Validate and sanitize user input"""
    if not text or not text.strip():
        return False, "Please enter a question."
    
    # Length check
    if len(text) > 4000:
        return False, "Question too long. Please limit to 4000 characters."
    
    # Basic content filtering
    suspicious_patterns = [
        r'<script.*?>.*?</script>',
        r'javascript:',
        r'data:text/html'
    ]
    
    for pattern in suspicious_patterns:
        if re.search(pattern, text, re.IGNORECASE):
            return False, "Invalid input detected."
    
    return True, text.strip()

# Function to generate response from Bedrock
def query_bedrock(language, freeform_text):
    system_message = f"You are a helpful chatbot. Respond in {language}. Keep responses concise and helpful."
    
    try:
        response = bedrock_client.converse(
            modelId=model_id,
            messages=[
                {
                    "role": "user",
                    "content": [{"text": freeform_text}]
                }
            ],
            system=[{"text": system_message}],
            inferenceConfig={
                "temperature": 0.7,
                "maxTokens": 1000,
                "topP": 0.9
            }
        )
        return response['output']['message']['content'][0]['text']
    except Exception as e:
        logger.error(f"Bedrock error: {str(e)}")
        return "I'm experiencing technical difficulties. Please try again in a moment."

# Health check endpoint for ALB
if st.query_params.get("health") == "check":
    st.write("OK")
    st.stop()

# Streamlit UI
st.set_page_config(
    page_title="Secure Bedrock Chatbot", 
    page_icon="🤖",
    initial_sidebar_state="expanded"
)
st.title("🤖 Secure Bedrock Chatbot")
st.markdown("*Powered by Claude Sonnet 4 with Enterprise Security*")

# Sidebar configuration
with st.sidebar:
    st.header("Configuration")
    language = st.selectbox("Response Language", ["English", "Spanish", "French"])
    st.markdown("---")
    st.markdown("**Security Features:**")
    st.markdown("✅ ALB Cognito Authentication")
    st.markdown("✅ HTTPS Encryption")
    st.markdown("✅ Private Network")
    st.markdown("✅ VPC Endpoints")
    st.markdown("✅ IAM Role Restrictions")
    st.markdown("✅ Input Validation")

# Main chat interface
st.subheader("Ask me anything")
question = st.text_area(
    "Your question:", 
    placeholder="Enter your question here...", 
    height=100,
    max_chars=4000,
    help="Maximum 4000 characters"
)

if st.button("Send", type="primary"):
    is_valid, result = validate_input(question)
    
    if not is_valid:
        st.error(result)
    else:
        with st.spinner("Thinking..."):
            response = query_bedrock(language.lower(), result)
        
        st.success("Response:")
        st.write(response)
